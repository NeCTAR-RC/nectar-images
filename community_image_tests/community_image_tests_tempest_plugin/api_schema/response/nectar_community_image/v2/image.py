# Copyright 2014 NEC Corporation.  All rights reserved.
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
        'properties': {
            'id': {'type': 'string'},
            'status': {'type': 'string'},
            'updated_at': {'type': 'string'},
            'name': {'type': ['string', 'null']},
            'created_at': {'type': 'string'},
            'min_disk': {'type': 'integer'},
            'min_ram': {'type': 'integer'},
            'container_format': {'type': 'string'},
            'disk_format': {'type': 'string'},
            'schema': {'type': 'string'},
            'tags': {'type': 'array'},
            'updated_at': {'type': 'string'},
            'published_at': {'type': 'string'},
            'visibility': {'type': 'string'},
            'file': {'type': 'string'},
            'owner': {'type': 'string'},
            'virtual_size': {'type': ['integer', 'null']},
            'checksum': {'type': 'string'},
            'protected': {'type': 'boolean'},
            'self': {'type': 'string'},
            'image_location': {'type': 'string'},
            'image_state': {'type': 'string'},
            'image_type': {'type': 'string'},
            'availability_zone': {'type': 'string'},
            'ramdisk_id': {'type': ['string', 'null']},
            'kernel_id': {'type': ['string', 'null']},
            'clean_attempts': {'type': 'string'},
            'os_distro': {'type': 'string'},
            'os_version': {'type': 'string'},
            'default_user': {'type': 'string'},
            'added_packages': {'type': 'string'},
            'description': {'type': 'string'},
            'expiry_date': {'type': 'string'},
            'size': {'type': ['integer', 'null']}
        },
        'additionalProperties': False,
        # The required parameters for community images
        'required': ['container_format', 'min_disk', 'min_ram', 'published_at',
                    'disk_format', 'os_distro', 'os_version', 'default_user',
                    'added_packages', 'description', 'expiry_date'] 
    }
}
