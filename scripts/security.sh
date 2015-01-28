#!/bin/bash
set -x

# Delete password and lock account
passwd -d root
passwd -l root

if [ -f /etc/debian_version ]; then
    apt-get -qq -y install fail2ban
    sed -i 's/banaction = iptables-multiport/banaction = hostsdeny/' /etc/fail2ban/jail.conf
fi

# Disable password auth for SSH
sed -i -e 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i -e 's/^#\?PermitRootLogin.*/PermitRootLogin without-password/g' /etc/ssh/sshd_config
