#!/bin/bash
set -x
set -e

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

# Ubuntu uses it's own MOTD solution
if [ "$ID" == "ubuntu" ]; then
cat > /etc/update-motd.d/00-header << EOF
#!/bin/sh
[ -r /etc/lsb-release ] && . /etc/lsb-release

if [ -z "$DISTRIB_DESCRIPTION" ] && [ -x /usr/bin/lsb_release ]; then
        # Fall back to using the very slow lsb_release utility
        DISTRIB_DESCRIPTION=$(lsb_release -s -d)
fi

echo "-----------------------------------------------------------"
echo "  $DISTRIB_DESCRIPTION $(uname -i)"
echo "  Image details and information is available at            "
echo "  http://support.rc.nectar.org.au/docs/image_catalog.html  "
echo "-----------------------------------------------------------"
EOF
else
    # Add motd
    cat > /etc/motd << EOF
-----------------------------------------------------------
  $OSSTRING
  Image details and information is available at
  http://support.rc.nectar.org.au/docs/image_catalog.html
-----------------------------------------------------------

EOF
fi
