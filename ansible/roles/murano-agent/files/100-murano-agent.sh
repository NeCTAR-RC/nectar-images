#!/bin/bash
. $(dirname $0)/../assert.sh

### murano-agent service is installed and not running (return code 3)
assert_raises "/sbin/service murano-agent status" 3
assert_end "murano-agent is installed and disabled"
