#!/bin/bash

# Source testing framework
source $(dirname $0)/assert.sh

echo ""
echo "================================================================================="
echo "                                 Running Tests                                   "
echo "================================================================================="
echo ""

### I/O scheduler is none/noop
assert_raises "test \"cat /sys/block/*/queue/scheduler | grep -qEv '(none|[noop])'\""
assert_end "Check that none/noop I/O scheduler in use"

### Ephemeral disk checking
skip_if "test ! -b /dev/vdb" # skip is doesn't exist
assert_raises "grep '/dev/vdb.*ext4.*rw' /proc/mounts"
assert_end "Check that ephemeral disk is ext4 and read-write mounted on vdb"

### Root disk resized
assert "test $(lsblk --output MOUNTPOINT,SIZE | sed -n -e 's/^\/\s\+\([0-9]\+\)G/\1/p') -gt 4"
assert_end "Root filesystem resized"

### Serial console set in right order
assert_raises "grep 'console=tty0 console=ttyS0,115200n8' /boot/grub*/grub.c*f*"
assert_end "Kernel console log configured correctly"

### Default interface is eth0
assert "/sbin/ip route | grep -E 'default via .* dev eth0'"
assert_end "Default route via interface named eth0"

### Fail2ban
assert_raises "pgrep fail2ban"
assert_end "Fail2ban is running"

### heat-cfntools
assert_raises "which cfn-create-aws-symlinks cfn-get-metadata cfn-push-stats cfn-hup cfn-init cfn-signal"
assert_end "heat-cfntools are installed"

### No default passwords
assert_raises "test \"$(sudo cut -d ':' -f 2 /etc/shadow | cut -d '$' -sf3)\" = ''"
assert_end "No default passwords exist"

### NTP running
assert_raises "pgrep ntp"
assert_end "NTP service is running"

### SSH key for root
assert "sudo wc -l /root/.ssh/authorized_keys | cut -d ' ' -f1" 1
assert_end "Single SSH authorized key for root exists"

### SSH key for current user
assert "wc -l ~/.ssh/authorized_keys | cut -d ' ' -f1" 1
assert_end "Single SSH authorized key for current user exists"

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
