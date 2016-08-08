#!/bin/bash
set -x
set -e

#prefer dnf over yum if available
if hash dnf 2>/dev/null; then
  INSTALL='dnf'
else
  INSTALL='yum'
fi


# Clean up udev rules to prevent incrementing network card IDs
if [ -f /etc/udev/rules.d/70-persistent-net.rules ]; then
    sudo rm /etc/udev/rules.d/70-persistent-net.rules
    sudo touch /etc/udev/rules.d/70-persistent-net.rules
fi

[ -d /dev/.udev ] && sudo rm -rf /dev/.udev

# Empty log files on the VM
sudo find /var/log -type f -exec bash -c 'cat /dev/null > {}' \;

# Remove SSH host keys
sudo rm -f /etc/ssh/*key*

# Debian based distros
if [ -f /etc/debian_version ]; then
    # Removing leftover dhcp lease
    sudo rm /var/lib/dhcp*/*

    # Remove resolvconf package
    DEBIAN_FRONTEND=noninteractive apt-get -y remove resolvconf
    sudo echo "pre-up sleep 5" >> /etc/network/interfaces

    # Remove all kernels except the current version
    sudo dpkg-query -l 'linux-image-[0-9]*' | grep ^ii | awk '{print $2}' | \
        grep -v $(uname -r) | xargs -r sudo apt-get -y remove

    # Clean apt
    sudo apt-get -q -y autoremove
    sudo apt-get -q -y autoclean
    sudo apt-get -q -y clean all
fi

# RedHat based distros
if [ -f /etc/redhat-release ]; then
    # Remove install logs
    rm -f anaconda* install.log*

    # Remove hardware specific settings from eth0
    sudo sed -i -e 's/^\(HWADDR\|UUID\|IPV6INIT\|NM_CONTROLLED\|MTU\).*//;/^$/d' \
        /etc/sysconfig/network-scripts/ifcfg-eth0

    # Remove all kernels except the current version
    rpm -qa | grep ^kernel-[0-9].* | sort | grep -v $(uname -r) | \
        xargs -r ${INSTALL} -y remove

    # Clean yum
    ${INSTALL} -y clean all
fi

# Remove cloud-init files
sudo rm -fr /var/lib/cloud/*
