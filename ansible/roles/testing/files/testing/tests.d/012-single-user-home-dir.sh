#!/bin/bash
. $(dirname $0)/../assert.sh

### Only one user home directory
assert_raises "test $(find /home -mindepth 1 -maxdepth 1 -type d | wc -l) -eq 1"
assert_end "Single home directory exists in /home"
