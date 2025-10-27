#!/bin/bash
. $(dirname $0)/../assert.sh

### R-Studio also has a shiny user, so test for 2
assert_raises "test $(find /home -mindepth 1 -maxdepth 1 -type d | wc -l) -eq 2"
assert_end "Two home directories exists in /home"
