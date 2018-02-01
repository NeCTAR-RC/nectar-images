#!/bin/bash
. $(dirname $0)/../assert.sh

### Ephemeral disk checking
skip_if "test ! -b /dev/vdb" # skip is doesn't exist
assert_raises "grep '/dev/vdb.*ext4.*rw' /proc/mounts"
assert_end "Check that ephemeral disk is ext4 and read-write mounted on vdb"
