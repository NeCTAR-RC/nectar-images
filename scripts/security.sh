#!/bin/bash
set -x

# Randomise the root password, then lock
PASS=$(tr -dc A-Za-z0-9 < /dev/urandom | head -c10)
echo "Setting root password: $PASS"
echo "root:$PASS" | chpasswd
#passwd -l root
#passwd -d root

if [ -f /etc/debian_version ]; then
    sed -i 's/banaction = iptables-multiport/banaction = hostsdeny/' /etc/fail2ban/jail.conf
fi

# SSH config
sed -i -e 's/^PasswordAuthentication yes.*/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i -e 's/^PermitRootLogin yes.*/PermitRootLogin no/g' /etc/ssh/sshd_config
