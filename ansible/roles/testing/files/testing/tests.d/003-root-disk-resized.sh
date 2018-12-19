#!/bin/bash
. $(dirname $0)/../assert.sh

### Root disk resized
skip_if "test ! -z $NECTAR_TEST_BUILD"
assert_raises "test $(df -P -BG / | tail -n1 | awk '{print $2}' | sed -n 's/^\([0-9]\+\)G/\1/p') -gt 4"
assert_end "Root filesystem resized"
