#!/bin/bash
set -x

# Delete password and lock account
passwd -d root
passwd -l root

# Disable password auth for SSH
sed -i -e 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i -e 's/^#\?PermitRootLogin.*/PermitRootLogin without-password/g' /etc/ssh/sshd_config
