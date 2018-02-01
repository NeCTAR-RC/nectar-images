#!/bin/bash
. $(dirname $0)/../assert.sh

### SSH key for current user (populated by cloud-init)
assert "wc -l ~/.ssh/authorized_keys | cut -d ' ' -f1" 1
assert_end "Single SSH authorized key for current user exists"
