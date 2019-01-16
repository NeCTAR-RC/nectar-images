#!/bin/bash
. $(dirname $0)/../assert.sh

### Serial console set in right order
skip_if "test ! -z $NECTAR_TEST_BUILD"
assert_raises "grep -E 'console=tty0\s.*console=ttyS0' /proc/cmdline"
assert_end "Kernel console log configured correctly"
