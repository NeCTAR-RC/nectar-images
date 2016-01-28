#!/bin/bash
set -x
set -e

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OSSTRING=$PRETTY_NAME
elif [ -x /usr/bin/lsb_release ]; then
    OSSTRING="$(lsb_release -s -d | sed -e 's/"//g') $(uname -m)"
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

if [ -z "\$DISTRIB_DESCRIPTION" ] && [ -x /usr/bin/lsb_release ]; then
        # Fall back to using the very slow lsb_release utility
        DISTRIB_DESCRIPTION=\$(lsb_release -s -d)
fi

echo "-------------------------------------------------------------------------------------"
echo "  NeCTAR $DISTRIB_DESCRIPTION $(uname -i)"
echo "  Image details and information is available at"
echo "  https://support.nectar.org.au/support/solutions/articles/6000106269-image-catalog"
echo "-------------------------------------------------------------------------------------"
EOF
else
    # Add motd
    cat > /etc/motd << EOF
-------------------------------------------------------------------------------------
  NeCTAR $OSSTRING
  Image details and information is available at
  https://support.nectar.org.au/support/solutions/articles/6000106269-image-catalog
-------------------------------------------------------------------------------------

EOF
fi
