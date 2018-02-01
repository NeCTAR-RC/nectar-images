#!/bin/bash
. $(dirname $0)/../assert.sh

### Default interface is eth0
assert_raises "/sbin/ip route | grep -E 'default via.*dev eth0'"
assert_end "Default route via interface named eth0"
