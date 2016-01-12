#!/bin/bash
set -x
set -e

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
case $RELEASEVER in
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
yum -y install cloud-init cloud-utils heat-cfntools

# Try and install these, but don't die is they fail
yum -y install dracut-modules-growroot cloud-initramfs-tools cloud-utils-growpart || true

# Move our cloud config into place
[ -f /tmp/cloud.cfg ] && mv /tmp/cloud.cfg /etc/cloud/cloud.cfg

# Make sure cloud init is enabled for systemd
if which systemctl >/dev/null 2>&1; then
    for SERVICE in cloud-config cloud-final cloud-init cloud-init-local; do
        systemctl enable $SERVICE
    done
fi

dracut -f

# Common kernel args
KERNEL_ARGS="elevator=noop console=ttyS0,115200n8 console=tty0 consoleblank=0 net.ifnames=0 biosdevname=0"

# Add our Grub kernel args for OpenStack
grubby --update-kernel=ALL --remove-args="rhgb quiet"
grubby --update-kernel=ALL --args="$KERNEL_ARGS"

# Make sure sudo works properly with openstack
sed -i "s/^.*requiretty$/Defaults !requiretty/" /etc/sudoers
