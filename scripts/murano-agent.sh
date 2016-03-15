#!/bin/bash
set -x
set -e

# Test OS
if [ -f /etc/os-release ]; then
    source /etc/os-release
fi

# We only support murano agent on Ubuntu 14.04 for now
if [ "$ID" == "ubuntu" ] && [ "$VERSION_ID" == "14.04" ]; then
    # We require Mitaka cloud archive for deps
    add-apt-repository -y cloud-archive:mitaka
    # Package only available for Wiley
    wget http://au.archive.ubuntu.com/ubuntu/pool/universe/m/murano-agent/murano-agent_1.0.0~b3-1_all.deb -O /tmp/murano-agent_1.0.0~b3-1_all.deb
    dpkg -i /tmp/murano-agent_1.0.0~b3-1_all.deb || true # keep script running
    apt-get -qq -y install -f
    rm -f /tmp/murano-agent_1.0.0~b3-1_all.deb
else
    # Not supported
    exit 1
fi
