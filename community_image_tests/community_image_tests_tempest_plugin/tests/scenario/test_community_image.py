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

    """This is a suite of basic scenario tests for
       checking Community Images.

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

    def get_image_info(self):
        # Get the image ID
        image_id = CONF.compute.image_ref

        # Get the image info
        # whilst validating against the
        # community image schema
        info = self.community_image_client.show_image(image_id)

        return info

    def create_server_client(self):
        # Get the image info
        info = self.get_image_info()

        # Create keypair
        self.keypair = self.create_keypair()

        # Set linux user
        self.linux_user = info['default_user']

        # Create server
        self.server = self.create_server(image_id=CONF.compute.image_ref,
                                    key_name=self.keypair['name'],
                                    wait_until='ACTIVE')
        self.nova_show(self.server)
        self.ip = self.get_server_ip(self.server)
        self.create_and_add_security_group_to_server(self.server)

        # Check that we can SSH to the server before reboot
        self.linux_client = self.get_remote_client(
            self.ip, username=self.linux_user,
            private_key=self.keypair['private_key'])

    @test.idempotent_id('0f6b273d-3ded-4382-96a0-6523a11fd6e8')
    @test.services('compute', 'image')
    def test_image_expiry(self):
        # Get the image info
        info = self.get_image_info()

        # Check if the image has expired
        expires_at = datetime.datetime.strptime(
                        info['expires_at'], "%Y-%m-%dT%H:%M:%SZ")
        now = datetime.datetime.now()
        self.assertTrue('Image ' + info['id'] + 'is expired', expires_at > now)

    @test.idempotent_id('fbebd1b0-2a40-43b7-be16-8709fb83511c')
    @test.services('compute', 'image')
    def test_os_vulnerability(self):
        # Create the server client
        self.create_server_client()

        # Install git
        self.linux_client.exec_command("""
                        if [ $(command -v zypper) ]; then\
                        sudo zypper install -y git;
                        elif [ $(command -v yum) ]; then\
                        sudo yum install git -y;
                        elif [ $(command -v apt-get) ]; then\
                        sudo apt-get install git -y;
                        fi""")

        # Get Lynis and set to fail on warnings
        self.linux_client.exec_command("""
                        cd /tmp; git clone \
                        https://github.com/CISOfy/lynis.git;
                        sudo chown -R 0:0 lynis;cd lynis;
                        sudo sed -i -e \
                        's/error\-on\-warnings=no/error\-on\-warnings=yes/' \
                        default.prf""")

        # Configure Lynis auditing
        # Skipping Firewall checking : [FIRE-4512], [FIRE-4513], [FIRE-4590]
        # Skipping Postfix information leakage: [MAIL-8818]
        # Skipping Accounts w/o password checking: [AUTH-9218]
        # Skipping Vulnerable packages checks: [PKGS-7392]
        lynis_skip_list = [
                        'FIRE-4512', 'FIRE-4513', 'FIRE-4590',
                        'MAIL-8818', 'AUTH-9218', 'PKGS-7392']
        skip = '\n'.join(
                        "skip-test=" + test +
                        "\\" for test in lynis_skip_list)
        skip_command = """cd /tmp/lynis; sudo sed -i -e \
                        '/Skip a test (one per line)/a\\%s\n' default.prf;
                        sudo ./lynis audit system""" % skip
        self.linux_client.exec_command(skip_command)

    @test.idempotent_id('a94ff412-062d-4327-b345-df69cb7ea1aa')
    @test.services('compute', 'image')
    def test_minimum_basic_scenario(self):
        # Create the server client
        self.create_server_client()

        # Check if root filesystem is resized
        self.linux_client.exec_command("""
                        df -P -BG / | sed -n -e 's/^\/\s\+\([0-9]\+\)G.*/\1/p'\
                        || test $? -gt 4""")

        # Check that no default passwords exist
        self.linux_client.exec_command("""
                                test "$(sudo cut -d ':' -f 2 /etc/shadow \
                                | cut -d '$' -sf3)" = "" """)

        # Check if single SSH authorized key for root exists
        rootkey = self.linux_client.exec_command(
                        """sudo wc -l /root/.ssh/authorized_keys \
                        | cut -d ' ' -f1""")
        self.assertEqual(1, eval(rootkey))

        # Check if single SSH authorized key for current user exists
        userkey = self.linux_client.exec_command(
                        """wc -l ~/.ssh/authorized_keys | cut -d ' ' -f1""")
        self.assertEqual(1, eval(userkey))

        self.nova_reboot(self.server)

        # check that we can SSH to the server after reboot
        # (both connections are part of the scenario)
        self.linux_client = self.get_remote_client(
            self.ip, username=self.linux_user, private_key=self.keypair['private_key'])
