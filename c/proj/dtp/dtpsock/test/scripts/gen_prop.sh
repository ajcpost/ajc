#!/bin/sh

###########
#### Default values
v4Family=2
v6Family=30
protoTcp=6
protoSctp=132
clientPort=5777
serverPort=2999
clientCertStore=/tmp/store.pem
clientCertFile=/tmp/clientCert.pem
clientKeyFile=/tmp/clientKey.pem
serverCertStore=/tmp/store.pem
serverCertFile=/tmp/serverCert.pem
serverKeyFile=/tmp/serverKey.pem
enableSsl=0
enableSslClientAuth=0
#v4ClientAddr=10.66.92.78
v4ClientAddr=localhost
v6ClientAddr=::1
v4ServerAddr=localhost
v6ServerAddr=::1

v4Client="$v4Family $v4ClientAddr"
v6Client="$v6Family $v6ClientAddr"
v4MultiClient="$v4Family junk10.66.92 $v6Family $v4ClientAddr $v4Family $v4ClientAddr $v4Family $v4ClientAddr"
v6MultiClient="$v6Family junkfe80::21f:5bffA $v4Family $v6ClientAddr $v6Family $v6ClientAddr $v6Family $v6ClientAddr"

v4Server="$v4Family $v4ServerAddr"
v6Server="$v6Family $v6ServerAddr"
v4MultiServer="$v4Family junk10.66.92 v6Family $v4ServerAddr $v4Family $v4ServerAddr $v4Family $v6ServerAddr"
v6MultiServer="$v6Family junkfe80::21f:5bffA $v4Family $v6ServerAddr $v6Family $v6ServerAddr $v6Family $v6ServerAddr"

usage ()
{
printf "Usage: %s: [-p tcp|sctp] [-f 4|6] [-a v4|v4multi|v6|v6multi|v4v6] [-s] [-c]\n" $(basename $0) >&2
exit 1;
}

############
#### Base properties
genDefault ()
{
    echo "clientLogFilePath="
    echo "clientMaxLogSize=10000000"
    echo "clientLogLevel=DEBUG"
    echo "clientSharedPort=$clientPort"

    echo "serverLogFilePath="
    echo "serverMaxLogSize=10000000"
    echo "serverLogLevel=DEBUG"
    echo "serverSharedPort=$serverPort"
    echo "serverSocketQLen=5"

    echo "maxPduSize=10000000"
    echo "transferDataSize=1024"

    echo "protocol=$protoTcp"
    echo "afamily=$v4Family"
    echo "ipv6Only=0"
    echo "blocking=1"
    echo "clientCertStore=$clientCertStore"
    echo "clientCertFile=$clientCertFile"
    echo "clientKeyFile=$clientKeyFile"
    echo "serverCertStore=$serverCertStore"
    echo "serverCertFile=$serverCertFile"
    echo "serverKeyFile=$serverKeyFile"
}

## Based on input
genConfig ()
{
cfgProtocol=""
cfgFamily=""
cfgAddr=""
while getopts p:f:a:s:c option
do
    case $option in
        p) cfgProtocol="$OPTARG"
        ;;
        f) cfgFamily="$OPTARG"
        ;;
        a) cfgAddr="$OPTARG"
        ;;
        s) enableSsl=1
        ;;
        c) enableSslClientAuth=1
        ;;
        ?) usage
        ;;
    esac
done

if [ "$cfgProtocol" == "tcp" ]
then
    echo "protocol=$protoTcp"
elif [ "$cfgProtocol" == "sctp" ]
then
    echo "protocol=$protoSctp"
else
    echo "Wrong protocol value $cfgProtocol"
    usage
fi

if [ "$cfgFamily" == "4" ]
then
    echo "afamily=$v4Family"
elif [ "$cfgFamily" == "6" ]
then
    echo "afamily=$v6Family"
else
    echo "Wrong address family value $cfgFamily"
    usage
fi

if [ "$cfgAddr" == "v4" ]
then
    echo "clientBindAddr=$v4Client"
    echo "serverBindAddr=$v4Server"
    echo "clientConnectAddr=$v4Server"
elif [ "$cfgAddr" == "v4multi" ]
then
    echo "clientBindAddr=$v4MultiClient"
    echo "serverBindAddr=$v4MultiServer"
    echo "clientConnectAddr=$v4MultiServer"
elif [ "$cfgAddr" == "v6" ]
then
    echo "clientBindAddr=$v6Client"
    echo "serverBindAddr=$v6Server"
    echo "clientConnectAddr=$v6Server"
elif [ "$cfgAddr" == "v6multi" ]
then
    echo "clientBindAddr=$v6MultiClient"
    echo "serverBindAddr=$v6MultiServer"
    echo "clientConnectAddr=$v6MultiServer"
else
    echo "Wrong address value $cfgAddr"
    usage
fi
echo "enableSsl=$enableSsl"
echo "enableSslClientAuth=$enableSslClientAuth"
}

genDefault
if [ $# -gt 0 ]
then
    genConfig $*
fi
