#!/bin/bash

# Source testing framework
source $(dirname $0)/assert.sh

echo ""
echo "================================================================================="
echo "                                 Running Tests                                   "
echo "================================================================================="
echo ""

if [ -f /etc/os-release ]; then
    . /etc/os-release
elif [ -f /etc/redhat-release ]; then
    NAME=$(sed -e 's/\(.*\)release\? \([0-9]\+\).*/\1/' /etc/redhat-release)
    ID=$(echo $NAME | tr '[:upper:]' '[:lower:]')
    VERSION_ID=$(sed -e 's/.*release\? \([0-9]\+\).*/\1/' /etc/redhat-release)
else
    echo "Disto ID check fail"
    exit 1
fi

### I/O scheduler is none/noop
assert "grep -Ev '(none|\[noop\])' /sys/block/*/queue/scheduler" ''
assert_end "Check that none/noop I/O scheduler in use"

### Ephemeral disk checking
skip_if "test ! -b /dev/vdb" # skip is doesn't exist
assert_raises "grep '/dev/vdb.*ext4.*rw' /proc/mounts"
assert_end "Check that ephemeral disk is ext4 and read-write mounted on vdb"

### Root disk resized
assert_raises "test $(df -P -BG / | tail -n1 | awk '{print $2}' | sed -n 's/^\([0-9]\+\)G/\1/p') -gt 4"
assert_end "Root filesystem resized"

### Serial console set in right order
assert_raises "grep -E 'console=tty0\s.*console=ttyS0' /proc/cmdline"
assert_end "Kernel console log configured correctly"

### Default interface is eth0
assert_raises "/sbin/ip route | grep -E 'default via.*dev eth0'"
assert_end "Default route via interface named eth0"

### Fail2ban
skip_if "test -z $(which fail2ban-server 2>/dev/null)" # only run test if installed
assert_raises "pgrep fail2ban"
assert_end "fail2ban is running"

### heat-cfntools for everything except CentOS 5
skip_if "test \"$ID\" = \"centos\" -a $VERSION_ID -lt 6"
assert_raises "which cfn-create-aws-symlinks cfn-get-metadata cfn-push-stats cfn-hup cfn-init cfn-signal"
assert_end "heat-cfntools are installed"

### No default passwords
assert "sudo cut -d ':' -f 2 /etc/shadow | cut -d '$' -sf3" ''
assert_end "No default passwords exist"

### NTP running
assert_raises "pgrep -f 'ntp|chronyd|systemd-timesyncd'"
assert_end "NTP, chrony or systemd-timesyncd service is running"

### SSH key for root (populated by cloud-init)
assert "sudo wc -l /root/.ssh/authorized_keys | cut -d ' ' -f1" 1
assert_end "Single SSH authorized key for root exists"

### SSH key for current user (populated by cloud-init)
assert "wc -l ~/.ssh/authorized_keys | cut -d ' ' -f1" 1
assert_end "Single SSH authorized key for current user exists"

### Only one user home directory
assert_raises "test $(find /home -mindepth 1 -maxdepth 1 -type d | wc -l) -eq 1"
assert_end "Single home directory exists in /home"

### Package repos
if hash zypper 2>/dev/null; then
    assert_raises "sudo zypper --gpg-auto-import-keys refresh"
    assert_raises "sudo zypper clean"
    assert_end "Package repositories are OK"
elif hash dnf 2>/dev/null; then
    assert_raises "sudo dnf makecache"
    assert_raises "sudo dnf clean all"
    assert_end "Package repositories are OK"
elif hash yum 2>/dev/null; then
    assert_raises "sudo yum makecache"
    assert_raises "sudo yum clean all"
    assert_end "Package repositories are OK"
elif hash apt-get 2>/dev/null; then
    assert_raises "sudo apt-get update"
    assert_raises "sudo apt-get -y clean all"
    assert_end "Package repositories are OK"
fi

echo ""
echo "================================================================================="
echo "                                Tests Complete                                   "
echo "================================================================================="
echo ""
