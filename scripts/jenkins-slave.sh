#!/bin/bash
set -x
set -e

add-apt-repository cloud-archive:liberty

apt-get update
apt-get install -y openjdk-7-jdk rake ruby-puppetlabs-spec-helper puppet-lint git bundler python-dev libssl-dev libxml2-dev libxslt-dev python-tox python-pip build-essential libmysqlclient-dev libfreetype6-dev libpng12-dev git-buildpackage debhelper dupload libffi-dev npm nodejs libpq-dev unzip qemu pkg-config libvirt-dev libsqlite3-dev libldap2-dev libsasl2-dev
apt-get install -y --force-yes dh-systemd openstack-pkg-tools python-sphinx python3-setuptools libcurl3 python-ceilometerclient python-cinderclient python-designateclient python-glanceclient python-heatclient python-keystoneclient python-muranoclient python-neutronclient python-novaclient python-openstackclient python-swiftclient python-hivemind python-hivemind-contrib

apt-get -qq -y autoremove
apt-get -qq -y autoclean
apt-get -qq -y clean
