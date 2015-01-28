#!/bin/bash
set -x

# OS detection used in other scripts
if [ -x /usr/bin/lsb_release ]; then
    OSSTRING="$(lsb_release -s -d | sed -e 's/"//g') $(uname -m)"
elif [ -f /etc/os-release ]; then
    source /etc/os-release
    OSSTRING=$PRETTY_NAME
elif [ -f /etc/redhat-release ] ; then
    OSSTRING="$(cat /etc/redhat-release) $(uname -m)"
else
    OSSTRING="$(uname -s) $(uname -r) $(uname -m)"
fi

# Add banner
cat >> /etc/ssh/sshd_banner <<EOF
-----------------------------------------------------------
  $OSSTRING                                                           
  Image details and information is available at                               
  http://support.rc.nectar.org.au/docs/image_catalog.html                    
-----------------------------------------------------------

EOF
sed -i -e 's/^#\?Banner .*$/Banner \/\etc\/\ssh\/\sshd_banner/g' /etc/ssh/sshd_config
