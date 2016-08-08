#!/bin/bash
set -x
set -e

# Delete password and lock account
sudo passwd -d root
sudo passwd -l root

# Disable password auth for SSH
sudo  sed -i -e 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/g' /etc/ssh/sshd_config
sudo sed -i -e 's/^#\?PermitRootLogin.*/PermitRootLogin without-password/g' /etc/ssh/sshd_config

# Ensure all installed packages are up-to-date
if [ -f '/etc/debian_version' ] ; then
    sudo apt-get -qq -y update
    sudo apt-get -y dist-upgrade
elif [ -f '/etc/redhat-release' ] ; then
	#prefer dnf ('dandified yum') over yum where available.
	if hash dnf 2>/dev/null; then
		sudo dnf -y clean all
		sudo dnf -y makecache
		sudo dnf -y upgrade
	else
        sudo yum -y clean all
        sudo yum -y makecache
        sudo yum -y upgrade || true  # Returns non-zero code on Fedora 23
	fi
elif [ -f '/etc/SuSE-release' ] ; then
    sudo zypper -q -n ref
    sudo zypper -n dup
fi
