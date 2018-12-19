#!/bin/bash
. $(dirname $0)/../assert.sh

### SSH key for root (populated by cloud-init)
skip_if "test ! -z $NECTAR_TEST_BUILD"
assert "sudo wc -l /root/.ssh/authorized_keys | cut -d ' ' -f1" 1
assert_end "Single SSH authorized key for root exists"
