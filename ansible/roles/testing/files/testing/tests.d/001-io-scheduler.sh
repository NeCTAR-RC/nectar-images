#!/bin/bash
. $(dirname $0)/../assert.sh

### I/O scheduler is none/noop
skip_if "test ! -z $NECTAR_TEST_BUILD"
assert "grep -Ev '(none|\[noop\])' /sys/block/*/queue/scheduler" ''
assert_end "Check that none/noop I/O scheduler in use"
