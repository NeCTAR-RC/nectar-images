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
        cat > /etc/yum.repos.d/CentOS-OpenStack-kilo.repo << EOM
[centos-openstack-kilo]
name=CentOS-\$releasever - OpenStack kilo
baseurl=http://mirror.centos.org/centos/\$releasever/cloud/\$basearch/openstack-kilo/
gpgcheck=0
enabled=1
EOM
        ;;
    *)
        echo "OpenStack package repository not required for $RELEASEVER"
        ;;
esac

if hash dnf 2>/dev/null; then
    RH_INSTALL=dnf
else
    RH_INSTALL=yum
fi
# Install cloud package
"${RH_INSTALL}" -y install cloud-init

# Try and install these, but don't die is they fail
"${RH_INSTALL}" -y install dracut-modules-growroot cloud-initramfs-tools \
       cloud-utils-growpart cloud-utils heat-cfntools || true

# Remove repo after package installation
rm -f /etc/yum.repos.d/CentOS-OpenStack-kilo.repo

# Move our cloud config into place
[ -f /tmp/cloud.cfg ] && mv /tmp/cloud.cfg /etc/cloud/cloud.cfg
# Move nectar testing directory into place
[ -d /tmp/testing ] && mv /tmp/testing/* /var/lib/packer/build

# Make sure cloud init is enabled for systemd
if which systemctl >/dev/null 2>&1; then
    for SERVICE in cloud-config cloud-final cloud-init cloud-init-local; do
        systemctl enable $SERVICE
    done
fi

# Common kernel args
KERNEL_ARGS="console=tty0 console=ttyS0,115200n8 vga=788 consoleblank=0"

if [ $RELEASEVER -eq 5 ]; then
    # CentOS 5 cloud-init does not create initial user
    /usr/sbin/useradd -G adm,wheel -m -d /home/ec2-user -s /bin/bash ec2-user
    /bin/echo '# User rules for ec2-user' >> /etc/sudoers
    /bin/echo 'ec2-user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
else
    # CentOS 6 and greater
    KERNEL_ARGS="$KERNEL_ARGS net.ifnames=0 biosdevname=0"
fi

if [ $RELEASEVER -lt 7 ]; then
    # elevator=noop only required for older distros
    KERNEL_ARGS="$KERNEL_ARGS elevator=noop"
fi

# Only works in very recent systemd
if [ $RELEASEVER -gt 22 ]; then
  KERNEL_ARGS="$KERNEL_ARGS systemd.log_color=no"
fi

if [ $RELEASEVER -gt 23 ]; then
  BOOTLOADER="--extlinux"
else
  BOOTLOADER=""
fi

# Add our Grub kernel args for OpenStack

grubby ${BOOTLOADER} --update-kernel=ALL --remove-args="rhgb quiet" \
    --args="$KERNEL_ARGS"

# Make sure sudo works properly with openstack
sed -i "s/^.*requiretty$/Defaults !requiretty/" /etc/sudoers
