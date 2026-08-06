#!/bin/bash
. $(dirname $0)/../assert.sh

### /etc/hosts has localhost entries and localhost resolves
assert_raises "grep -Eq '^127\.0\.0\.1[[:space:]]+localhost' /etc/hosts"
assert_raises "grep -Eq '^::1[[:space:]]' /etc/hosts"
assert_raises "getent hosts localhost"
assert_end "localhost resolves via /etc/hosts"
