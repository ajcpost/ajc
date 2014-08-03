#!/bin/sh
acl=$1
user=$2
time=$3
echo "Granting ACL $acl to $user for $time hours"
./gnu p5 -f /ariba/ond_sspr3/ariba/platform/acls/${acl} allow ${user} -t ${time}
# "./gnu p5 -f ~/ariba/mainline/ariba/platform/catalog/acls/core.acl allow gbhatnagar -t 24;"
