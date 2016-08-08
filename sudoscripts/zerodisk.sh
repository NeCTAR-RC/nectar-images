#!/bin/bash
set -x

# Zero out the free space to save space in the final image:
sudo dd if=/dev/zero of=/EMPTY bs=1M
sync
sudo rm -f /EMPTY
sync
exit
