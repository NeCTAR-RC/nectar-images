#!/bin/bash
set -x
set -e

if [ -z "${ORGANISATION}" ] ; then
    ORGANISATION="NeCTAR"
fi

if [ -z "${IMAGE_SUPPORT_URL}" ] ; then
    IMAGE_SUPPORT_URL="https://support.nectar.org.au/support/solutions/articles/6000106269-image-catalog"
fi

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
echo "  ${ORGANISATION} \$DISTRIB_DESCRIPTION \$(uname -i)"
echo "  Image details and information is available at"
echo "  ${IMAGE_SUPPORT_URL}"
echo "-------------------------------------------------------------------------------------"
EOF
else
    # Add motd
    cat > /etc/motd << EOF
-------------------------------------------------------------------------------------
  ${ORGANISATION} ${OSSTRING}
  Image details and information is available at
  ${IMAGE_SUPPORT_URL}
-------------------------------------------------------------------------------------

EOF
fi
