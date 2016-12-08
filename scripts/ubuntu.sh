#!/bin/bash
set -x
set -e

# Get OS details
[ -f /etc/os-release ] && . /etc/os-release

# Disable apt-daily.timer from running at Boot
# http://stackoverflow.com/questions/36896806/how-can-i-be-sure-a-freshly-started-vm-is-ready-for-provisioning
if [ -f /lib/systemd/system/apt-daily.timer ]; then
    mkdir -p /etc/systemd/system/apt-daily.timer.d
    cat > /etc/systemd/system/apt-daily.timer.d/apt-daily.timer.conf << EOF
[Timer]
Persistent=false
EOF
fi

# Disable Unattended upgrades
echo '# NeCTAR disable unattended upgrades, but refresh list
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "0";' | tee /etc/apt/apt.conf.d/10periodic /etc/apt/apt.conf.d/20auto-upgrades

# Fix for: Ignoring file '20auto-upgrades.ucf-dist' in directory
# '/etc/apt/apt.conf.d/' as it has an invalid filename extension
rm -f /etc/apt/apt.conf.d/*.ucf-dist

# Disable i386 architecture. This saves time, bandwidth and diskspace
# by not updating the i386 repositories (which are typically unused)
foreign_arch=$(dpkg --print-foreign-architectures)
if [ "${foreign_arch}" == "i386" ] ; then
   dpkg --remove-architecture i386
fi
