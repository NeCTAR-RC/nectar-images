#!/bin/bash
. $(dirname $0)/../assert.sh

assert_raises "pgrep qemu-ga"
assert_end "QEMU guest agent is running"

assert_raises "ps --no-heading -o cmd -p $(pgrep qemu-ga) | grep -E 'blacklist.guest'"
assert_end "QEMU guest agent started with blacklist"
