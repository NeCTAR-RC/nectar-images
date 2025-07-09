#!/bin/bash -e


NAME="NeCTAR Windows Server 2022 $(date --iso)"
BUILD_DIR="builds/build_files/packer-windows-2022"

PROPERTIES=""
# Loop through and apply facts as image properties
for FACT in $BUILD_DIR/.facts/*; do
    KEY=${FACT##*/}
    VAL=$(cat $FACT)
    # Skip nectar_name
    [ "$KEY" == "nectar_name" ] && continue
    PROPERTIES="$PROPERTIES --property ${KEY}=${VAL}"
done

IMAGE_ID=$(openstack image create -f value -c id \
	--disk-format qcow2 --progress $PROPERTIES \
	--file $BUILD_DIR/image.qcow2 \
	"$NAME")

openstack image show "$IMAGE_ID"
