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



#prefer dnf over yum if available
if hash dnf 2>/dev/null; then
  INSTALL='dnf'
else
  INSTALL='yum'
fi

#
# RedHat based distros
#
if [ "$ID" == "centos" ] || [ "$ID" == "fedora" ] || [ "$ID" == "scientific linux" ]; then
    sudo ${INSTALL} -q -yy install fail2ban ed

    # Make our jail.d directory if doesn't exist
    [ -d /etc/fail2ban/jail.d ] || mkdir /etc/fail2ban/jail.d

    # On newer distros, remove the firewalld package and the fail2ban
    # empty meta-package too. We'll provide our own config
    if sudo rpm -q fail2ban-firewalld &>/dev/null; then
        sudo rpm -e fail2ban fail2ban-firewalld
    fi

    # CentOS 7, Fedora 20+
    if [ $VERSION_ID -eq 7 ] || [ $VERSION_ID -ge 20 ]; then

        if [ "$ID" == "fedora" ]; then
            # Fedora 20+ has SSH logs in systemd
            sudo ${INSTALL} -q -yy install fail2ban-systemd
        fi

        sudo tee  /etc/fail2ban/jail.d/00-hostdeny.conf << EOF
# use hostsdeny by default
[DEFAULT]
banaction = hostsdeny
EOF

        sudo tee  /etc/fail2ban/jail.d/01-sshd.conf << EOF
# enable SSH jail
[sshd]
enabled = true
EOF

        # Enable service
        sudo systemctl enable fail2ban

    # CentOS 6
    elif [ $VERSION_ID -eq 6 ]; then
        sudo tee  /etc/fail2ban/jail.d/01-ssh-iptables.conf << EOF
# don't use iptables by default
[ssh-iptables]
enabled = false
EOF

        sudo tee  /etc/fail2ban/jail.d/02-ssh-tcpwrapper.conf << EOF
# use tcpwrapper SSH
[ssh-tcpwrapper]
enabled     = true
filter      = sshd
action      = hostsdeny[daemon_list=sshd]
logpath     = /var/log/secure
EOF

        # Enable service
        sudo chkconfig --add fail2ban

    fi

#
# Debian
#
elif [ "$ID" == "debian" ]; then

    # Install fail2ban package
    sudo apt-get -qq -y install fail2ban

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

#
# Ubuntu 14.04+
#
elif [ "$ID" == "ubuntu" ]; then

    # Install fail2ban package
    sudo apt-get -qq -y install fail2ban

    # Remove default debian config
    [ -f /etc/fail2ban/jail.d/defaults-debian.conf ] && \
        sudo rm /etc/fail2ban/jail.d/defaults-debian.conf

    sudo tee  /etc/fail2ban/jail.d/00-hostsdeny.conf << EOF
# use hostsdeny by default
[DEFAULT]
banaction = hostsdeny
EOF

    if [ ${VERSION_ID%%.*} -ge 15 ]; then
        SSH_JAILNAME="sshd"
    else
        SSH_JAILNAME="ssh"
    fi

    sudo tee  /etc/fail2ban/jail.d/01-ssh.conf << EOF
# enable SSH jail
[$SSH_JAILNAME]
enabled = true
EOF

    # Enable service
    [ -f /etc/init.d/fail2ban ] && sudo update-rc.d fail2ban enable

#
# OpenSuSE 13.2
#
elif [ "$ID" == "opensuse" ]; then
    # Install fail2ban package
    sudo zypper -n --no-gpg-checks install fail2ban

    # Enable service
    sudo systemctl enable fail2ban

    # Make our jail.d directory if doesn't exist
    [ -d /etc/fail2ban/jail.d ] || sudo mkdir /etc/fail2ban/jail.d

    sudo tee  /etc/fail2ban/jail.d/00-hostdeny.conf << EOF
# use hostsdeny by default
[DEFAULT]
banaction = hostsdeny
EOF

    sudo tee  /etc/fail2ban/jail.d/01-sshd.conf << EOF
# enable SSH jail
[sshd]
enabled = true
EOF
fi

# Some new distros don't ship the hostsdeny action
if [ ! -e /etc/fail2ban/action.d/hostsdeny.conf ]; then
    sudo tee  /etc/fail2ban/action.d/hostsdeny.conf << 'EOF'
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
