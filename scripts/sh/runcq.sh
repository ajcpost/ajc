#!/bin/sh

###############################################################################
# Wrapper script to execute CQ tests during RU.
# 
# CQ (Cluster qual) use-cases
# ---------------------------
# Doing CQ for dynamic capacity consists of two main use-cases
# - capacityChange: via RU when builds differ in topology/capacity
# - realmRebalance: via RR for new version of RC (realm-community) mappings
# 
# To test these use-cases on a continual basis, it's necessary that
# new builds differ in topology and/or RC mappings from the currently 
# installed build. While it may work for few build cycles, it's not 
# sustainable given that the physical infrastructure is static and will 
# run out of capacity. 
#
# Below outlines an approach to test these use-cases even when RC builds
# don't differ in topology and/or RC mappings. The approach is completely
# automated, enabling CQ run on a daily basis.
# 
#
# capacityChange 
# --------------
# The change is simulated using dummy build configurations which are pre set
# test configurations "per" product & service and are applied to the old and 
# new build.
# (1) pre-test: This is the configuration to which currently installed build 
#     is moved to before starting RU. 
# (2) Scenario based (e.g. addhost): This is the configuration applied to
#     the new build before doing an upgrade to it. This is based on the
#     test scenarios to be executed, e.g. add host.
#
# Deployed images of the currently installed build and the new build are
# modified so that perl scripts point to these dummy build configuration rather 
# than what's built in RC. 
#
# See runIntegratedUC() for details on the actual steps.
#
# Sample command:
# runcq.sh -s itg -p buyer -u capacityChange -o SSPR3-580 -n SSPR3-583 -t all -m -d | tee <output log>
#
# realmRabalance
# --------------
# Prior to running rolling restart on the currently installed build, realms are 
# added and rebalanced to simulate new RC mappings. Over a period, this will 
# overflow the number of realms a build can support so it's expected that periodic
# restore&migrate will help clean this up.
#
# See runRealmRebalane() for details on the actual steps.
#
# Sample command:
# runcq.sh -s itg -p buyer -u realmRebalance -t all -m -d | tee <output log>
#
# capacityChange+realmRebalance
# -----------------------------
# This is an intgrated scenario wherein both RU and RR are run one after other
# to simulate a capacityChange first and then realmRebalance.
# 
# See runIntegratedUC() for details on the actual steps.
#
# Sample command:
# runcq.sh -s itg -p buyer -u integrated -o SSPR3-580 -n SSPR3-583 -t all -m -d | tee <output log>
#
###############################################################################


sourceUtilScript()
{
    ### Figure out where the script resides
    ### and source the utility script
    cwd=`pwd`
    scriptHome=$(cd `dirname ${0}`; pwd)
    cd ${cwd}
    source ${scriptHome}/runcq_util.sh
}

setECBPath()
{
    buildRoot=$1
    command=$2
    _ecbPath=${buildRoot}/${_cqTestDataDir}/${_product}${_service}/${_cqTest}/EventCallbackParameters_${command}.table
}

setCurBuild()
{
    ## Use -P option to resolve the link to real path
    cwd=`pwd`
    cd -P "${_svcRoot}/${_product}/config"
    cd ..
    _curBuildRoot=`pwd`
    _curBuild=`basename ${_curBuildRoot}`
    cd ${cwd}
}

exportSeleniumSettings()
{
    ### Sed expression below replaces tabs, newlines, space etc with a single space
    ### See http://serverfault.com/questions/431167/sed-replace-all-tabs-and-spaces-with-a-single-space
    ### Reproduced below:
    ### [   # start of character class
    ###     [:space:]  The POSIX character class for whitespace characters. It's
    ###                functionally identical to [ \t\r\n\v\f] which matches a space,
    ###                tab, carriage return, newline, vertical tab, or form feed.
    ### ]   # end of character class
    ### \+  # one or more of the previous item (anything matched in the brackets).

    rolesFile=${_curBuildRoot}/config/roles.cfg
    host=`cat ${rolesFile} | grep -i seleniumrc | sed -e "s/[[:space:]]\+/ /g" | cut -d " " -f2`
    logMsg "Setting ARIBA_SELENIUM_RC_HOST to ${host}"
    export ARIBA_SELENIUM_RC_HOST=${host}

    appFlagsFile=${_curBuildRoot}/config/appflags.cfg
    port=`cat ${appFlagsFile} | grep -i -A 5 "BEGIN SeleniumRC" | grep BasePort | sed -e "s/[[:space:]]\+//g" | cut -d "=" -f2`
    logMsg "Setting ARIBA_SELENIUM_RC_PORT to ${port}"
    export ARIBA_SELENIUM_RC_PORT=${port}
}

dumpSettings()
{
    logMsg "Service: ${_service}"
    logMsg "Product: ${_product}"
    logMsg "Use case: ${_useCase}"
    logMsg "CQ Tests: ${_cqTest}"
    logMsg "Cur build label: ${_curBuild}"
    logMsg "Old build label: ${_oldBuild}"
    logMsg "New build label: ${_newBuild}"
    logMsg "Restore new build: ${_restoreNewBuildConfig}"
    logMsg "Pause mode: ${_pause}"
    logMsg "Sleep time after CD Stop: ${__sleepIntervalAfterCdStop}"
    logMsg "Sleep time after CD Start/Upgrade: ${_sleepIntervalAfterCd}"
}

initialize()
{
    sourceUtilScript

    read -s -p "Enter Master Password: " _masterPassword
    echo

    logMsg "Initialization"

    while getopts "s:p:u:t:o:n:z:kmd" option; do
      case "$option" in
        s)  _service="$OPTARG";;
        p)  _product="$OPTARG";;
        u)  _useCase="$OPTARG";;
        t)  _cqTest="$OPTARG";;
        o)  _oldBuild="$OPTARG";;
        n)  _newBuild="$OPTARG";;
        z)  _sleepIntervalAfterCd="$OPTARG";;
        k)  _restoreNewBuildConfig="false";;
        m)  _pause="true";;
        d)  _debug="true";;
        ?)  usage;
      esac
    done

    ### Verify primary args
    if [[ (${_service} = "") || (${_product} = "") ||  (${_useCase} = "") ||
          (${_cqTest} = "") || (${_masterPassword} = "") ]]
    then
        usage
    fi

    _svcRoot=/home/svc${_service}
    setCurBuild
    exportSeleniumSettings

    ### Verify sub args
    ### .. in capacityChange/integrated usecase, old/new build args are manadatory.
    ### .. in realmRebalance usecase, old/new build args should not be supplied.
    if [[ ((${_useCase} = ${_capacityUC}) || (${_useCase} = ${_integratedUC})) &&
          (($_oldBuild != "") && ($_newBuild != "")) ]]
    then
        _oldBuildRoot=${_svcRoot}/${_product}/${_oldBuild}
        _newBuildRoot=${_svcRoot}/${_product}/${_newBuild}
        validateBuilds ${_oldBuild} ${_newBuild}
    elif [[ ((${_useCase} == ${_rebalanceUC})) &&
            (($_oldBuild == "") && ($_newBuild == "")) ]]
    then
        _restoreNewBuildConfig=false
    else
        usage
    fi

    dumpSettings
    logMsg "Initialization - done"
}

###############
### Patch build's configuration
### - Backup of the config is taken only if backup dir is not present.
### - Backup of perl src is not taken since it's available in RC area.
### - Cluster must be stopped before doing this.
### - Cluster must be started after doing this.
###############
patchBuildConfig()
{
    build=$1
    buildRoot=$2
    testScenario=$3
    logMsg  "Patching ${buildRoot}"

    ### Take backup of existing config
    buildConfig=${buildRoot}/config
    takeConfigBackup ${buildConfig}

    ### Copy appropriate cq test configuration
    testConfig=${buildRoot}/${_cqTestDataDir}/${_product}${_service}/${testScenario}
    debugMsg "Copying from ${testConfig}/ --> ${buildConfig}"
    cp ${testConfig}/* ${buildConfig}

    ### Edit ArchivedSharedServiceProduct.pm
    inFile=${_rcDeployHome}/${_service}/${_product}/${build}/lib/perl/ariba/rc/ArchivedSharedServiceProduct.pm
    outFile=${buildRoot}/lib/perl/ariba/rc/ArchivedSharedServiceProduct.pm
    inPattern="return \$installDir;"
    outPattern="if (defined \$buildname) \
                {return \"${_svcRoot}\/${_product}\/\$buildname\";} \
                else {return \"${_svcRoot}\/${_product}\";}"
    replacePattern ${inFile} ${outFile} "${inPattern}" "${outPattern}"

    ### Edit InstalledSharedServiceProduct.pm
    inFile=${_rcDeployHome}/${_service}/${_product}/${build}/lib/perl/ariba/rc/InstalledSharedServiceProduct.pm
    outFile=${buildRoot}/lib/perl/ariba/rc/InstalledSharedServiceProduct.pm
    inPattern="return \$installDir;"
    outPattern="if (defined \$buildname) \
                {return \"${_svcRoot}\/${_product}\/\$buildname\";} \
                else {return \"${_svcRoot}\/${_product}\";}"
    replacePattern ${inFile} ${outFile} "${inPattern}" "${outPattern}"

    ### Edit PreCheck.pm
    inFile=${_rcDeployHome}/${_service}/${_product}/${build}/lib/perl/ariba/Ops/PreCheck.pm
    outFile=${buildRoot}/lib/perl/ariba/Ops/PreCheck.pm
    inPattern="sub loadCheck"
    outPattern="sub loadCheck { return 0; }\\n sub oldloadcheck "
    replacePattern ${inFile} ${outFile} "${inPattern}" "${outPattern}"

    logMsg  "Patching ${buildRoot}- done"
}

###############
### Revert build's configuration as per RC image
### - Cluster must be stopped before doing this.
### - Cluster must be started after doing this.
###############
revertBuildConfig()
{
    build=$1
    buildRoot=$2
    logMsg  "Reverting patches from ${buildRoot}"

    ### Restore backup config
    backupConfig=${buildRoot}/config${_backupPrefix}
    debugMsg "Copying from ${backupConfig}/ --> ${buildRoot}/config/"
    cp ${backupConfig}/* ${buildRoot}/config/

    ### Restore edited perl files
    inFile=${_rcDeployHome}/${_service}/${_product}/${build}/lib/perl/ariba/rc/ArchivedSharedServiceProduct.pm
    outFile=${buildRoot}/lib/perl/ariba/rc/ArchivedSharedServiceProduct.pm
    debugMsg "${inFile} --> ${outFile}"
    cp ${inFile} ${outFile}

    inFile=${_rcDeployHome}/${_service}/${_product}/${build}/lib/perl/ariba/rc/InstalledSharedServiceProduct.pm
    outFile=${buildRoot}/lib/perl/ariba/rc/InstalledSharedServiceProduct.pm
    debugMsg "${inFile} --> ${outFile}"
    cp ${inFile} ${outFile}

    inFile=${_rcDeployHome}/${_service}/${_product}/${build}/lib/perl/ariba/Ops/PreCheck.pm
    outFile=${buildRoot}/lib/perl/ariba/Ops/PreCheck.pm
    debugMsg "${inFile} --> ${outFile}"
    cp ${inFile} ${outFile}


    logMsg  "Reverting patches from ${buildRoot} - done"
}

runCD()
{
    build=$1
    buildRoot=$2
    command=$3  # <start|stop|upgrade|restart>
    testScenario=$4

    addlFlags="" 
    ### For upgrade/restart, setup additional flags as necessary
    if [[ (${command} = "upgrade") ]]
    then
        addlFlags="-buildname ${build}" 
        addlFlags="${addlFlags} -clustertest ${_ecbPath}" 
    fi
    if [[ (${command} = "restart") ]]
    then
        addlFlags="${addlFlags} -clustertest ${_ecbPath}" 
    fi

    cdbinary=${buildRoot}/bin/${_cd}
    commandParams="${_product} ${_service} -cluster primary ${command} ${addlFlags}"
    debugMsg "Running ${cdbinary} ${commandParams}"
    ${cdbinary} ${commandParams} << EOF
$_masterPassword
EOF
    ret=$?
    if [ $ret -ne 0 ]
    then
        exitOnError "${command} on ${build} had errors"
    fi

    # Sleep (must during start/upgrade/restart to allow node initialization to complete)
    if [ ${command} = "stop" ]
    then
        logMsg  "Sleeping for ${__sleepIntervalAfterCdStop} seconds"
        sleep ${__sleepIntervalAfterCdStop}
    else
        logMsg  "Sleeping for ${_sleepIntervalAfterCd} seconds"
        sleep ${_sleepIntervalAfterCd}
    fi
}

stopBuild()
{
    setCurBuild
    logMsg  "Stopping ${_curBuild}"
    runCD ${_curBuild} ${_curBuildRoot} stop
    cleanupCluster
    logMsg  "Stopping ${_curBuild} - done"
}

startBuild()
{
    setCurBuild
    logMsg  "Starting ${_curBuild}"
    runCD ${_curBuild} ${_curBuildRoot} start
    logMsg  "Starting ${_curBuild} - done"
}

upgradeBuild()
{
    build=$1
    buildRoot=$2
    testScenario=$3
    logMsg  "Upgrading to ${build}, running cq tests ${testScenario}"
    setECBPath ${buildRoot} RU
    runCD ${build} ${buildRoot} upgrade ${testScenario}
    logMsg  "Upgrading to ${build}, running cq tests ${testScenario} - done"
}

restartBuild()
{
    testScenario=$1
    setCurBuild
    logMsg  "Restarting ${_curBuild}, running cq tests ${testScenario}"
    setECBPath ${_curBuildRoot} RR
    runCD ${_curBuild} ${_curBuildRoot} restart ${testScenario}
    logMsg  "Restarting ${_curBuild}, running cq tests ${testScenario} - done"
}

restoreRCBuild()
{
    setCurBuild
    if [ ${_restoreNewBuildConfig} = "true" ]
    then
        logMsg "Restoring ${_curBuild}"
        takeCTFResultsBackup ${_curBuildRoot}
        stopBuild
        revertBuildConfig ${_curBuild} ${_curBuildRoot}
        restartSSWS
        startBuild
        logMsg "Restoring ${build} - done"

        ### Restart monitoring
        restartMON
    fi
}

runIntegratedUC()
{
    setECBPath ${_newBuildRoot} RU

    ### Move "old (currently_installed)" build to pre-test config.
    stepMsg "UseCase ${_useCase}, moving ${_oldBuild} to pre-test configuration"
    pause "Press ENTER To move ${_oldBuild} to pre-test config..."
    stopBuild
    patchBuildConfig ${_oldBuild} ${_oldBuildRoot} ${_cqPreTest}
    restartSSWS
    startBuild
    stepMsg "UseCase ${_useCase}, moving ${_oldBuild} to pre-test configuration - done"

    ### Add few realms & generate new realm-community version.
    ### Add few more but don't generate new realm-community version.
    ### This step must be done only after old build has been patched and "started".
    stepMsg "UseCase ${_useCase}, Adding & rebalancing realms"
    pause "Press ENTER To Add realms..."
    addRealmsWithRebalance
    addRealmsWithoutRebalance
    stepMsg "UseCase ${_useCase}, Adding & rebalancing realms - done"

    ### Change "new (to_be_installed)" build to the test scenario config
    stepMsg "UseCase ${_useCase}, Patching ${_newBuild} with ${_cqTest} test config"
    pause "Press ENTER To change ${_newBuild} to ${_cqTest} test config..."
    envSpecificSteps ${_newBuildRoot}
    patchBuildConfig ${_newBuild} ${_newBuildRoot} ${_cqTest}
    stepMsg "UseCase ${_useCase}, Patching ${_newBuild} with ${_cqTest} test config - done"

    ### Start RU to "new (to_be_installed)" build
    stepMsg "UseCase ${_useCase}, Rolling upgrade to ${_newBuild} with ${_cqTest} test config"
    pause "Press ENTER to rolling upgrade to ${_newBuild}..."
    upgradeBuild ${_newBuild} ${_newBuildRoot} ${_cqTest}
    stepMsg "UseCase ${_useCase}, Rolling upgrade to ${_newBuild} with ${_cqTest} test config - done"

    if [[ ${_useCase} == ${_integratedUC} ]]
    then
        ### Start RR on "new build"
        stepMsg "UseCase ${_useCase}, Rolling restart ${_newBuild} with ${_cqTest} test config"
        pause "Press ENTER to rolling restart ${_newBuild}..."
        restartBuild ${_cqTest}
        stepMsg "UseCase ${_useCase}, Rolling restart ${_newBuild} with ${_cqTest} test config - done"
    fi

    ### Restore
    stepMsg "UseCase ${_useCase}, Restoring ${_newBuild} to RC image"
    pause "Press ENTER to restore ${_newBuild} to RC image..."
    restoreRCBuild
    stepMsg "UseCase ${_useCase}, Restoring ${_newBuild} to RC image - done"
}

runRebalanceUC()
{
    setECBPath ${_curBuildRoot} RR

    ### Stop/Start current build before doing a rolling restart. This will bring
    ### the community tab up to date and ensure that all existing realms are allocated
    ### to a community.
    stepMsg "UseCase ${_useCase}, Stopping/Starting ${_curBuild}"
    pause "Press ENTER To stop/start ${_curBuild}..."
    stopBuild
    startBuild
    stepMsg "UseCase ${_useCase}, Stopping/Starting ${_curBuild} - done"

    ### Add few realms & generate new realm-community version.
    ### Add few more but don't generate new realm-community version.
    ### This step must be done only after current build has been stopped and started.
    stepMsg "UseCase ${_useCase}, Adding & rebalancing realms"
    pause "Press ENTER To Add realms..."
    addRealmsWithRebalance
    addRealmsWithoutRebalance
    stepMsg "UseCase ${_useCase}, Adding & rebalancing realms - done"

    ### Start RR on the currently installed build
    stepMsg "UseCase ${_useCase}, Rolling restart ${_curBuild} with ${_cqTest} test config"
    pause "Press ENTER to rolling restart ${_curBuild}..."
    restartBuild ${_cqTest}
    stepMsg "UseCase ${_useCase}, Rolling restart ${_curBuild} with ${_cqTest} test config - done"
}

main ()
{
    initialize $*

    if [[ (${_useCase} = ${_integratedUC}) || (${_useCase} = ${_capacityUC}) ]]
    then
        runIntegratedUC
    elif [[ (${_useCase} = ${_rebalanceUC}) ]]
    then
        runRebalanceUC
    else
       exitOnError "Unsupported use case ${_useCase}"
    fi
    exitOnSuccess
}

main $*
