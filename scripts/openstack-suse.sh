#!/bin/bash
set -x
set -e

. /etc/os-release

case $VERSION_ID in
    42.1)
        zypper addrepo -f obs://Cloud:OpenStack:Liberty/openSUSE_Leap_42.1 Liberty
        ;;
    13.2)
        zypper addrepo -f obs://Cloud:OpenStack:Kilo/openSUSE_13.2 Liberty
        ;;
    *)
        echo "No OpenStack repository defines for openSUSE $VERSION"
        ;;
esac

# Install our cloud-init and heat-cfn tools
zypper -n --no-gpg-checks install cloud-init python-heat-cfntools e2fsprogs

# Remove repo after package installation
zypper -n removerepo Liberty

# Ensure cloud-init services are enabled on boot
for SERVICE in cloud-config cloud-final cloud-init cloud-init-local; do
    systemctl enable $SERVICE
done

# Move our cloud config into place
[ -f /tmp/cloud.cfg ] && mv /tmp/cloud.cfg /etc/cloud/cloud.cfg

# Common kernel args
KERNEL_ARGS="splash=slient showopts console=tty0 console=ttyS0,115200n8 vga=788 consoleblank=0 net.ifnames=0 biosdevname=0"

# change GRUB so log tab and console tab in openstack work
if [ -e /etc/default/grub ] ; then
    sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT=.*$/GRUB_CMDLINE_LINUX_DEFAULT=\" ${KERNEL_ARGS}\"/g" /etc/default/grub
    grub2-mkconfig -o /boot/grub2/grub.cfg
fi

# Make sure sudo works properly with openstack
sed -i "s/^.*requiretty$/Defaults !requiretty/" /etc/sudoers
