#!/bin/sh

echo "File: " $1
echo "Gap (in min): " $2
file=$1
gap=$2

awk < $file '{
currenttime=$4;
split(currenttime,a,":")
if (a[1]=="" || a[2]=="" || a[3]=="") next;
currentmin=(a[1]*60)+a[2];
if (prevmin)
{
timegap=currentmin-prevmin;
if (timegap > '$gap') { print "Found gap of", timegap,"mins..."; print prevline; print $0 }
}
prevmin=currentmin;
prevline=$0
}'
