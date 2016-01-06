#!/bin/bash
set -x
set -e

# Install our cloud-init and heat-cfn tools
zypper addrepo -f obs://Cloud:OpenStack:Juno/openSUSE_13.2 Juno
zypper -n --no-gpg-checks install cloud-init python-heat-cfntools e2fsprogs

for SERVICE in cloud-config cloud-final cloud-init cloud-init-local; do
    systemctl enable $SERVICE
done

# Move our cloud config into place
[ -f /tmp/cloud.cfg ] && mv /tmp/cloud.cfg /etc/cloud/cloud.cfg

# Common kernel args
KERNEL_ARGS=" splash=slient showopts elevator=noop console=ttyS0,115200n8 console=tty0 consoleblank=0"

# change GRUB so log tab and console tab in openstack work
if [ -e /etc/default/grub ] ; then
    sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT=.*$/GRUB_CMDLINE_LINUX_DEFAULT=\" ${KERNEL_ARGS}\"/g" /etc/default/grub
    grub2-mkconfig -o /boot/grub2/grub.cfg
fi

# Make sure sudo works properly with openstack
sed -i "s/^.*requiretty$/Defaults !requiretty/" /etc/sudoers
