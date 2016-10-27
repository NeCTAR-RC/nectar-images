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
from tempest.api.compute.servers import test_create_server
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
    3. Create a test flavor without ephemeral disk
    4. Create keypair
    5. Boot base instance with keypair and
       flavor with ephemeral disk
    6. Boot test instance with keypair and
       flavor without ephemeral disk
    7. Get list of instances
    6. Check SSH connection to both instances before reboot
    7. Check SSH connection to both instances after reboot
    8. Check whether ephemeral disk was created
       on the base instance
    9. Run diagnostic tests on the base instance

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

    def create_test_flavor(self):
        # Get the compute ref flavor
        ref_flavor = self.flavors_client.show_flavor(
                                CONF.compute.flavor_ref)['flavor']

        # Create a test flavor
        # without ephemeral disk
        test_flavor_disk_name = data_utils.rand_name('without_eph')
        test_flavor_disk_id = data_utils.rand_int_id(start=1000)
        ram = ref_flavor['ram']
        vcpus = ref_flavor['vcpus']
        disk = ref_flavor['disk']

        test_flavor = self.flavors_client.create_flavor(
                                name=test_flavor_disk_name,
                                ram=ram, vcpus=vcpus, disk=disk,
                                id=test_flavor_disk_id)['flavor']
        return test_flavor

    def get_linux_client(self, keypair, flavor_id, linux_user):
        # Create the server
        server = self.create_server(image_id=CONF.compute.image_ref,
                                    key_name=keypair['name'],
                                    flavor=flavor_id,
                                    wait_until='ACTIVE')
        servers = self.nova_list()
        self.assertIn(server['id'], [x['id'] for x in servers])
        self.nova_show(server)
        ip = self.get_server_ip(server)

        self.create_and_add_security_group_to_server(server)

        # Check that we can SSH to the server
        linux_client = self.get_remote_client(
            ip, username=linux_user, private_key=keypair['private_key'])

        self.nova_reboot(server)

        # Check that we can SSH to the server after reboot
        # (both connections are part of the scenario)
        linux_client = self.get_remote_client(
            ip, username=linux_user, private_key=keypair['private_key'])

        # Get Volume attachments of the server
        volume_list = self.servers_client.list_volume_attachments(
            server['id'])

        # Check if there are any extra volume attachments
        self.assertEqual(0, len(volume_list['volumeAttachments']))

        return linux_client

    def create_servers_and_test_ephemeral_disk(self, image_info):
        # Create Keypair
        keypair = self.create_keypair()

        # Create test flavor
        test_flavor = self.create_test_flavor()

        # Get linux user
        linux_user = image_info['default_user']

        # Get ref linux client
        ref_linux_client = self.get_linux_client(
                                    keypair,
                                    CONF.compute.flavor_ref,
                                    linux_user)
        # Get test linux client
        test_linux_client = self.get_linux_client(
                                    keypair,
                                    test_flavor['id'],
                                    linux_user)

        # Delete the test flavor
        self.flavors_client.delete_flavor(test_flavor['id'])

        ref_partitions = len(ref_linux_client.get_partitions().split('\n'))
        test_partitions = len(test_linux_client.get_partitions().split('\n'))

        self.assertEqual(test_partitions + 1, ref_partitions)

        return ref_linux_client

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

        # Create servers and test ephemeral disk
        self.linux_client = self.create_servers_and_test_ephemeral_disk(info)

        # Check that ephemeral disk is
        # read-write mounted on vdb
        self.linux_client.exec_command("""
                        grep '/dev/vdb.*rw' /proc/mounts""")

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
