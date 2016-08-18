#!/bin/bash
set -x
set -e

# Clean up udev rules to prevent incrementing network card IDs
if [ -f /etc/udev/rules.d/70-persistent-net.rules ]; then
    rm /etc/udev/rules.d/70-persistent-net.rules
    touch /etc/udev/rules.d/70-persistent-net.rules
fi

[ -d /dev/.udev ] && rm -rf /dev/.udev

# Empty log files on the VM
find /var/log -type f -exec bash -c 'cat /dev/null > {}' \;

# Remove SSH host keys
rm -f /etc/ssh/*key*
# Remove root's .ssh dir, to be recreated by cloud-init
rm -rf /root/.ssh || true


# Debian based distros
if [ -f /etc/debian_version ]; then

    # Fix for: Ignoring file '20auto-upgrades.ucf-dist' in directory
    # '/etc/apt/apt.conf.d/' as it has an invalid filename extension
    rm /etc/apt/apt.conf.d/*.ucf-dist

    # Removing leftover dhcp lease
    rm /var/lib/dhcp*/*

    # Remove resolvconf package
    DEBIAN_FRONTEND=noninteractive apt-get -y remove resolvconf
    echo "pre-up sleep 5" >> /etc/network/interfaces

    # Remove all kernels except the current version
    dpkg-query -l 'linux-image-[0-9]*' | grep ^ii | awk '{print $2}' | \
        grep -v $(uname -r) | xargs -r apt-get -y remove

    # Clean apt
    apt-get -q -y autoremove
    apt-get -q -y autoclean
    apt-get -q -y clean all
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

    # Clean yum/dnf
    if hash dnf 2>/dev/null; then
        dnf -y clean all
    else
        yum -y clean all
    fi
fi

# Remove cloud-init files
rm -fr /var/lib/cloud/*

#Remove ssh keys from current user The user's key should be injected by
#cloud-init on boot.
truncate -s0 ${HOME}/.ssh/authorized_keys
