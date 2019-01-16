#!/bin/bash
. $(dirname $0)/../assert.sh

### Fail2ban
skip_if "test ! -z $NECTAR_TEST_BUILD"
skip_if "test -z $(which fail2ban-server 2>/dev/null)" # only run test if installed
assert_raises "pgrep fail2ban"
assert_end "fail2ban is running"
