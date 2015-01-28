#!/bin/bash
set -x

# Test OS
if [ -f /etc/os-release ]; then
    source /etc/os-release
fi

# Debian Wheeze required backports for cloud-init
if [ "$ID" == "debian" ] && [ "$VERSION_ID" == "7" ]; then
    echo 'deb http://ftp.debian.org/debian wheezy-backports main' >> /etc/apt/sources.list
fi

apt-get -qq -y update
apt-get -qq -y install cloud-utils cloud-init cloud-initramfs-growroot bash-completion

# use our specific config
mv -f /tmp/cloud.cfg /etc/cloud/cloud.cfg
# remove distro installed package to ensure Ec2 is only enabled
rm -f /etc/cloud/cloud.cfg.d/90_*

# Setup utils
apt-get -qq -y install sudo rsync curl less

# change GRUB so log tab and console tab in openstack work
if [ -e /etc/default/grub ] ; then
    sed -i -e 's/quiet/console=ttyS0,115200n8 console=tty0/' /etc/default/grub
    update-grub
fi

# Make sure sudo works properly with openstack
sed -i 's/env_reset/env_reset\nDefaults\t\!requiretty/' /etc/sudoers

# Fix networking to auto bring up eth0 and work correctly with cloud-init
sed -i 's/allow-hotplug eth0/auto eth0/' /etc/network/interfaces

apt-get -qq -y autoremove
apt-get -qq -y autoclean
apt-get -qq -y clean
