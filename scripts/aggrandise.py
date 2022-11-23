#!/usr/bin/env python3

import argparse
from functools import partial
import logging

import glanceclient
import openstack

logging.basicConfig(
    format='%(message)s',
    level=logging.INFO)

LOG = logging.getLogger(__name__)
LOG.setLevel(logging.DEBUG)

# Project names are NeCTAR-Images / NeCTAR-Images-Archive
PROJECT_IDS = {
    'production': {
        'project': '28eadf5ad64b42a4929b2fb7df99275c',
        'archive_project': 'c9217cb583f24c7f96567a4d6530e405',
    },
    'rctest': {
        'project': 'cef831fd182944e9848dc1ea9cd9d6a5',
        'archive_project': '41215d7761b945479c7f2d24bc1c8afa',
    }
}


class Aggrandise(object):

    def __init__(self, dry_run=False):
        self.dry_run = dry_run
        self.session = self.get_session()

    def get_session(self):
        conn = openstack.connect()
        return conn.session

    def get_glanceclient(self):
        return glanceclient.Client('2', session=self.session)

    def get_archive_name(self, image):
        name = image.name
        if hasattr(image, 'nectar_build'):
            build = f'[v{image.nectar_build}]'
            # Add build number to name if it's not already there
            # E.g. NeCTAR Ubuntu 17.10 LTS (Artful) amd64 (v10)
            if build not in image.name:
                name = f'{name} {build}'
        return name

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

    def promote(self, image, project, archive_project):
        gc = self.get_glanceclient()
        img = gc.images.get(image)

        try:
            name = img.nectar_name
            build = img.nectar_build
        except AttributeError as e:
            raise type(e)(
                "nectar_name or nectar_build not found for image.") from e

        match_check = partial(self.match, name, int(build))
        matches = filter(
            match_check, gc.images.list(filters={'owner': img.owner}))

        for i in matches:
            self.archive(image=i.id, archive_project=archive_project)

        if self.dry_run:
            LOG.info(f"Would promote image {img.name} ({img.id})")
        else:
            LOG.info(f"Promoting image {img.name} ({img.id})")
            gc.images.update(img.id, visibility='public', owner=project)

    def archive(self, image, archive_project):
        gc = self.get_glanceclient()
        try:
            img = gc.images.get(image)
        except glanceclient.exc.HTTPNotFound:
            raise Exception('Image ID not found.')

        name = self.get_archive_name(img)

        if self.dry_run:
            LOG.info("Running in dry run mode")
            LOG.info(f"Would archive image {name} ({img.id}) to project "
                     f"{archive_project}")
            if hasattr(img, 'murano_image_info'):
                LOG.info(f'Would remove murano image properties from {img.id}')
        else:
            LOG.info(f"Archiving image {name} ({img.id}) to project "
                     f"{archive_project}")
            gc.images.update(img.id, name=name, owner=archive_project,
                             visibility='community')

            if hasattr(img, 'murano_image_info'):
                LOG.info(f"Removing murano image properties from {img.id}")
                gc.images.update(img.id, remove_props=['murano_image_info'])


def parse_args(argv):
    actions = ['promote', 'archive']
    parser = argparse.ArgumentParser(
        description="Image workflow tool")
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
    return parser.parse_args(argv)


def main(argv=None):
    args = parse_args(argv)
    aggrandise = Aggrandise(dry_run=args.dry_run)

    # Use provided project IDs if given
    project = args.project or PROJECT_IDS[args.environment]['project']
    archive_project = (args.archive_project or
                       PROJECT_IDS[args.environment]['archive_project'])

    if args.action == 'promote':
        aggrandise.promote(image=args.image, project=project,
                           archive_project=archive_project)
    elif args.action == 'archive':
        aggrandise.archive(image=args.image,
                           archive_project=archive_project)
    else:
        LOG.error('Not a valid action: %s' % args.action)


if __name__ == '__main__':
    main()
