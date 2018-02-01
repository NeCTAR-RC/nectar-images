#!/bin/bash
. $(dirname $0)/../assert.sh

### No default passwords
assert "sudo cut -d ':' -f 2 /etc/shadow | cut -d '$' -sf3" ''
assert_end "No default passwords exist"
