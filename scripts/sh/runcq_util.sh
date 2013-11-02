#!/bin/sh

###############################################################################
# Utility functions used by runcq.sh
###############################################################################


###############
### Globals
###############
_service=""
_product=""
_curBuild=""
_oldBuild=""
_newBuild=""
_masterPassword=""
_svcRoot=""
_useCase=""
_cqTest=""
_rcDeployHome="/home/rc/archive/deployments"
_sswsTopologyRoot="ssws/docroot/topology"

_curBuildRoot=""
_oldBuildRoot=""
_newBuildRoot=""
_capacityUC="capacityChange"
_rebalanceUC="realmRebalance"
_integratedUC="integrated"
_cqTestDataDir="internal/testData/test.cluster"
_cqPreTest="pre-test"

_restoreNewBuildConfig="true"
_pause="false"
_cd="control-deployment"
_ctfExecutor="clusterTestExecutor"
_addrealms="addandinitrealms"
_rebalancerealms="rebalancerealms.pl"
_migrateschool="migrateSchool"
_postAddRealmEvent="PostAddRealms"
_postRebalanceRealmEvent="PostRealmRebalance"
_ecbPath=""
_backupPrefix="_cq_bak"
_configFilesToPatch="roles.cfg appcounts.cfg"
__sleepIntervalAfterCdStop=120
_sleepIntervalAfterCd=800
_debug="false"


usage()
{
    echo "Usage: runcq.sh -s <itg|dev|> -p <buyer|s4> -u <capacityChange|realmRebalance|integrated> 
                          -t <test scenario>
                          [ -o <installed_build_label> -n <new_build_label>]
                          [ -z <sleep sec> -k -m -d]"
    echo "-k (keep) will _not_ restore new build's config to RC baseline"
    echo "-m (manual mode) will make script execution pause at high level steps"
    echo "-z (sleep sec) will sleep for input seconds after every C-D start/upgrade/restart"
    echo "-d (debug mode) will dump additional messages"
    exit 1
}

stepMsg()
{
    msg="STEP::`date`:: $*"
    echo "============================================="
    echo ${msg}
    echo "============================================="
}

logMsg()
{
    msg="Log::`date`:: $*"
    echo ${msg}
}

debugMsg()
{
    if [ ${_debug} = "true" ]
    then
        echo $*
    fi
}

pause()
{
    if [ ${_pause} = "true" ]
    then
        msg="Pause::`date`:: $*"
        echo ${msg}
        read
    fi
}

exitOnError()
{
    errMessage="$*"
    logMsg "Error - ${errMessage}"
    stepMsg "CQ failed!!, You may have to cleanup runaway Java processes."
    exit 1;
}

exitOnSuccess()
{
    stepMsg "CQ successful!!"
    if [[ (${_useCase} != ${_rebalanceUC}) && (${_restoreNewBuildConfig} = "false") ]]
    then
        stepMsg "${_newBuild} is on test configuration - ${_cqTest}\
                 LQ may not succeed on this configuration."
    fi
    exit 0;
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

cleanupCluster()
{
    logMsg "Archiving l2pmap & centralized topology"
    chmod +w ${_svcRoot}/${_sswsTopologyRoot}
    currentDir=`pwd`
    cd ${_svcRoot}/${_sswsTopologyRoot}
    configDir=${_product}

    ### Move existing dir to backup and create a fresh one
    if [ ! -d ${configDir}${_backupPrefix} ]
    then
        mkdir ${configDir}${_backupPrefix}
    fi
    ts=`date +%Y%m%d_%H%M`
    debugMsg "Moving ${configDir} --> ${configDir}${_backupPrefix}/${configDir}${ts}"
    mv ${configDir} ${configDir}${_backupPrefix}/${configDir}${ts}
    mkdir ${configDir}
    cd ${currentDir}

    logMsg "Archiving l2pmap & centralized topology - done"
}

takeConfigBackup()
{
    buildConfig=$1
    backupConfig=${buildConfig}${_backupPrefix}
    if [ ! -d ${backupConfig} ]
    then
        mkdir ${backupConfig}
        debugMsg "Copying from ${buildConfig} --> ${backupConfig}"
        for file in ${_configFilesToPatch}
        do
            cp ${buildConfig}/${file} ${backupConfig}
        done
        chmod -w ${backupConfig}/*
        chmod -w ${backupConfig}
    else
        logMsg "Backup config ${backupConfig} already exists"
    fi
}

takeCTFResultsBackup()
{
    logMsg "Backing CTF results"
    buildRoot=$1

    ### Find the location of the results
    if [ -e "${_ecbPath}" ]
    then
        ctfResultDir=`cat ${_ecbPath} | grep "ResultDir" | cut -d "=" -f2 | 
                      sed 's:"::g' | sed 's:;::g'`
    else
        logMsg "Can't find ${_ecbPath} and CTF result location. \
                No backup will be taken"
        return
    fi

    if [ ! -d "${ctfResultDir}" ]
    then
        logMsg "Can't find ${ctfResultDir}. No backup will be taken"
        return
    fi

    ### Bakup previous results, if any
    currentDir=`pwd`
    cd ${ctfResultDir}
    resultDir=`basename $(pwd)`
    cd ..
    chmod +w .
    if [ ! -d ${resultDir}${_backupPrefix} ]
    then
        mkdir ${resultDir}${_backupPrefix}
    fi
    ts=`date +%Y%m%d_%H%M`
    debugMsg "Moving ${resultDir} --> ${resultDir}${_backupPrefix}"
    mv ${resultDir} ${resultDir}${_backupPrefix}/${resultDir}${ts}
    mkdir ${resultDir}
    cd ${currentDir}
    logMsg "Backing CTF results - done"
}

changePermissions()
{
    buildRoot=$1
    chmod +w ${buildRoot}
    chmod +w ${buildRoot}/config
    chmod +w ${buildRoot}/config/*
    chmod +w ${buildRoot}/lib/perl/ariba/rc/
    chmod +w ${buildRoot}/lib/perl/ariba/Ops/
    chmod +w ${buildRoot}/lib/perl/ariba/rc/ArchivedSharedServiceProduct.pm
    chmod +w ${buildRoot}/lib/perl/ariba/rc/InstalledSharedServiceProduct.pm
    chmod +w ${buildRoot}/lib/perl/ariba/Ops/PreCheck.pm
}

validateBuilds()
{
    ### Verify both builds are present
    if [[ (! -d ${_oldBuildRoot}) || (! -d ${_newBuildRoot}) ]]
    then
        exitOnError "One of ${_oldBuildRoot} or ${_newBuildRoot} doesn't exist";
    fi

    ### Verify both builds are different
    if [ ${_oldBuild} = ${_newBuild} ]
    then
        exitOnError "${_oldBuild} and ${_newBuild} are same"
    fi

    ### Verify both builds have ClusterName config file
    if [[ (! -e ${_oldBuildRoot}/config/ClusterName) || 
          (! -e ${_newBuildRoot}/config/ClusterName) ]]
    then
        exitOnError "${_oldBuildRoot}/config/ClusterName or
                     ${_newBuildRoot}/config/ClusterName doesn't exist";
    fi

    ### Verify old build is indeed currently installed build
    if [ ${_oldBuildRoot} != ${_curBuildRoot} ]
    then
        exitOnError "${_oldBuildRoot} is not installed build"
    fi

    ### Set write permissions for files/directories that the code will patch
    changePermissions ${_oldBuildRoot}
    changePermissions ${_newBuildRoot}
}


###############
### Wipe out records in communitytab and bucketstatetab
### This is a kludge but is required because svcsql with @<script>
### and here-document doesn't work. This is temporary and will soon go away
### once initCluster Java code is fixed to wipe out these tables.
###############
emptyTables()
{
    logMsg "Wiping out communitytab and bucketstate tab"

    ### ------------------------------------------------------------------------
    ### <-- Kludge begins -->
    ### Below lines do not work, hence the kludge
#    ${_oldBuildRoot}/bin/svcsql ${_product} ${_service} \@${_scriptHome}/cleanup.sql << eof
#${_masterPassword}
#eof
    svcSqlOutput=/tmp/svcsql.output
    ${_oldBuildRoot}/bin/svcsql ${_product} ${_service} -d > ${svcSqlOutput} << eof
${_masterPassword}
eof

    ### Extract values of interest from svcsql debug output. It's a very small file
    ### so it's ok to read it 4 times.
    sid=`cat ${svcSqlOutput} | grep "sid =" | cut -d "=" -f2 | sed 's/ //g'`
    dbhost=`cat ${svcSqlOutput} | grep "dbhost =" | cut -d "=" -f2 | sed 's/ //g'`
    user=`cat ${svcSqlOutput} | grep "user =" | cut -d "=" -f2 | sed 's/ //g'`
    pass=`cat ${svcSqlOutput} | grep "pass =" | cut -d "=" -f2 | sed 's/ //g'`

    ### Form sqlplus command using above values
    export ORACLE_HOME=/usr/local/oracle
    debugMsg "Running ${ORACLE_HOME}/bin/sqlplus ${user}/${pass}\@\"
              (description=(address=(host=${dbhost})(protocol=tcp)(port=1521))
              (connect_data=(sid=${sid})))\""
    ${ORACLE_HOME}/bin/sqlplus ${user}/${pass}@"(description=(address=(host=${dbhost})(protocol=tcp)(port=1521))(connect_data=(sid=${sid})))" << eof
delete from communitytab;
delete from bucketstatetab;
eof
    ### <-- Kludge ends -->
    ### ------------------------------------------------------------------------

    logMsg "Wiping out communitytab and bucketstate tab - done"
}

envSpecificSteps()
{
    logMsg "Running environment specific steps"
    buildRoot=$1
    if [[ ! -z $(echo ${buildRoot} | grep "svcitg" | grep "s4") ]]
    then
        commandParams="-installDir ${buildRoot} -readMasterpassword -skipCompleteSchoolSchemaMigration"
        debugMsg "Running ${buildRoot}/internal/bin/migrateSchool ${commandParams}"
        ${buildRoot}/internal/bin/migrateSchool ${commandParams} << eof
${_masterPassword}
eof
        debugMsg "Running env specific steps for S4, SVCITG environment - done"
    fi
    logMsg "Running environment specific steps - done"
}

launchCTF()
{
    logMsg "Launching CTF"
    eventParamFile=$1
    oldTopologyFile=$2
    newTopologyFile=$3
    ecbEvent=$4

    commandParams="-event ${ecbEvent} -config ${eventParamFile} -oldTopology ${oldTopologyFile} -newTopology ${newTopologyFile} -useCase ${_useCase}"
    debugMsg "Running ${_curBuildRoot}/internal/bin/${_ctfExecutor} ${commandParams}"
    ${_curBuildRoot}/internal/bin/${_ctfExecutor} ${commandParams}
    logMsg "Launching CTF - done"
}

addRealm()
{
    bdv=$1
    ${_curBuildRoot}/internal/bin/${_addrealms} -add 1 -baseDomainVariant ${bdv} -readMasterPassword << eof
${_masterPassword}
eof
    ret=$?
    if [ $ret -ne 0 ]
    then
        exitOnError "adding ${bdv} realm failed"
    fi
}

addRealms()
{
    logMsg "Adding realms"
    setCurBuild
    if [[ (${_product} = "buyer") ]]
    then
        addRealm vgeneric
        addRealm vpsoft84ora
        addRealm vsap
    else
        addRealm vbase
    fi
    logMsg "Adding realms - done"
}

rebalanceRealms()
{
    logMsg "Rebalancing realms"
    setCurBuild
    ${_curBuildRoot}/internal/bin/${_rebalancerealms} -cluster primary -product ${_product} -readMasterPassword << eof
${_masterPassword}
eof
    if [ $ret -ne 0 ]
    then
        exitOnError "rebalancing realms failed"
    fi
    logMsg "Rebalancing realms - done"
}

addRealmsWithRebalance()
{
    # To cover few of the test scenarios, CTF needs to be launched after adding realms and after 
    # rebalancing the realms. This requires configuration data like topology, selenium env
    # variables, etc (see PlatformHighTopologyManager.pm).
    #
    # Given that the test scenarios are very specific in nature:
    # - Path of the currently installed build's topology is passed as old/new topology.
    # - Selenium env is not set.

    setCurBuild

    # Example topology file location -- /var/tmp/buyer/tomcat/itg/SSPR3-787/Node1-app511
    topoParentDir=/var/tmp/${_product}/tomcat/${_service}/${_curBuild}
    subDir=`ls ${topoParentDir} | tail -1`
    oldTopologyFile=${topoParentDir}/${subDir}/Topology.table
    newTopologyFile=${topoParentDir}/${subDir}/Topology.table
    
    addRealms
    launchCTF ${_ecbPath} ${oldTopologyFile} ${newTopologyFile} ${_postAddRealmEvent}
    rebalanceRealms
    launchCTF ${_ecbPath} ${oldTopologyFile} ${newTopologyFile} ${_postRebalanceRealmEvent}
}

addRealmsWithoutRebalance()
{
    addRealms
}

restartSSWS()
{
    logMsg "Restarting SSWS"
    cdbinary=${_svcRoot}/ssws/bin/${_cd}
    commandParams="ssws ${_service} -cluster primary -force restart"
    debugMsg "Running ${cdbinary} ${commandParams}"
    ${cdbinary} ${commandParams} << EOF
$_masterPassword
EOF
    ret=$?
    if [ $ret -ne 0 ]
    then
        exitOnError "Restart on ssws had errors"
    fi
    logMsg "Restarting SSWS - done"
}

restartMON()
{
    logMsg "Restarting MON"
    cdbinary=/home/mon${_service}/bin/${_cd}
    commandParams="mon ${_service} -cluster primary -force restart"
    debugMsg "Running ${cdbinary} ${commandParams}"
    ${cdbinary} ${commandParams} << EOF
$_masterPassword
EOF
    logMsg "Restarting MON - done"
}

