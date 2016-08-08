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
    #prefer dnf ('dandified yum') over yum where available.
    if hash dnf 2>/dev/null; then
        RH_INSTALL=dnf
    else
        RH_INSTALL=yum
    fi
    "${RH_INSTALL}" -y clean all
    "${RH_INSTALL}" -y makecache
    "${RH_INSTALL}" -y upgrade
elif [ -f '/etc/SuSE-release' ] ; then
    zypper -q -n ref
    zypper -n dup
fi
