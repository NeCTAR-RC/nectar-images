#!/bin/bash
. $(dirname $0)/../assert.sh

### 
assert_raises "sudo dnf-automatic --no-downloadupdates --no-installupdates"
assert_end "dnf-automatic is installed and working"
