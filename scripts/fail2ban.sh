#!/bin/bash
set -x

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
if [ "$ID" == "centos" ] || [ "$ID" == "fedora" ] || [ "$ID" == "scientific linux" ]; then
    yum -q -yy install fail2ban

    # Make our jail.d directory if doesn't exist
    [ -d /etc/fail2ban/jail.d ] || mkdir /etc/fail2ban/jail.d

    # On newer distros, remove the firewalld package and the fail2ban
    # empty meta-package too. We'll provide our own config
    if rpm -q fail2ban-firewalld &>/dev/null; then 
        rpm -e fail2ban fail2ban-firewalld
    fi

    # CentOS 7, Fedora 20+
    if [ $VERSION_ID -eq 7 ] || [ $VERSION_ID -ge 20 ]; then
        cat > /etc/fail2ban/jail.d/00-hostdeny.conf << EOF
# NeCTAR: use hostsdeny by default
[DEFAULT]
banaction = hostsdeny
EOF

        cat > /etc/fail2ban/jail.d/01-sshd.conf << EOF
# NeCTAR: enable SSH jail
[sshd]
enabled = true
EOF

    # Enable service
    systemctl enable fail2ban

    # CentOS 6
    elif [ $VERSION_ID -eq 6 ]; then
        cat > /etc/fail2ban/jail.d/01-ssh-iptables.conf << EOF
# NeCTAR doesn't use iptables by default
[ssh-iptables]
enabled = false
EOF

        cat > /etc/fail2ban/jail.d/02-ssh-tcpwrapper.conf << EOF
# NeCTAR: use tcpwrapper SSH
[ssh-tcpwrapper]
enabled     = true
filter      = sshd
action      = hostsdeny[daemon_list=sshd]
logpath     = /var/log/secure
EOF

    # Enable service
    chkconfig --add fail2ban

    fi

#
# Debian 7
#
elif [ "$ID" == "debian" ]; then

    # Install fail2ban package
    apt-get -qq -y install fail2ban

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

#
# Ubuntu 14.04+
#
elif [ "$ID" == "ubuntu" ]; then

    # Install fail2ban package
    apt-get -qq -y install fail2ban

    cat > /etc/fail2ban/jail.d/00-hostsdeny.conf << EOF
# NeCTAR: use hostsdeny by default
[DEFAULT]
banaction = hostsdeny
EOF

    cat > /etc/fail2ban/jail.d/01-ssh.conf << EOF
# NeCTAR: enable SSH jail
[ssh]
enabled = true
EOF

#
# OpenSuSE 13.2
#
elif [ "$ID" == "opensuse" ]; then
    # Install fail2ban package
    zypper -n --no-gpg-checks install fail2ban

    # Enable service
    systemctl enable fail2ban
    
    # Make our jail.d directory if doesn't exist
    [ -d /etc/fail2ban/jail.d ] || mkdir /etc/fail2ban/jail.d

    cat > /etc/fail2ban/jail.d/01-ssh-iptables.conf << EOF
# NeCTAR doesn't use iptables by default
[ssh-iptables]
enabled = false
EOF

    cat > /etc/fail2ban/jail.d/02-ssh-tcpwrapper.conf << EOF
# NeCTAR: use tcpwrapper SSH
[ssh-tcpwrapper]
enabled     = true
EOF
fi


# Some new distros don't ship the hostsdeny action
if [ ! -e /etc/fail2ban/action.d/hostsdeny.conf ]; then
    cat > /etc/fail2ban/action.d/hostsdeny.conf << EOF
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
