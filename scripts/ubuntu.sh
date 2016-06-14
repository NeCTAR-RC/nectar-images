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
