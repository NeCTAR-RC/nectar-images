# Copyright 2013 NEC Corporation
# All Rights Reserved.
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
from tempest.scenario import manager
from community_image_tests_tempest_plugin.\
    services.v2.community_image_client\
    import CommunityImagesClient
from tempest import test

CONF = config.CONF


class TestCommunityImage(manager.ScenarioTest):

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
        super(manager.ScenarioTest, cls).setup_clients()
        # Community image client
        cls.community_image_client = CommunityImagesClient(
            cls.manager.auth_provider,
            CONF.community_image.catalog_type,
            CONF.identity.region,
            endpoint_type=CONF.community_image.endpoint_type,
            **cls.manager.default_params)
        cls.flavors_client = cls.manager.flavors_client
        cls.compute_floating_ips_client = (
            cls.manager.compute_floating_ips_client)
        if CONF.service_available.glance:
            # Glance image client v1
            cls.image_client = cls.manager.image_client
        # Compute image client
        cls.compute_images_client = cls.manager.compute_images_client
        cls.keypairs_client = cls.manager.keypairs_client
        # Nova security groups client
        cls.compute_security_groups_client = (
            cls.manager.compute_security_groups_client)
        cls.compute_security_group_rules_client = (
            cls.manager.compute_security_group_rules_client)
        cls.servers_client = cls.manager.servers_client
        cls.interface_client = cls.manager.interfaces_client
        # Neutron network client
        cls.networks_client = cls.manager.networks_client
        cls.ports_client = cls.manager.ports_client
        cls.routers_client = cls.manager.routers_client
        cls.subnets_client = cls.manager.subnets_client
        cls.floating_ips_client = cls.manager.floating_ips_client
        cls.security_groups_client = cls.manager.security_groups_client
        cls.security_group_rules_client = (
            cls.manager.security_group_rules_client)
        # Heat client
        cls.orchestration_client = cls.manager.orchestration_client

        if CONF.volume_feature_enabled.api_v1:
            cls.volumes_client = cls.manager.volumes_client
            cls.snapshots_client = cls.manager.snapshots_client
        else:
            cls.volumes_client = cls.manager.volumes_v2_client
            cls.snapshots_client = cls.manager.snapshots_v2_client

    def nova_list(self):
        servers = self.servers_client.list_servers()
        # The list servers in the compute client is inconsistent...
        return servers['servers']

    def nova_show(self, server):
        got_server = (self.servers_client.show_server(server['id'])
                      ['server'])
        excluded_keys = ['OS-EXT-AZ:availability_zone']
        # Exclude these keys because of LP:#1486475
        excluded_keys.extend(['OS-EXT-STS:power_state', 'updated'])
        self.assertThat(
            server, custom_matchers.MatchesDictExceptForKeys(
                got_server, excluded_keys=excluded_keys))

    def nova_reboot(self, server):
        self.servers_client.reboot_server(server['id'], type='SOFT')
        waiters.wait_for_server_status(self.servers_client,
                                       server['id'], 'ACTIVE')

    def create_and_add_security_group_to_server(self, server):
        secgroup = self._create_security_group()
        self.servers_client.add_security_group(server['id'],
                                               name=secgroup['name'])
        self.addCleanup(self.servers_client.remove_security_group,
                        server['id'], name=secgroup['name'])

        def wait_for_secgroup_add():
            body = (self.servers_client.show_server(server['id'])
                    ['server'])
            return {'name': secgroup['name']} in body['security_groups']

        if not test.call_until_true(wait_for_secgroup_add,
                                    CONF.compute.build_timeout,
                                    CONF.compute.build_interval):
            msg = ('Timed out waiting for adding security group %s to server '
                   '%s' % (secgroup['id'], server['id']))
            raise exceptions.TimeoutException(msg)

    @test.idempotent_id('a94ff412-062d-4327-b345-df69cb7ea1aa')
    @test.services('compute', 'network')
    def test_community_image(self):

        # Get the image ID
        image_id = CONF.community_image.image_id

        # Get the image info
        # whilst validating against the
        # community image schema
        info = self.community_image_client.show_image(image_id)

        # Check if the image has expired
        import datetime
        expiry_date = datetime.datetime.strptime(
                        info['expiry_date'], "%Y-%m-%dT%H:%M:%SZ")
        now = datetime.datetime.now()
        self.assertTrue('Image ' + image_id + 'is expired', expiry_date > now)
        linux_user = info['default_user']
        keypair = self.create_keypair()
        server = self.create_server(image_id=CONF.community_image.image_id,
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
        volume_list = self.servers_client.list_volume_attachments(
            server['id'])

        # Check if there are any volume attachments
        if not volume_list['volumeAttachments']:
            # Good, now check that ephemeral disk is ext4
            # and read-write mounted on vdb
            self.linux_client.exec_command("""
                            grep '/dev/vdb.*ext4.*rw' /proc/mounts""")

        # Check if root filesystem is resized
        self.linux_client.exec_command("""
                        df -P -BG / | sed -n -e 's/^\/\s\+\([0-9]\+\)G.*/\1/p'\
                        || test $? -gt 4""")

        # Check if kernel console log configured correctly
        self.linux_client.exec_command("""
                        grep 'console=tty0 console=ttyS0,115200n8' \
                        /proc/cmdline""")

        # Check that default route via interface named eth0
        self.linux_client.exec_command("""
                        /sbin/ip route | grep -E 'default via .* dev eth0'""")

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
