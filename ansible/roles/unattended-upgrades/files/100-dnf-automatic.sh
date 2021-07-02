#!/bin/bash
. $(dirname $0)/../assert.sh

### 
assert_raises "sudo dnf-automatic --no-downloadupdates --no-installupdates 2>&1 | grep -qE '(The following updates are available|No security updates needed)'"
assert_end "dnf-automatic is installed and working"
