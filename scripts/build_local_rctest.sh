#!/bin/bash -xe

FILE=$1
[ -z $FILE ] && exit 1

BUILD_NUMBER=$2
[ -z $BUILD_NUMBER ] && exit 1

NAME=$(basename -s .json ${FILE})
BUILD_NAME="${NAME}_build_${BUILD_NUMBER}"

jq ".builders[0].image_name = \"$BUILD_NAME\"" ${NAME}.json > ${BUILD_NAME}.json
packer-io build ${BUILD_NAME}.json
openstack image save --file ${BUILD_NAME}_large.qcow2 $BUILD_NAME
openstack image delete --property name=$NAME
qemu-img convert -c -o compat=0.10 -O qcow2 ${BUILD_NAME}_large.qcow2 ${BUILD_NAME}.qcow2
rm ${BUILD_NAME}_large.qcow2
openstack image create -f value -c id --disk-format qcow2 --container-format bare --file ${BUILD_NAME}.qcow2 "${NAME}-v${BUILD_NUMBER}"
rm ${BUILD_NAME}.qcow2

