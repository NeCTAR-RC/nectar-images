#!/bin/bash
. $(dirname $0)/../assert.sh

### I/O scheduler is none/noop
assert "grep -Ev '(none|\[noop\])' /sys/block/*/queue/scheduler" ''
assert_end "Check that none/noop I/O scheduler in use"
