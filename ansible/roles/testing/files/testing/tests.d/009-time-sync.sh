#!/bin/bash
. $(dirname $0)/../assert.sh

### NTP running
assert_raises "pgrep -f 'ntp|chronyd|systemd-timesyncd'"
assert_end "NTP, chrony or systemd-timesyncd service is running"
