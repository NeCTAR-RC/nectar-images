#!/bin/bash

# Source testing framework
source $(dirname $0)/assert.sh

### Ephemeral disk checking
assert_raises "grep '/dev/vdb.*ext4.*rw' /proc/mounts"
assert_end "Check that ephemeral disk is ext4 and read-write mounted on vdb"

### Root disk resized
assert "test $(lsblk --output MOUNTPOINT,SIZE | sed -n -e 's/^\/\s\+\([0-9]\+\)G/\1/p') -gt 4"
assert_end "Root filesystem resized"

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
