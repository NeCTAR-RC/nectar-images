#!/bin/bash
set -x

# Clean up udev rules to prevent incrementing network card IDs
echo "cleaning up udev rules"
rm /etc/udev/rules.d/7*-persistent-net*.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
ln -s /dev/null /etc/udev/rules.d/80-net-name-slot.rules

# Remove log files from the VM
find /var/log -type f -exec rm -f {} \;

# Remove SSH host keys
rm -f /etc/ssh/*key*

# Debian based distros
if [ -f /etc/debian_version ]; then
    # Removing leftover leases and persistent rules
    echo "cleaning up dhcp leases"
    rm /var/lib/dhcp3/*
    # remove annoying resolvconf package
    DEBIAN_FRONTEND=noninteractive apt-get -y remove resolvconf
    echo "Adding a 3 sec delay to the interface up, to make the dhclient and cloud-init happy"
    echo "pre-up sleep 5" >> /etc/network/interfaces
    # Remove all kernels except the current version
    dpkg-query -l 'linux-image-[0-9]*' | grep ^ii | awk '{print $2}' | \
        grep -v $(uname -r) | xargs -r apt-get -y remove
    apt-get -y clean all
fi

# RedHat based distros
if [ -f /etc/redhat-release ]; then
    # Remove install logs
    rm -f anaconda* install.log*
    # Remove hardware specific settings from eth0
    sed -i -e 's/^\(HWADDR\|UUID\|IPV6INIT\|NM_CONTROLLED\|MTU\).*//;/^$/d' \
        /etc/sysconfig/network-scripts/ifcfg-eth0
    # Remove all kernels except the current version
    rpm -qa | grep ^kernel-[0-9].* | sort | grep -v $(uname -r) | \
        xargs -r yum -y remove
    # Clean yum
    yum -y clean all
fi
