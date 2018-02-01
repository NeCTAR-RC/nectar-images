#!/bin/bash
. $(dirname $0)/../assert.sh

### Package repos
if hash zypper 2>/dev/null; then
    assert_raises "sudo zypper --gpg-auto-import-keys refresh"
    assert_raises "sudo zypper clean"
    assert_end "Package repositories are OK"
elif hash dnf 2>/dev/null; then
    assert_raises "sudo dnf makecache"
    assert_raises "sudo dnf clean all"
    assert_end "Package repositories are OK"
elif hash yum 2>/dev/null; then
    assert_raises "sudo yum makecache"
    assert_raises "sudo yum clean all"
    assert_end "Package repositories are OK"
elif hash apt-get 2>/dev/null; then
    assert_raises "sudo apt-get update"
    assert_raises "sudo apt-get -y clean all"
    assert_end "Package repositories are OK"
fi
