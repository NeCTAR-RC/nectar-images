#!/bin/bash -xe

if hash zypper 2>/dev/null; then
    # openSUSE
    zypper --gpg-auto-import-keys refresh
    zypper -n install python
elif hash dnf 2>/dev/null; then
    # Fedora
    dnf -q -y install python libselinux-python python2-dnf
elif hash yum 2>/dev/null; then
    # CentOS/Scientific Linux
    yum -q -y install python libselinux-python sudo
elif hash apt-get 2>/dev/null; then
    # Debian/Ubuntu
    apt-get -q -y update
    apt-get -q -y install python-apt sudo
fi

