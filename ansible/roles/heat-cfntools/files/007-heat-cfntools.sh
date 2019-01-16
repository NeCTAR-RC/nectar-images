#!/bin/bash
. $(dirname $0)/../assert.sh

### heat-cfntools installed in path
assert_raises "which cfn-create-aws-symlinks cfn-get-metadata cfn-push-stats cfn-hup cfn-init cfn-signal"
assert_end "heat-cfntools are installed"
