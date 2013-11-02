#!/bin/sh

########################################################################################
# Utility functions used by dyncapPerlUT.sh
########################################################################################


###############
### Globals
###############

_service=""
_product=""
_curBuild=""
_curBuildRoot=""
_debug="false"
_rcDeployHome="/home/rc/archive/deployments"
_runDir=rundata # Must be in sync with path setup in SetLib.pm
_testDir=testdata
_inputTestCases=""
_srcBuild=baseline
_destBuilds="all addhost addcommunity addindefault replacehost"
_configFiles="appflags.cfg BranchName ClusterName Parameters.table ProductName ReleaseName roles2dirs.cfg TomcatVersion.cfg"
_errorPatterns="Error Failed Abort Died"

_perl=perl

usage()
{
    echo "Usage: dyncapPerlUT.sh -p <buyer|s4> -s <itg|dev|personal_robot354|...> [-t <comma separated list>] [-n comma separated dest buids] [-d]"
    echo "-t modjk.t,topologymanager.t"
    echo "-n all,addhost"
    echo "-d will dump additional messages"
    exit 1
}

logMsg()
{
    msg="==`date`== $*"
    echo ${msg}
}

debugMsg()
{
    if [ ${_debug} = "true" ]
    then
        echo
        echo $*
    fi
}

exitWithUsage()
{
    logMsg "$*"
    usage
}

exitOnError()
{
    logMsg "$*"
    exit 1
}

exitOnSuccess()
{
    logMsg "$*"
    exit 0
}

replacePattern()
{
    inFile=$1
    outFile=$2
    inPattern=$3
    outPattern=$4

    debugMsg "Replacing \"${inPattern}\" in ${inFile}"
    debugMsg "       to \"${outPattern}\" in ${outFile}"
    if [ `grep -c "${inPattern}" ${inFile}` -eq 0 ]
    then
        exitOnError "${inFile} doesn't have \"${inPattern}\""
    else
        ### sed uses ':' as delimited so if the pattern contains
        ### that char, it must be escaped.
        cat ${inFile} | sed "s:${inPattern}:${outPattern}:" > ${outFile}
    fi
}
