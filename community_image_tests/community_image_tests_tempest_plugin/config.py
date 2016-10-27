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

from oslo_config import cfg
from tempest import config

community_images_group = cfg.OptGroup(
    name="community_image",
    title="Community Images ID"
)

CommunityImagesGroup = [
    cfg.StrOpt(
                "image_id", default="",
                help="Image ID of the community image to be tested"),
    cfg.StrOpt(
                "endpoint_type", default="publicURL",
                choices=["publicURL", "adminURL", "internalURL"],
                help="The endpoint type for the community image service."),
    cfg.StrOpt(
                "catalog_type", default="image",
                help="The catalog type for the community image service."),
]
