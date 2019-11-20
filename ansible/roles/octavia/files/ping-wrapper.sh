#!/bin/bash
if [[ $HAPROXY_SERVER_ADDR =~ ":" ]]; then
    /bin/ping -q -n -w 1 -c 1 $HAPROXY_SERVER_ADDR > /dev/null 2>&1
else
    /bin/ping6 -q -n -w 1 -c 1 $HAPROXY_SERVER_ADDR > /dev/null 2>&1
fi
