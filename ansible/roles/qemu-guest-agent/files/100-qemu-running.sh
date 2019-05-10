#!/bin/bash
. $(dirname $0)/../assert.sh

assert_raises "pgrep qemu-ga"
assert_end "QEMU guest agent is running"
