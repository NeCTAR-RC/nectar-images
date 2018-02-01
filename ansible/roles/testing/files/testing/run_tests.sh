#!/bin/bash

LOGFILE=/var/log/nectar_tests.log
TESTS_D=$(dirname -- "$0")/tests.d
RET=0

echo ""
echo "================================================================================="
echo "                                 Running Tests                                   "
echo "================================================================================="
echo ""

# Iterate through tests
[ ! -d "$TESTS_D" ] && exit 0
for file in "$TESTS_D"/*.sh ; do
    [ -x "$file" ] || continue
    "$file" "$@"
    [ $? -gt 0 ] && RET=$STATUS
done

echo ""
echo "================================================================================="
echo "                                Tests Complete                                   "
echo "================================================================================="
echo ""

exit $RET
