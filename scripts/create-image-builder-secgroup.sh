#!/bin/bash

SECGROUP_ID=$(openstack security group show -c id -f value image-build)
if [ -z "$SECGROUP_ID" ]; then
    openstack security group create image-build
fi

# ICMP from all
openstack security group rule create --proto icmp image-build

# SSH from Core Services desktops and NAT pool
for CIDR in 128.250.116.128/26 192.43.209.64/29 172.26.21.0/24 172.26.20.192/26; do
    openstack security group rule create --proto tcp --dst-port 22 --remote-ip $CIDR image-build
done
