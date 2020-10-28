#!/bin/bash -x

# Clean up leftover build files
rm -fr /home/*/{.ssh,.ansible,.cache}
rm -fr /root/{.ssh,.ansible,.cache}
rm -fr /root/'~'*

# Clean up any default users
userdel -rf ec2-user || true
userdel -rf debian || true
userdel -rf fedora || true
userdel -rf ubuntu || true

# Truncate any log files
find /var/log -type f -print0 | xargs -0 truncate -s0

dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY
sync
