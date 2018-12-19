#!/bin/bash
. $(dirname $0)/../assert.sh

### NTP running
skip_if "test ! -z $NECTAR_TEST_BUILD"
assert_raises "pgrep -f 'ntp|chronyd|systemd-timesyncd'"
assert_end "time sync service is running"
