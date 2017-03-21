#!/bin/bash -xe
#
# Download and 
#

SCRIPT=$(realpath $0)
SCRIPT_PATH=$(dirname $SCRIPT)
WORKING_DIR="${SCRIPT_PATH}/.."

NAME=$1

case "$NAME" in
    ubuntu-14.04)
        URL=http://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64-disk1.img
        SUMS=http://cloud-images.ubuntu.com/trusty/current/SHA256SUMS
    ;;
    ubuntu-16.04)
        URL=http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img
        SUMS=http://cloud-images.ubuntu.com/xenial/current/SHA256SUMS
    ;;
    debian-8)
        URL=http://cdimage.debian.org/cdimage/openstack/current-8/debian-8-openstack-amd64.qcow2    
        SUMS=http://cdimage.debian.org/cdimage/openstack/current-8/SHA256SUMS
    ;;
    centos-6)
        URL=http://cloud.centos.org/centos/6/images/CentOS-6-x86_64-GenericCloud.qcow2
        SUMS=http://cloud.centos.org/centos/6/images/sha256sum.txt
    ;;
    centos-7)
        URL=http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2
        SUMS=http://cloud.centos.org/centos/7/images/sha256sum.txt
    ;;
    *)
        echo $"Usage: $0 [distro]"
        exit 1
esac

IMAGE_NAME="${NAME}-x86_64_vendor"
OLD_ID=$(openstack image list -f value -c ID --property name=$IMAGE_NAME)
[ -z $OLD_ID ] && exit 1

wget $URL -O ${IMAGE_NAME}.qcow2
NEW_ID=$(openstack image create -f value -c id --disk-format qcow2 --container-format bare --file ${IMAGE_NAME}.qcow2 ${IMAGE_NAME})
rm ${IMAGE_NAME}.qcow2
openstack image delete $OLD_ID
sed -i "s/$OLD_ID/$NEW_ID/g" $WORKING_DIR/${NAME}-*.json
