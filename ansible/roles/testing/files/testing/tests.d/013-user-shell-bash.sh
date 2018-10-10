#!/bin/bash
. $(dirname $0)/../assert.sh

### Users shell is set to /bin/bash
assert "getent passwd $USER | cut -d: -f7" '/bin/bash'
assert_end "users shell is set to /bin/bash"
