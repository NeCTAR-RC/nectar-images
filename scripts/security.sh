#!/bin/bash
set -x
set -e

# Delete password and lock account
passwd -d root
passwd -l root

# Disable password auth for SSH
sed -i -e 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i -e 's/^#\?PermitRootLogin.*/PermitRootLogin without-password/g' /etc/ssh/sshd_config

# Ensure all installed packages are up-to-date
if [ -f '/etc/debian_version' ] ; then
    apt-get -qq -y update
    apt-get -y dist-upgrade
elif [ -f '/etc/redhat-release' ] ; then
    yum -y clean all
    yum -q -y makecache
    yum -y upgrade
elif [ -f '/etc/SuSE-release' ] ; then
    zypper -q -n ref
    zypper -n dup
fi
