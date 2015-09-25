#!/bin/bash
set -x

function heat-cfntools {
    # Install heat cfntools
    if [ "$ID" == "ubuntu" ] && [ "$VERSION_ID" == "14.04" ]; then
        # Package is broken on Trusty. Pull in the utopic version instead
        wget http://mirror.aarnet.edu.au/ubuntu/pool/universe/h/heat-cfntools/heat-cfntools_1.2.7-2_all.deb -O /tmp/heat-cfntools_1.2.7-2_all.deb
        dpkg -i /tmp/heat-cfntools_1.2.7-2_all.deb
        apt-get -qq -y install -f
        rm /tmp/heat-cfntools_1.2.7-2_all.deb
    else
        apt-get -qq --no-install-recommends -y install heat-cfntools
    fi
}

function os-config {
    #install os-collect-config os-refresh-config os-apply-config for heat
    #these packages should make it into debian 9+
    if [ "$ID" == "ubuntu" ] && [ "$VERSION_ID" == "14.04" ]; then
        #packages are not available for Ubuntu 14.04, but depdendencies are.
        apt-get -qq --no-install-recommends -y install python-anyjson \
            python-eventlet python-iso8601 python-keystoneclient python-lxml \
            python-oslo.config python-pbr python-pystache python-requests \
            python-six
        wget http://mirror.internode.on.net/pub/ubuntu/ubuntu/pool/universe/p/python-os-collect-config/python-os-collect-config_0.1.15-1_all.deb
        wget http://mirror.internode.on.net/pub/ubuntu/ubuntu/pool/universe/p/python-os-refresh-config/python-os-refresh-config_0.1.2-1_all.deb
        wget http://mirror.internode.on.net/pub/ubuntu/ubuntu/pool/universe/p/python-os-apply-config/python-os-apply-config_0.1.14-1_all.deb
        dpkg -i python-os-apply-config_0.1.14-1_all.deb \
                python-os-refresh-config_0.1.2-1_all.deb \
                python-os-collect-config_0.1.15-1_all.deb
    elif [ "$ID" == "ubuntu" ]; then
        apt-get -qq --noinstall-recommends -y python-os-collect-config \
            python-os-refresh-config python-os-apply-config
    fi

}

# Test OS
if [ -f /etc/os-release ]; then
    source /etc/os-release
fi

# Debian Wheezy required backports for cloud-init
if [ "$ID" == "debian" ] && [ "$VERSION_ID" == "7" ]; then
    echo 'deb http://ftp.debian.org/debian wheezy-backports main' >> /etc/apt/sources.list
fi

apt-get -qq -y update
apt-get -qq -y install cloud-utils cloud-init cloud-initramfs-growroot bash-completion


heat-cfntools
os-config

# use our specific config
mv -f /tmp/cloud.cfg /etc/cloud/cloud.cfg
# remove distro installed package to ensure Ec2 is only enabled
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
