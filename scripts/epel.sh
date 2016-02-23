#!/bin/bash
set -x
set -e

RELEASEVER=$(sed -e 's/.*release \([0-9]\+\).*/\1/' /etc/redhat-release)
# add epel repo
cat > /etc/yum.repos.d/epel.repo << EOM
[epel]
name=epel
baseurl=http://dl.fedoraproject.org/pub/epel/${RELEASEVER}/\$basearch
enabled=1
gpgcheck=0
EOM

