#!/bin/bash

# Clean up leftover build files
echo "Cleaning up Ansible build files..."
rm -frv /home/*/{.ssh,.ansible,.cache} /root/{.ssh,.ansible,.cache} /root/'~'*

# Clean up any default users
echo "Cleaning up default users..."
for U in ec2-user debian fedora ubuntu rocky almalinux; do
    if id $U &>/dev/null; then
        echo "Cleaning up user: $U"
        userdel -rf $U || true
    fi
done

# Truncate any log files
find /var/log -type f -print0 | xargs -0 truncate -s0

# Truncate resolv.conf if it exists
# https://bugs.centos.org/view.php?id=14369
truncate -c -s 0 /etc/resolv.conf

# Set all of the remaining disk space to zeros
dd if=/dev/zero of=/EMPTY bs=1M || true
rm -f /EMPTY

sync
