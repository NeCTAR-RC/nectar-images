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

import copy

from tempest.lib.api_schema.response.compute.v2_1 import parameter_types

image_links = copy.deepcopy(parameter_types.links)
image_links['items']['properties'].update({'type': {'type': 'string'}})

community_image_schema = {
    'status_code': [200],
    'response_body': {
        'type': 'object',
        'properties': {},
        'additionalProperties': True,
        # The required parameters for community images
        'required': [
                    'container_format', 'min_disk', 'min_ram',
                    'disk_format', 'os_distro', 'os_version', 'default_user',
                    'added_packages', 'description', 'publisher_name',
                    'publisher_org', 'publisher_email', 'change_log']
    }
}
