#!/bin/bash
set -x
set -e

# Test OS
if [ -f /etc/os-release ]; then
    source /etc/os-release
fi

### Ubuntu 16.04
if [ "$ID" == "ubuntu" ] && [ "$VERSION_ID" == "16.04" ]; then

    # We use the distro package for Murano Agent, but it's defaults are very
    # very different to the values pushed by the Murano service.
    # We work around things here like:
    # (script runs as 'sh' but uses 'bash' syntax
    # /var/lib/heat-cfntools/cfn-userdata: 7: /var/lib/heat-cfntools/cfn-userdata: [[: not found
    # And the distro init script and murano service having different ideas on
    # where the config and log files are kept.

	# Clean up bad distro scripts and directories
	rm -fr /etc/init.d/murano-agent /etc/init/murano-agent.conf \
           /etc/murano-agent /var/log/murano /var/log/murano-agent

	# Pre-create these directories to avoid errors
	/bin/mkdir -p /etc/murano /var/murano/plans

	# Install standard agent package for Xenial
	apt-get -y install murano-agent

    # Install an actual working service config
    cat > /etc/systemd/system/murano-agent.service << EOF
[Unit]
Description=OpenStack Murano Agent

[Service]
Type=simple
ExecStart=/usr/bin/muranoagent --config-dir=/etc/murano --log-file=/var/log/murano-agent.log
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload

	# Yes, exit
	exit 0
fi


### Source based installs for Ubuntu 14.04 and CentOS 7
dir=/opt/stack
venv_dir=$dir/venvs/murano-agent
source_dir=$dir/murano-agent
repo=git://git.openstack.org/openstack/murano-agent.git
branch=stable/liberty

### Ubuntu 14.04
if [ "$ID" == "ubuntu" ] && [ "$VERSION_ID" == "14.04" ]; then

    # Add liberty cloud-archive repo for deps
    add-apt-repository -y cloud-archive:liberty
	apt-get -q -y update

    DEBIAN_FRONTEND=noninteractive apt-get -y install git-core wget make gcc \
                                              python-pip python-dev \
                                              python-virtualenv \
                                              python-setuptools chef puppet

    apt-get -y install python-amqp python-babel python-bunch python-enum34 \
                       python-eventlet python-git python-gitdb python-greenlet \
                       python-iso8601 python-kombu python-netaddr \
                       python-netifaces python-oslo.concurrency \
                       python-oslo.config python-oslo.context python-oslo.i18n \
                       python-oslo.log python-oslo.serialization \
                       python-oslo.service python-oslo.utils python-monotonic \
                       python-paste python-pastedeploy python-pyinotify \
                       python-dateutil python-repoze.lru python-requests \
                       python-retrying python-routes python-semantic-version \
                       python-smmap python-stevedore python-webob python-wrapt

    # Install init script
    cat > /etc/init/murano-agent.conf << EOF
start on runlevel [2345]
stop on runlevel [016]

respawn
# the default post-start of 1 second sleep delays respawning enough to
# not hit the default of 10 times in 5 seconds. Make it 2 times in 5s.
respawn limit 2 5

# We're logging to syslog
console none

exec start-stop-daemon --start -c root --exec /opt/stack/venvs/murano-agent/bin/muranoagent -- --config-dir /etc/murano 2>&1 | logger -t murano-agent

post-start exec sleep 1
EOF
fi

### CentOS 7
if [ "$ID" == "centos" ] && [ "$VERSION_ID" == "7" ]; then

    # Add liberty openstack repo
    cat > /etc/yum.repos.d/CentOS-OpenStack-liberty.repo << EOF
[centos-openstack-liberty]
name=CentOS-\$releasever - OpenStack liberty
baseurl=http://mirror.centos.org/centos/\$releasever/cloud/\$basearch/openstack-liberty/
gpgcheck=0
enabled=1
EOF

    # Installation deps
    yum install -y git-core wget make gcc python-pip python-devel \
                   python-setuptools python-virtualenv puppet

    # Murano agent deps: try to install as many as possible as RPMS
    yum install -y python-amqp python-babel python-bunch python-debtcollector \
                   python-enum34 python2-eventlet python2-fasteners \
                   python2-funcsigs python-gitdb python2-greenlet \
                   python2-iso8601 python-kombu python-monotonic \
                   python2-msgpack python-netaddr python-netifaces \
                   python-oslo-context python-oslo-i18n python-oslo-log \
                   python-oslo-serialization python-oslo-service \
                   python-oslo-utils python-paste python-paste-deploy \
                   python-inotify python-dateutil pytz python-repoze-lru \
                   python-requests python-retrying python-routes python-smmap \
                   python-stevedore python-webob python-wrapt \
                   python2-funcsigs GitPython

    # Install service config
    cat > /etc/systemd/system/murano-agent.service << EOF
[Unit]
Description=OpenStack Murano Agent

[Service]
Type=simple
ExecStart=/opt/stack/venvs/murano-agent/bin/muranoagent --config-dir /etc/murano
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable murano-agent.service
fi


### Common source installation steps
virtualenv --system-site-packages $venv_dir

mkdir -p $source_dir
git clone --depth=1 -b $branch $repo $source_dir

$venv_dir/bin/pip install $source_dir

mkdir -p /etc/murano /var/murano/plans
