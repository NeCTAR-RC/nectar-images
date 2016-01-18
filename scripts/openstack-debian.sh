#!/bin/bash
set -x
set -e

# Test OS
if [ -f /etc/os-release ]; then
    source /etc/os-release
fi

# Debian 7 requires some extra repos for OpenStack packages
if [ "$ID" == "debian" ] && [ "$VERSION_ID" == "7" ]; then
    wget -qO - http://archive.gplhost.com/debian/repository_key.asc | apt-key add -
    echo 'deb http://mirror.aarnet.edu.au/debian/ wheezy-backports main' >> /etc/apt/sources.list
    echo 'deb http://archive.gplhost.com/debian juno main' >> /etc/apt/sources.list
    echo 'deb http://archive.gplhost.com/debian juno-backports main' >> /etc/apt/sources.list
fi

apt-get -qq -y update
apt-get -qq -y install cloud-utils cloud-init cloud-initramfs-growroot bash-completion heat-cfntools

# Install heat cfntools for Debian 7
if [ "$ID" == "ubuntu" ] && [ "$VERSION_ID" == "14.04" ]; then
    # heat-cfntools package is broken on Trusty. Pull in the utopic version instead
    wget http://au.archive.ubuntu.com/ubuntu/pool/universe/h/heat-cfntools/heat-cfntools_1.2.7-2_all.deb -O /tmp/heat-cfntools_1.2.7-2_all.deb
    dpkg -i /tmp/heat-cfntools_1.2.7-2_all.deb || true # keep script running
    apt-get -qq -y install -f
    rm /tmp/heat-cfntools_1.2.7-2_all.deb
fi

# Use our specific config for cloud init and remove distro
# installed package to ensure Ec2 is only enabled
[ -f /tmp/cloud.cfg ] && mv -f /tmp/cloud.cfg /etc/cloud/cloud.cfg
rm -f /etc/cloud/cloud.cfg.d/90_*

# Setup utils
apt-get -qq -y install sudo rsync curl less

# change GRUB so log tab and console tab in openstack work
if [ -e /etc/default/grub ] ; then
    sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*$/GRUB_CMDLINE_LINUX_DEFAULT="elevator=noop console=ttyS0,115200n8 console=tty0 consoleblank=0 net.ifnames=0 biosdevname=0"/g' /etc/default/grub
    update-grub
fi

# Make sure sudo works properly with openstack
sed -i 's/env_reset/env_reset\nDefaults\t\!requiretty/' /etc/sudoers

# Fix networking to auto bring up eth0 and work correctly with cloud-init
sed -i 's/allow-hotplug eth0/auto eth0/' /etc/network/interfaces

apt-get -qq -y autoremove
apt-get -qq -y autoclean
apt-get -qq -y clean
