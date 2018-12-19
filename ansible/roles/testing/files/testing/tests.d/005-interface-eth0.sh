#!/bin/bash
. $(dirname $0)/../assert.sh

### Default interface is eth0
skip_if "test ! -z $NECTAR_TEST_BUILD"
assert_raises "/sbin/ip route | grep -E 'default via.*dev eth0'"
assert_end "Default route via interface named eth0"
