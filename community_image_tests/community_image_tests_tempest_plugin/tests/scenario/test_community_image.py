# Copyright (c) 2016, Monash e-Research Centre
#  (Monash University, Australia)
#  All rights reserved.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

from tempest.common import custom_matchers
from tempest.common import waiters
from tempest import config
from tempest import exceptions
from tempest.lib import exceptions as lib_exc
from tempest.common.utils import data_utils
from tempest.scenario import test_minimum_basic
from community_image_tests_tempest_plugin.\
    services.v2.community_image_client\
    import CommunityImagesClient
from tempest import test
import datetime

CONF = config.CONF


class TestCommunityImage(test_minimum_basic.TestMinimumBasicScenario):

    """This is a basic scenario test for checking Community Images.

    This test below:
    * across the multiple components
    * as a regular user
    * with and without optional parameters
    * check command outputs

    Steps:
    1. Check and verify Metadata
    2. Check Image expiry
    3. Create keypair
    4. Boot instance with keypair and get list of instances
    5. Check SSH connection to instance
    6. Run diagnostic tests on instance
    7. Reboot instance
    8. Check SSH connection to instance after reboot

    """

    credentials = ['primary']

    @classmethod
    def setup_clients(cls):
        super(TestCommunityImage, cls).setup_clients()
        # Community image client
        cls.community_image_client = CommunityImagesClient(
            cls.manager.auth_provider,
            CONF.image.catalog_type,
            CONF.identity.region,
            endpoint_type=CONF.image.endpoint_type,
            **cls.manager.default_params)

    @test.idempotent_id('a94ff412-062d-4327-b345-df69cb7ea1aa')
    @test.services('compute', 'network')
    def test_minimum_basic_scenario(self):

        # Get the image ID
        image_id = CONF.compute.image_ref

        # Get the image info
        # whilst validating against the
        # community image schema
        info = self.community_image_client.show_image(image_id)

        # Check if the image has expired
        expiry_date = datetime.datetime.strptime(
                        info['expiry_date'], "%Y-%m-%dT%H:%M:%SZ")
        now = datetime.datetime.now()
        self.assertTrue('Image ' + image_id + 'is expired', expiry_date > now)
        linux_user = info['default_user']
        keypair = self.create_keypair()
        server = self.create_server(image_id=CONF.compute.image_ref,
                                    key_name=keypair['name'],
                                    wait_until='ACTIVE')
        servers = self.nova_list()
        self.assertIn(server['id'], [x['id'] for x in servers])
        self.nova_show(server)
        ip = self.get_server_ip(server)
        self.create_and_add_security_group_to_server(server)

        # Check that we can SSH to the server before reboot
        self.linux_client = self.get_remote_client(
            ip, username=linux_user, private_key=keypair['private_key'])

        # Get Volume attachments of the server
        #volume_list = self.servers_client.list_volume_attachments(
        #    server['id'])

        # Check if there are any volume attachments
        #if not volume_list['volumeAttachments']:
        #    # Good, now check that ephemeral disk is ext4
        #    # and read-write mounted on vdb
        #    self.linux_client.exec_command("""
        #                    grep '/dev/vdb.*ext4.*rw' /proc/mounts""")

        # Check if root filesystem is resized
        self.linux_client.exec_command("""
                        df -P -BG / | sed -n -e 's/^\/\s\+\([0-9]\+\)G.*/\1/p'\
                        || test $? -gt 4""")

        # Check that no default passwords exist
        self.linux_client.exec_command("""
                                test "$(sudo cut -d ':' -f 2 /etc/shadow \
                                | cut -d '$' -sf3)" = "" """)

        # Check if single SSH authorized key for root exists
        rootkey = str(self.linux_client.exec_command(
                        """sudo wc -l /root/.ssh/authorized_keys \
                        | cut -d ' ' -f1"""))
        self.assertEqual(
                        'Expected 1 %s key, but found %s'
                        % ('root', rootkey.strip()),
                        '1', rootkey.strip())

        # Check if single SSH authorized key for current user exists
        userkey = str(self.linux_client.exec_command(
                        """wc -l ~/.ssh/authorized_keys | cut -d ' ' -f1"""))
        self.assertEqual(
                        'Expected 1 %s key, but found %s'
                        % ('user', userkey.strip()), '1', userkey.strip())

        self.nova_reboot(server)

        # check that we can SSH to the server after reboot
        # (both connections are part of the scenario)
        self.linux_client = self.get_remote_client(
            ip, username=linux_user, private_key=keypair['private_key'])
