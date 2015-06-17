#!/bin/bash
# This script is the entrypoint of a CGAL testsuite docker container.
set -e

testresult_owner_uid=$(stat -c '%u' /mnt/testresults)
testresult_group_id=$(stat -c '%g' /mnt/testresults)


# Only add cgal_tester group and user, when they do not already exist.
groupadd -o -g $testresult_group_id -f cgal_tester
id -u cgal_tester &>/dev/null || useradd -o -u $testresult_owner_uid -d /home/cgal_tester -g cgal_tester cgal_tester
# useradd will not create the home directory and we cannot use
# adduser, because it is Debian specific
mkdir -p /home/cgal_tester
chown cgal_tester:cgal_tester /home/cgal_tester

cd /home/cgal_tester
su cgal_tester -c '/bin/bash /mnt/testsuite/run-testsuite.sh'
