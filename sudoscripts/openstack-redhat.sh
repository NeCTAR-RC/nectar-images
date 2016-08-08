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

#prefer dnf over yum if available
if hash dnf 2>/dev/null; then
  INSTALL='dnf'
else
  INSTALL='yum'
fi




# Kilo repo only available for CentOS 7 and Fedora 20-21
# This repo is now only required for heat-cfntools
# Fedora 23+ doesn't need an extra repo for heat-cfntools
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

# Install cloud package
sudo ${INSTALL} -y install cloud-init

# Try and install these, but don't die is they fail
sudo ${INSTALL} -y install dracut-modules-growroot cloud-initramfs-tools \
       cloud-utils-growpart cloud-utils heat-cfntools || true

# Move our cloud config into place
[ -f /tmp/cloud.cfg ] && sudo mv /tmp/cloud.cfg /etc/cloud/cloud.cfg

# Make sure cloud init is enabled for systemd
if which systemctl >/dev/null 2>&1; then
    for SERVICE in cloud-config cloud-final cloud-init cloud-init-local; do
        sudo systemctl enable $SERVICE
    done
fi

# Common kernel args
KERNEL_ARGS="console=tty0 console=ttyS0,115200n8 vga=788 consoleblank=0"

if [ $RELEASEVER -eq 5 ]; then
    # CentOS 5 cloud-init does not create initial user
    sudo /usr/sbin/useradd -G adm,wheel -m -d /home/ec2-user -s /bin/bash ec2-user
    sudo /bin/echo '# User rules for ec2-user' >> /etc/sudoers
    sudo /bin/echo 'ec2-user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
else
    # CentOS 6 and greater
    sudo dracut -f
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

# Add our Grub kernel args for OpenStack
sudo grubby --update-kernel=ALL --remove-args="rhgb quiet"
sudo grubby --update-kernel=ALL --args="$KERNEL_ARGS"

# Make sure sudo works properly with openstack
sudo sed -i "s/^.*requiretty$/Defaults !requiretty/" /etc/sudoers
