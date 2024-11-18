#!/bin/bash
. $(dirname $0)/../assert.sh

# Ensure password auth is no
assert "sudo sshd -T | grep -q 'passwordauthentication no'"

# Run a test against localhost
RESULT=$(ssh -v -n \
    -o Batchmode=yes \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -o PreferredAuthentications=password \
    -o PubkeyAuthentication=no \
    DOES_NOT_EXIST@localhost 2>&1 \
    | grep 'Permission denied' | grep password)

assert_raises "$RESULT" "password"

assert_end "SSH Password Authentication is disabled"
