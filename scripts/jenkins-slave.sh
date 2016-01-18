#!/bin/bash
set -x
set -e

add-apt-repository cloud-archive:liberty

apt-get -qq -y update
apt-get -qq -y install openjdk-7-jdk rake ruby-puppetlabs-spec-helper puppet-lint git bundler python-dev libssl-dev libxml2-dev libxslt-dev build-essential libmysqlclient-dev libfreetype6-dev libpng12-dev git-buildpackage debhelper dupload libffi-dev npm nodejs libpq-dev unzip qemu pkg-config libvirt-dev libsqlite3-dev libldap2-dev libsasl2-dev python-pip
apt-get -qq -y install dh-systemd openstack-pkg-tools python-sphinx python3-setuptools libcurl3 python-ceilometerclient python-cinderclient python-designateclient python-glanceclient python-heatclient python-keystoneclient python-muranoclient python-neutronclient python-novaclient python-openstackclient python-swiftclient

apt-get -qq -y autoremove
apt-get -qq -y autoclean
apt-get -qq -y clean

# Needed to build Liberty on Trusty
pip install --upgrade 'pip==7.1.2' 'virtualenv==13.1.2' 'setuptools==19.4' 'pbr==1.8.1' 'tox==2.3.1'

# Install packer
PACKER_VER=0.8.6
PACKER_FILE="packer_${PACKER_VER}_linux_amd64.zip"
wget -q https://releases.hashicorp.com/packer/$PACKER_VER/$PACKER_FILE -O /tmp/$PACKER_FILE
unzip /tmp/$PACKER_FILE -d /usr/local/bin/
rm /tmp/$PACKER_FILE
