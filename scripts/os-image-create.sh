#!/bin/bash -xe

NAME="NeCTAR Windows Server 2022 Testing"

openstack image delete "$NAME" || true

IMAGE_ID=$(openstack image create -f value -c id \
	--disk-format qcow2 \
	--progress \
	--property os_distro='windows' \
	--property hw_video_model='virtio' \
	--property hw_disk_bus='scsi' \
	--property hw_scsi_model='virtio-scsi' \
	--property hw_machine_type='q35' \
	--property hw_qemu_guest_agent='yes' \
	--property hw_firmware_type='uefi' \
	--property os_require_quiesce='yes' \
    --property trait:CUSTOM_NECTAR_WINDOWS='required' \
	--file builds/build_files/packer-windows-2022/image.qcow2 \
	"$NAME")

openstack image show "$IMAGE_ID"

openstack volume delete "$NAME" || true

cinder create --poll \
	--image-id "$IMAGE_ID" \
	--availability-zone QRIScloud \
	--name "NeCTAR Windows Server 2022 Testing" \
	30
