#!/bin/bash
set -x

# Install RDO
# See https://repos.fedorapeople.org/repos/openstack/openstack-juno/ and
# https://github.com/redhat-openstack/rdo-release/blob/master/rdo-release.spec
DIST=f
RELEASEVER=$(sed -e 's/.*release \([0-9]\+\).*/\1/' /etc/redhat-release)
if ! grep -qFi 'fedora' /etc/redhat-release; then
    DIST=el
fi

# Kilo repo only available for CentOS 7 and Fedora 20-21
# This repo is now only required for heat-cfntools
# Fedora 23 doesn't need an extra repo for heat-cfntools
case ${RELEASEVER} in
    7|21|22)

        cat > /etc/yum.repos.d/rdo-release.repo << EOM
[openstack-kilo]
name=OpenStack Kilo Repository
baseurl=http://repos.fedorapeople.org/repos/openstack/openstack-kilo/${DIST}${RELEASEVER}/
enabled=1
gpgcheck=0
EOM
        ;;
    *)
        echo Not creating rdo-release repo
        ;;
esac

# Install cloud packages
yum -q -y update
yum -q -y install cloud-init cloud-utils cloud-utils-growpart dracut-modules-growroot

# Only allow SSH service after cloud-init for systemd distros
#if [ $RELEASEVER -eq 7 ] || [ $RELEASEVER -ge 20 ]; then
#    FILE=/usr/lib/systemd/system/cloud-init.service
#    sed -i '/^Wants/s/$/ sshd.service/' $FILE
#    grep -q Before $FILE && sed -i '/Before/s/$/ sshd.service/' $FILE ||  sed -i '/[Unit]/aBefore=sshd.service' $FILE
#fi

# Move our cloud config into place
[ -f /tmp/cloud.cfg ] && mv /tmp/cloud.cfg /etc/cloud/cloud.cfg

# Install heat-cfntools if RDO is set up
yum -y install heat-cfntools

dracut -f

# Common kernel args
KERNEL_ARGS="elevator=noop console=ttyS0,115200n8 console=tty0 consoleblank=0 net.ifnames=0 biosdevname=0"

# Add our Grub kernel args for OpenStack
grubby --update-kernel=ALL --remove-args="rhgb quiet"
grubby --update-kernel=ALL --args="$KERNEL_ARGS"

# Make sure sudo works properly with openstack
sed -i "s/^.*requiretty$/Defaults !requiretty/" /etc/sudoers
