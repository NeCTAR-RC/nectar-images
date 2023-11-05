#!/bin/bash -x

# Clean up leftover build files
rm -fr /home/*/{.ssh,.ansible,.cache}
rm -fr /root/{.ssh,.ansible,.cache}
rm -fr /root/'~'*

# Clean up any default users
for U in ec2-user debian fedora ubuntu rocky almalinux; do
  userdel -rf $U || true
done

# Truncate any log files
find /var/log -type f -print0 | xargs -0 truncate -s0

# Truncate resolv.conf if it exists
# https://bugs.centos.org/view.php?id=14369
truncate -c -s 0 /etc/resolv.conf

dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY
sync
