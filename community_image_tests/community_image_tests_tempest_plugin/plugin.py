# Copyright 2015
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


import os

from tempest import config
from tempest.test_discover import plugins

from community_image_tests_tempest_plugin import config as community_image_config


class CommunityImageTestPlugin(plugins.TempestPlugin):
    def load_tests(self):
        base_path = os.path.split(os.path.dirname(
            os.path.abspath(__file__)))[0]
        test_dir = "community_image_tests_tempest_plugin/tests"
        full_test_dir = os.path.join(base_path, test_dir)
        return full_test_dir, base_path

    def register_opts(self, conf):
        config.register_opt_group(
            conf, community_image_config.community_images_group,
            community_image_config.CommunityImagesGroup)

    def get_opt_lists(self):
        return [(community_image_config.community_images_group.name,
                community_image_config.CommunityImagesGroup),]

    def get_service_clients(self):
        community_image_client_config = community_image_config.service_client_config('community_image_client')
        params_community_image_client = {
            'name': 'community_image_client_v2',
            'service_version': 'community_image_client.v2',
            'module_path': 'community_image_tests_tempest_plugin.services.v2.community_image_client',
            'client_names': ['CommunityImagesClient'],
        }
        params_community_image_client.update(community_image_client_config)
        return [params_community_image_client]
