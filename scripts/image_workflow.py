#!/usr/bin/env python3

import argparse
from collections import defaultdict
import datetime
from dateutil.relativedelta import relativedelta
from functools import partial
import logging

import openstack
import prettytable

import glanceclient
from glanceclient import exc
from keystoneclient import exceptions as ks_exc

# Make Gnocchi optional
try:
    from gnocchiclient.v1 import client as gnocchi_client
except:
    pass

logging.basicConfig(
    format='%(message)s',
    level=logging.INFO)

LOG = logging.getLogger(__name__)
LOG.setLevel(logging.DEBUG)


project_ids = {
'production' : {
    'project':'28eadf5ad64b42a4929b2fb7df99275c',  # NeCTAR-Images
    'archive_project':'c9217cb583f24c7f96567a4d6530e405',  # NeCTAR-Images-Archive
  },
  'rctest' : {
    'project':'cef831fd182944e9848dc1ea9cd9d6a5',  # NeCTAR-Images
    'archive_project':'41215d7761b945479c7f2d24bc1c8afa',  # NeCTAR-Images-Archive
  }
}

def get_project(args, project):
    if args[project]:
        return args[project]

    if args['environment']:
        environment = args['environment']
        return project_ids[environment][project]

def paginate(func):
    """Decorator to support Gnocchi pagination until a release with
    https://github.com/gnocchixyz/python-gnocchiclient/commit/7355fb2d7d3311f5962230a565574ce8c76c1caa
    is made
    """
    def wrapper(*args, **kwargs):
        limit = 3000
        if 'limit' in kwargs:
            limit = kwargs['limit']
        else:
            kwargs['limit'] = limit

        results = []
        while True:
            result = func(*args, **kwargs)
            results.extend(result)
            if len(result) < limit:
                break
            kwargs['marker'] = result[-1].get('id')
        return results
    return wrapper


class ImageWorkflow(object):

    def __init__(self, *args, **kwargs):
        self.dry_run = kwargs['dry_run']
        self.session = self.get_session()

    def get_session(self):
        conn = openstack.connect()
        return conn.session

    def get_glanceclient(self):
        return glanceclient.Client('2', session=self.session)

    def match(self, name, build, image):
        """return true if image's name == name, and nectar_build < build"""
        if image.get('nectar_name') != name:
            return False

        thisbuild = image.get('nectar_build')
        if not thisbuild:
            return False
        if int(thisbuild) < int(build):
            return True
        return False

    def promote(self, *args, **kwargs):
        image = kwargs['image']
        project = get_project(kwargs, 'project')
        gc = self.get_glanceclient()

        try:
            img = gc.images.get(image)
        except exc.HTTPNotFound:
            raise Exception("Image ID not found.")

        try:
            name = img.nectar_name
            build = (int(img.nectar_build))
        except AttributeError:
            raise Exception("nectar_name or nectar_build not found for image.")

        m_check = partial(self.match, name, build)
        matchingimages = filter(
            m_check, gc.images.list(filters={'owner': img.owner}))

        for i in matchingimages:
            self.archive(image=i)

        if self.dry_run:
            LOG.info(f"Would promote image {img.name} ({img.id})")
        else:
            LOG.info(f"Promoting image {img.name} ({img.id})")
            gc.images.update(img.id, visibility='public', owner=project)

    def archive(self, *args, **kwargs):
        archive_project = get_project(kwargs, 'archive_project')

        gc = self.get_glanceclient()
        try:
            img = gc.images.get(kwargs['image'])
        except exc.HTTPNotFound:
            raise Exception('Image ID not found.')

        name = img.name

        if 'nectar_build' in img:
            build = '[v%s]' % img.nectar_build

            # Add build number to name if it's not already there
            # E.g. NeCTAR Ubuntu 17.10 LTS (Artful) amd64 (v10)
            if build not in name:
                name = '%s %s' % (name, build)

        if self.dry_run:
            LOG.info("Running in dry run mode")
            LOG.info(f"Would archive image {name} ({img.id}) to project "
                     f"{archive_project}")
            if 'murano_image_info' in img:
                LOG.info(f'Would remove murano image properties from {img.id}')
        else:
            LOG.info(f"Archiving image {name} ({img.id}) to project "
                     f"{archive_project}")
            gc.images.update(img.id, name=name, owner=archive_project,
                             visibility='community')

            if 'murano_image_info' in img:
                LOG.info(f"Removing murano image properties from {img.id}")
                gc.images.update(img.id, remove_props=['murano_image_info'])

    def audit(self, *args, **kwargs):
        """Print usage information about all public images
        """
        gc = self.get_glanceclient()
        gnc = gnocchi_client.Client(session=self.session)

        projects = [
            get_project(kwargs, 'project'),
            get_project(kwargs, 'archive_project'),
        ]

        images = []
        image_details = defaultdict(list)

        LOG.debug('Building list of images...')
        for project in projects:
            for visibility in ['public', 'community']:
                filters = {'owner': project, 'visibility': visibility}
                images += list(gc.images.list(filters=filters))

        # Build a list of images names and all ids that match that name
        for i in images:
            # Use the name from the nectar_name property, otherwise use the
            # regular image name, but strip off any leading 'NeCTAR '
            name = i.get('nectar_name', i.name).replace('NeCTAR ', '')
            image_details[name].append(i.id)

        LOG.debug('Fetching instance data for %d images (this will take '
                  'a while)...', len(images))
        table = prettytable.PrettyTable(['Name', 'Running', 'Boots',
                                         'Last Boot', 'Public'])

        table.align = 'l'
        table.align['Running'] = 'r'
        table.align['Boots'] = 'r'

        for name, ids in image_details.items():
            ids = [str(i) for i in ids]  # remove unicode from str repr
            all_instances = paginate(gnc.resource.search)(
                resource_type='instance', query="image_ref in %s" % ids)

            boot_count = len(all_instances)
            last_boot = 'Never'
            if boot_count > 0:
                last_boot = max([i.get('started_at') for i in all_instances])

            running_instances = [s for s in all_instances
                                 if not s.get('ended_at')]

            public = 'public' in [j.visibility for j in
                                  [i for i in images if i.id in ids]]

            num = len(running_instances) if running_instances else 0
            table.add_row([name, num, boot_count, last_boot, public])

        print(table.get_string(sortby='Running', reversesort=True))

    def list(self, *args, **kwargs):
        """Print usage information about official images
        """
        gc = self.get_glanceclient()
        filters = {
            'owner': get_project(kwargs, 'project'),
        }
        images = gc.images.list(filters=filters)

        table = prettytable.PrettyTable(['ID', 'Name', 'Build', 'Date',
                                         'Visibility'])
        table.align = 'l'

        for i in images:
            build = getattr(i, 'nectar_build', 'N/A')
            table.add_row([i.id, i.name, build, i.created_at, i.visibility])

        print(table.get_string(sortby='Name'))

def main():
    actions = ['promote', 'archive', 'list', 'audit']
    parser = argparse.ArgumentParser()
    parser.add_argument('-e', '--environment',
                        choices=['production', 'rctest'],
                        default='production',
                        help='Cloud environment.\
                              Defaults to production.\
                              Can be overridden by -p/-a.')
    parser.add_argument('-i', '--image',
                        help='Image ID to process')
    parser.add_argument('-p', '--project',
                        help='Project. Overrides -e.')
    parser.add_argument('-a', '--archive-project',
                        help='Archive project. Overrides -e.')
    parser.add_argument('-v', '--verbose', action='store_true',
                        help='verbose mode')
    parser.add_argument('--dry-run', action='store_true', default=False,
                        help='Dry-run mode')
    parser.add_argument('action', choices=actions)
    args = parser.parse_args()

    kwargs = vars(args)
    workflow = ImageWorkflow(**kwargs)

    LOG.debug('Calling action: %s', args.action)
    func = getattr(workflow, args.action)
    func(**kwargs)

if __name__ == '__main__':
    main()
