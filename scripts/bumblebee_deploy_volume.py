#!/usr/bin/env python3

import argparse
from datetime import datetime
import logging
import os
import time

import openstack

import cinderclient.client as cinder_client
import glanceclient.client as glance_client
from glanceclient import exc as glance_exc

from keystoneauth1 import loading as ks_loading
from keystoneauth1 import session as ks_session

FORMAT = "[%(asctime)s] %(levelname)s %(message)s"

logging.basicConfig(
    format=FORMAT,
    level=logging.INFO,
    datefmt='%Y-%m-%d %H:%M:%S')

LOG = logging.getLogger(__name__)
LOG.setLevel(logging.INFO)

DRY_RUN = True


def wait_for_status(status_f, res_id, status_field='status',
                    success_status=['available'], error_status=['error'],
                    sleep_time=10):
    while True:
        res = status_f(res_id)
        status = getattr(res, status_field, '').lower()
        if status in success_status:
            retval = True
            break
        elif status in error_status:
            retval = False
            break
        LOG.debug('Volume status is: %s', status)
        time.sleep(sleep_time)
    return retval


def parse_date(ds):
    dt = datetime.fromisoformat(ds.replace('Z', '+00:00'))
    return dt.strftime('%Y%m%d')


def do_stuff(args):
    conn = openstack.connect(cloud='envvars')
    gc = glance_client.Client('2', session=conn.session)
    cc = cinder_client.Client('3', session=conn.session)

    zones = args.zones.split(',')
    LOG.info('Processing image ID %s for zones: %s', args.image_id, args.zones)

    try:
        image = gc.images.get(args.image_id)
        LOG.debug('Found image %s', image['name'])
    except glance_exc.HTTPNotFound:
        LOG.error("Image ID not found.")
        raise

    image_id = image['id']
    nectar_name = image.get('nectar_name', image['name'])
    nectar_build = image.get('nectar_build', parse_date(image.created_at))
    image_name = f"{nectar_name} [{nectar_build}]"

    for az in zones:
        volumes = [
            v for v in cc.volumes.list()
            if hasattr(v, 'volume_image_metadata')
            and v.volume_image_metadata.get('image_id') == image_id
            and v.volume_image_metadata.get('nectar_build') == nectar_build
            and v.name == image_name
            and v.availability_zone == az]

        if len(volumes) == 1:
            vol = volumes[0]
            LOG.info('Found existing volume %s in %s AZ',
                     vol.name, az)
        elif len(volumes) == 0:
            if DRY_RUN:
                LOG.info('Would create volume for %s in %s AZ',
                         image_name, az)
            else:
                LOG.info('Creating volume for %s in %s AZ',
                         image_name, az)
                metadata = {
                    'nectar_name': nectar_name,
                    'nectar_build': nectar_build,
                }
                vol = cc.volumes.create(
                    args.size, availability_zone=az, imageRef=image_id,
                    name=image_name, metadata=metadata)

                if args.wait:
                    if wait_for_status(cc.volumes.get, vol.id):
                        LOG.info('Created volume %s', vol.id)
                    else:
                        LOG.error('Error creating volume: %s', vol.id)
                        raise SystemExit


def main():
    parser = argparse.ArgumentParser()
    parser.description = 'Bumblebee Volume management'

    parser.add_argument('-d', '--debug', action='store_true',
                        help='Show debug logging.')
    parser.add_argument('-w', '--wait', action='store_true',
                        help='Wait for status')
    parser.add_argument('-s', '--size', default=50, type=int,
                        help='Volume size in GB (default 50)')
    parser.add_argument('-y', '--no-dry-run', action='store_true',
                        default=False,
                        help='Perform the actual actions, default is to \
                        only show what would happen')
    parser.add_argument('-z', '--zones', action='store',
                        help='Availability zones (comma separated)')
    parser.add_argument('image_id', help='Image ID')
    args = parser.parse_args()

    if args.debug:
        LOG.setLevel(logging.DEBUG)

    if args.no_dry_run:
        global DRY_RUN
        DRY_RUN = False
    else:
        LOG.info('DRY RUN')

    do_stuff(args)


if __name__ == '__main__':
    main()
