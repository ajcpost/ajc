#!/bin/sh

function usage()
{
    echo "find_logstmts <src-dir> <comma separated log-patterns>"
    exit 1;
}

function parse_args()
{
    if [ $# -ne 2 ]
    then
        usage
    else
        SRCDIR=$1
        PATTERN=$2
    fi
}

function find_logstmts()
{
    find $SRCDIR -name "*.java" -print | xargs -I % cat % | awk '{ print "file"; }'
}

parse_args $*
find_logstmts

