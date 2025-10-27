#!/bin/bash
. $(dirname $0)/../assert.sh

###
assert_raises "sudo unattended-upgrades --dry-run -v | grep -q 'Allowed origins'"
assert_end "unattended upgrades is installed and working"
