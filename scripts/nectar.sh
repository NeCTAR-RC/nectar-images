#!/bin/bash
set -x
set -e

if [ "${ORGANISATION}" == "NeCTAR" ] ; then
    ln -sf /var/lib/packer/build /usr/nectar
fi
