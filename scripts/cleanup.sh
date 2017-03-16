#!/bin/bash -xe

dd if=/dev/zero of=/EMPTY bs=1M || true
rm -f /EMPTY
sync
