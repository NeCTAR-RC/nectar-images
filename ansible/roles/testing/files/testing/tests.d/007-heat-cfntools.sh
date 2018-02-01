#!/bin/bash
. $(dirname $0)/../assert.sh

if [ -f /etc/os-release ]; then
    . /etc/os-release
elif [ -f /etc/redhat-release ]; then
    NAME=$(sed -e 's/\(.*\)release\? \([0-9]\+\).*/\1/' /etc/redhat-release)
    ID=$(echo $NAME | tr '[:upper:]' '[:lower:]')
    VERSION_ID=$(sed -e 's/.*release\? \([0-9]\+\).*/\1/' /etc/redhat-release)
else
    echo "Disto ID check fail"
    exit 1
fi

### heat-cfntools for everything except CentOS 5
skip_if "test \"$ID\" = \"centos\" -a $VERSION_ID -lt 6"
assert_raises "which cfn-create-aws-symlinks cfn-get-metadata cfn-push-stats cfn-hup cfn-init cfn-signal"
assert_end "heat-cfntools are installed"
