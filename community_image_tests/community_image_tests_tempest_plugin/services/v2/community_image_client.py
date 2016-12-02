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

from oslo_serialization import jsonutils as json
from six.moves.urllib import parse as urllib
from community_image_tests_tempest_plugin.\
    api_schema.response.nectar_community_image.v2\
    import image as schema

from tempest.lib.common import rest_client
from tempest.lib import exceptions as lib_exc
from tempest.lib.services.image.v2 import images_client


class CommunityImagesClient(images_client.ImagesClient):

    def show_image(self, image_id):
        url = 'images/%s' % image_id
        resp, body = self.get(url)
        self.expected_success(200, resp.status)
        body = json.loads(body)
        self.validate_response(schema.community_image_schema, resp, body)
        return rest_client.ResponseBody(resp, body)
