#!/bin/bash
set -x
set -e

# Test OS
if [ -f /etc/os-release ]; then
    source /etc/os-release
fi

if [ "$VERSION_ID" == "14.04" ]; then
    # Cloud archive for Trusty
    add-apt-repository cloud-archive:liberty

    # For Freshdesk integration
    apt-key adv --keyserver keyserver.ubuntu.com --recv 68576280
    apt-add-repository "deb https://deb.nodesource.com/node_4.x $(lsb_release -sc) main"
fi

apt-get -q -y update

# OpenJDK 7 on Trusty and OpenJDK 8 for Xenial
apt-get -q -y install default-jdk

apt-get -q -y install rake ruby-puppetlabs-spec-helper puppet-lint git bundler python-dev python3-dev libssl-dev libxml2-dev libxslt-dev build-essential libmysqlclient-dev libfreetype6-dev libpng12-dev git-buildpackage debhelper dupload libffi-dev libpq-dev unzip qemu pkg-config libvirt-dev libsqlite3-dev libldap2-dev libsasl2-dev python-pip

apt-get -q -y install dh-systemd openstack-pkg-tools python-sphinx python3-setuptools libcurl3 python-ceilometerclient python-cinderclient python-designateclient python-glanceclient python-heatclient python-keystoneclient python-muranoclient python-neutronclient python-novaclient python-openstackclient python-swiftclient

# For Freshdesk integration
apt-get -q -y install nodejs nodejs-legacy libkrb5-dev

if [ "$VERSION_ID" == "16.04" ]; then
    apt-get -q -y install virtualenv python3-virtualenv tox
fi

# Clean up
apt-get -q -y autoremove
apt-get -q -y autoclean
apt-get -q -y clean

if [ "$VERSION_ID" == "14.04" ]; then
    # Needed to build Liberty on Trusty
    pip install --upgrade 'pip==7.1.2' 'virtualenv==13.1.2' 'setuptools==19.4' 'pbr==1.8.1' 'tox==2.3.1'
fi

# Install packer
PACKER_VER=0.8.6
PACKER_FILE="packer_${PACKER_VER}_linux_amd64.zip"
wget -q https://releases.hashicorp.com/packer/$PACKER_VER/$PACKER_FILE -O /tmp/$PACKER_FILE
unzip /tmp/$PACKER_FILE -d /usr/local/bin/
rm /tmp/$PACKER_FILE
