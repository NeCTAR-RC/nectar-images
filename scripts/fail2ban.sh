#!/bin/bash
set -x
set -e

if [ -f /etc/os-release ]; then
    source /etc/os-release
elif [ -f /etc/redhat-release ]; then
    NAME=$(sed -e 's/\(.*\)release\? \([0-9]\+\).*/\1/' /etc/redhat-release)
    ID=$(echo $NAME | tr '[:upper:]' '[:lower:]')
    VERSION_ID=$(sed -e 's/.*release\? \([0-9]\+\).*/\1/' /etc/redhat-release)
else
    NAME=Unknown
    ID=Unknown
    VERSION_ID=Unknown
fi

#
# RedHat based distros
#

if hash dnf 2>/dev/null; then
    RH_INSTALL=dnf
else
    RH_INSTALL=yum
fi

case "${ID}" in
    centos|rhel|fedora|scientific\ linux)

    ${RH_INSTALL} -q -yy install fail2ban ed

    # Make our jail.d directory if doesn't exist
    [ -d /etc/fail2ban/jail.d ] || mkdir /etc/fail2ban/jail.d

    # On newer distros, remove the firewalld package and the fail2ban
    # empty meta-package too. We'll provide our own config
    if rpm -q fail2ban-firewalld &>/dev/null; then
        rpm -e fail2ban fail2ban-firewalld
    fi

    # CentOS 7, Fedora 20+
    if [ $VERSION_ID -eq 7 ] || [ $VERSION_ID -ge 20 ]; then

        if [ "$ID" == "fedora" ]; then
            # Fedora 20+ has SSH logs in systemd
            "${RH_INSTALL}" -q -yy install fail2ban-systemd
        fi

        cat > /etc/fail2ban/jail.d/00-hostdeny.conf << EOF
# use hostsdeny by default
[DEFAULT]
banaction = hostsdeny
EOF

        cat > /etc/fail2ban/jail.d/01-sshd.conf << EOF
# enable SSH jail
[sshd]
enabled = true
EOF

        # Enable service
        systemctl enable fail2ban

    # CentOS 6
    elif [ $VERSION_ID -eq 6 ]; then
        cat > /etc/fail2ban/jail.d/01-ssh-iptables.conf << EOF
# don't use iptables by default
[ssh-iptables]
enabled = false
EOF

        cat > /etc/fail2ban/jail.d/02-ssh-tcpwrapper.conf << EOF
# use tcpwrapper SSH
[ssh-tcpwrapper]
enabled     = true
filter      = sshd
action      = hostsdeny[daemon_list=sshd]
logpath     = /var/log/secure
EOF

        # Enable service
        chkconfig --add fail2ban

    fi
    ;;

#
# Debian
#
    debian)

    # Install fail2ban package
    apt-get -qq -y install fail2ban

    if [ $VERSION_ID -eq 7 ]; then
        # Debian 7 doesn't support jail.d
        cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
banaction = hostsdeny

[ssh]
enabled  = true
port     = ssh
filter   = sshd
logpath  = /var/log/auth.log
maxretry = 6
EOF
    else
        # Remove default debian config
        [ -f /etc/fail2ban/jail.d/defaults-debian.conf ] && \
            rm /etc/fail2ban/jail.d/defaults-debian.conf

        cat > /etc/fail2ban/jail.d/00-hostsdeny.conf << EOF
# use hostsdeny by default
[DEFAULT]
banaction = hostsdeny
EOF

    cat > /etc/fail2ban/jail.d/01-ssh.conf << EOF
# enable SSH jail
[ssh]
enabled = true
EOF
    fi
    ;;

#
# Ubuntu 14.04+
#
    ubuntu)

    # Install fail2ban package
    apt-get -qq -y install fail2ban

    # Remove default debian config
    [ -f /etc/fail2ban/jail.d/defaults-debian.conf ] && \
        rm /etc/fail2ban/jail.d/defaults-debian.conf

    cat > /etc/fail2ban/jail.d/00-hostsdeny.conf << EOF
# use hostsdeny by default
[DEFAULT]
banaction = hostsdeny
EOF

    if [ ${VERSION_ID%%.*} -ge 15 ]; then
        SSH_JAILNAME="sshd"
    else
        SSH_JAILNAME="ssh"
    fi

    cat > /etc/fail2ban/jail.d/01-ssh.conf << EOF
# enable SSH jail
[$SSH_JAILNAME]
enabled = true
EOF

    # Enable service
    [ -f /etc/init.d/fail2ban ] && update-rc.d fail2ban enable
    ;;
#
# OpenSuSE 13.2
#
    opensuse)
    # Install fail2ban package
    zypper -n --no-gpg-checks install fail2ban

    # Enable service
    systemctl enable fail2ban

    # Make our jail.d directory if doesn't exist
    [ -d /etc/fail2ban/jail.d ] || mkdir /etc/fail2ban/jail.d

    cat > /etc/fail2ban/jail.d/00-hostdeny.conf << EOF
# use hostsdeny by default
[DEFAULT]
banaction = hostsdeny
EOF

    cat > /etc/fail2ban/jail.d/01-sshd.conf << EOF
# enable SSH jail
[sshd]
enabled = true
EOF
    ;;
esac

# Some new distros don't ship the hostsdeny action
if [ ! -e /etc/fail2ban/action.d/hostsdeny.conf ]; then
    cat > /etc/fail2ban/action.d/hostsdeny.conf << 'EOF'
[Definition]
actionstart =
actionstop =
actioncheck =
actionban = IP=<ip> &&
            printf %%b "<daemon_list>: $IP\n" >> <file>
actionunban = echo "/^<daemon_list>: <ip>$/<br>d<br>w<br>q" | ed <file>

[Init]
file = /etc/hosts.deny
daemon_list = ALL
EOF
fi
