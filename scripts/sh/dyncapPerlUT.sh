#!/bin/sh

########################################################################################
# Wrapper script to run Perl Unit tests for Platform R3 dynamic capacity feature.
#
# This feature consists of two main use-cases:
# - capacityChange: via RU when builds differ in topology/capacity
# - realmRebalance: via RR for new version of RC (realm-community) mappings
#
# To support these use-cases, OPS Perl code (C-D and associated perl modules) executes
# a number of additional steps during RU/RR flow. In order to unit test these changes
# it's necessary to have builds that simulate these use-cases. It's sufficient to
# simulate capacityChange since realmRebalance is primarly at Java level except
# modjk configuration which can be tested even without realmRebalance.
# 
# Below outlines the approach to unit test these changes even when RC builds
# don't differ in topology and/or RC mappings. The approach is completely
# automated, requiring execution of just a single command.
#
# Test execution flow
# -------------------
# [1] Tests are started by executing dyncapPerlUT.sh under <install-dir>/tests/dyncap
# [2] The script internally does following:
#     (a) Creates various test-scenario build configurations.
#         - Creates a transient ${_runDir} directory for on the fly builds
#         - This directory is overwritten during each run.
#         - Configuration for on the fly builds is based on the seed data available 
#           in ${_testDir} directory, and actual product config from <install-dir>
#     (b) Creates copies of few of the OPS Perl scripts and edits these files so
#         that the build root dir points to above on the fly builds.
#     (c) Executes unit tests specified in the testlist file in each build
#         - Details of test execution are logged in a file "runlog" in ${_runData}
#           directory.
#
# [3] Following test configuration builds are currently in use:
#     (a) baseline:      This represents the source (currently installed build).
#     (a) baseline:      Is also used to do RR related tests.
#     (b) addhost:       This simulates the scenario where a host is being added.
#     (c) addcomunity:   This simulates the scenario where a new community is 
#                        being added.
#     (d) addindefault:  This simulates the scenario where new nodes are being 
#                        added to the default community.
#     (e) replacehost:   This simulates the scenario where a host is being replaced. 
#     (f) all:           This simulates all of above.
#
# [4] Following test cases are currently available:
#     (a) modjk.t:              Test modjk config generation during bucket 0/1 down.
#     (b) appinstancemanager.t: Test for port clashes, duplicate names between app
#                               instances of two builds.
#     (c) l2pmap.t:             Test l2pmap file generation during bucket 0/1 down.
#     (d) topologymanager.t:    Test some of orchestration steps during RU.

# Sample usage
# ------------
# [1] robot354@buildbox354> <install_dir>/tests/dyncap/dyncapPerlUT.sh -p buyer -s personal_robot354
#     Run all perl unit tests for buyer product, on personal_robot354 directory
# [2] [svcitg@snipe ~]$ <install_dir>/tests/dyncap/dyncapPerlUT.sh -p s4 -s itg -t modjk.t,topologymanager.t -n all,addhost -d
#     Run perl unit tests (modjk.t,topologymanager.t) for scenarions (all,addhost)
#     for s4 product, on itg service. Log additional debug output.
#     Note that if build's testlist file doesn't contain any of the specified test case, it's skipped.
# [3] Individual tests can directly be invoked via perl, so long as i${_runDir} folder is 
#     created with required test builds.
#     cd to <install_dir>/tests/dyncap
#     perl ${_testDir}/testcases/modjk.t buyer personal_robot354 baseline all
########################################################################################


sourceUtilScript()
{
    ### Figure out where the script resides
    ### and source the utility script
    cwd=`pwd`
    _scriptHome=$(cd `dirname ${0}`; pwd)
    cd ${cwd}
    source ${_scriptHome}/dyncapPerlUTUtil.sh
}

setPaths()
{
    ### Get the installed build
    ### Script assumed to be in <install-dir>/tests/dyncap

    ### Use -P option to resolve the link to real path
    cwd=`pwd`
    cd -P ${_scriptHome}/../../
    _curBuildRoot=`pwd`
    _curBuild=`basename ${_curBuildRoot}`
    cd ${cwd}
    
    ### - On robots, it's safe to use installed build location.
    ### - On service, it's best to point to RC image because CQ may be running
    ###   on service and may have already edited the installed build's config
    ###   or perl scripts
    if [[ ! -z $(echo ${_service} | grep personal) ]]
    then
        # /home/robot355/archive/deployments/personal_robot355/buyer/SSPR3-775/tests/dyncap
        _rcDeployPath=${_scriptHome}/../../
    else
        _rcDeployPath=/home/rc/archive/deployments/${_service}/${_product}/${_curBuild}
    fi
}

dumpSettings()
{
    logMsg "Service: ${_service}"
    logMsg "Product: ${_product}"
    logMsg "Script home: ${_scriptHome}"
    logMsg "Input test cases: ${_inputTestCases}"
    logMsg "Destination builds: ${_destBuilds}"
    logMsg "RC Deploy Path : ${_rcDeployPath}"
    logMsg "PERLLIB set to : ${PERLLIB}"
    logMsg "PERL5LIB set to : ${PERL5LIB}"
}

createTestBuilds()
{
    logMsg "Creating test builds"

    ### First, take what exists in seed builds
    mkdir ${_scriptHome}/${_runDir}/builds
    cp -R ${_scriptHome}/${_testDir}/builds/* ${_scriptHome}/${_runDir}/builds
    chmod -R +w ${_scriptHome}/${_runDir}/builds

    ### Now, shape up the entire build by pulling together other config and perl scripts
    allBuilds="${_srcBuild} ${_destBuilds}"
    for build in ${allBuilds}
    do
        logMsg "Creating build ${build}"
        # Copy test config files
        params="${_scriptHome}/${_testDir}/builds/${build}/config/${_product}/* ${_scriptHome}/${_runDir}/builds/${build}/config"
        debugMsg "Copying ${params}"
        cp ${params}

        # Create docroot directory structure
        params="${_scriptHome}/${_runDir}/builds/${build}/docroot/topology/${_product}"
        debugMsg "Creating ${params}"
        mkdir -p ${params}

        # Copy other config files from the current build
        src="${_scriptHome}/../../config"
        dest="${_scriptHome}/${_runDir}/builds/${build}/config"
        debugMsg "Copying following config files from ${src} to ${dest}"
        debugMsg "files: ${_configFiles}"
        for file in ${_configFiles}
        do
            cp ${src}/${file} ${dest}
        done

        logMsg "Creating build ${build} - done"
    done

    logMsg "Creating test builds - done"
}

createScripts()
{
    logMsg "Creating perl scripts"

    ### First take the seed perl scripts as is.
    mkdir -p ${_scriptHome}/${_runDir}/lib/ariba/rc
    cp -R ${_scriptHome}/${_testDir}/lib/* ${_scriptHome}/${_runDir}/lib
    chmod -R +w ${_scriptHome}/${_runDir}/lib

    ### Edit the perl as required
    ### It's necessary to use RC path so even if installed build is modified during 
    ### CQ, it has no effect.

    # ArchivedSharedServiceProduct.pm
    inFile=${_rcDeployPath}/lib/perl/ariba/rc/ArchivedSharedServiceProduct.pm
    outFile=${_scriptHome}/${_runDir}/lib/ariba/rc/ArchivedSharedServiceProduct.pm
    inPattern="return \$installDir"
    outPattern="if (defined \$buildname) {return \"${_scriptHome}\/${_runDir}\/builds\/\$buildname\";} else {return \"${_scriptHome}\/${_runDir}\/builds\";}"
    replacePattern ${inFile} ${outFile} "${inPattern}" "${outPattern}"

    # InstalledSharedServiceProduct.pm
    inFile=${_rcDeployPath}/lib/perl/ariba/rc/InstalledSharedServiceProduct.pm
    ts=`date +%Y%m%d_%H%M`
    outFile=/tmp/InstalledSharedServiceProduct.pm_temp_${ts}
    inPattern="return \$installDir"
    outPattern="if (defined \$buildname) {return \"${_scriptHome}\/${_runDir}\/builds\/\$buildname\";} else {return \"${_scriptHome}\/${_runDir}\/builds\";}"
    replacePattern ${inFile} ${outFile} "${inPattern}" "${outPattern}"

    # InstalledSharedServiceProduct.pm, change#2
    tempInputFile=/tmp/InstalledSharedServiceProduct.pm_temp_${ts}
    outFile=${_scriptHome}/${_runDir}/lib/ariba/rc/InstalledSharedServiceProduct.pm
    inPattern="return ( -d \"\$dir/config/\" && -f \"\$dir/config/BuildName\" )"
    outPattern="return \"true\"";
    replacePattern ${tempInputFile} ${outFile} "${inPattern}" "${outPattern}"
    rm ${tempInputFile}

    # AppIntanceManagr.pm
    inFile=${_rcDeployPath}/lib/perl/ariba/rc/AppInstanceManager.pm
    outFile=${_scriptHome}/${_runDir}/lib/ariba/rc/AppInstanceManager.pm
    inPattern="cannot resolve \$host to it ip address"
    outPattern=""
    replacePattern ${inFile} ${outFile} "${inPattern}" "${outPattern}"

    logMsg "Creating perl scripts - done"
}


setTestEnvironment()
{
    logMsg "Setting environment for the test run"

    ### Create a brand new rundata for this run
    chmod +w ${_scriptHome}
    params="${_scriptHome}/${_runDir}"
    debugMsg "Creating run directory - ${params}"
    rm -rf ${params}
    mkdir ${params}

    ### Point PERL path to include the run time perl scripts location
    export PERLLIB=${_scriptHome}:${_scriptHome}/${_runDir}/lib:${_scriptHome}/../../lib/perl:${PERLLIB}
    export PERL5LIB=${_scriptHome}:${_scriptHome}/${_runDir}/lib:${_scriptHome}/../../lib/perl:${PERL5LIB}

    createTestBuilds
    createScripts

    logMsg "Setting environment for the test run - done"
}


initialize()
{
    sourceUtilScript
    logMsg "Initializing"

    ### Read command line arguments
    inputDestBuilds=""
    inputTestCases=""
    while getopts "p:s:t:n:d" option; do
      case "$option" in
        p)  _product="$OPTARG";;
        s)  _service="$OPTARG";;
        t)  inputTestCases="$OPTARG";;
        n)  inputDestBuilds="$OPTARG";;
        d)  _debug="true";;
        ?)  usage;
      esac
    done

    ### Verify args
    if [[ (${_product} = "")  || (${_service} = "")]]
    then
        exitWithUsage "Product and/or service not supplied"
    fi

    ### Override default input test cases if supplied on commandline
    if [[ ${inputTestCases} != "" ]]
    then
        _inputTestCases=`echo ${inputTestCases} | sed "s:,: :g"`
    fi

    ### Override default destination builds if supplied on commandline
    if [[ ${inputDestBuilds} != "" ]]
    then
        _destBuilds=`echo ${inputDestBuilds} | sed "s:,: :g"`
    fi

    setPaths
    setTestEnvironment
    dumpSettings
    logMsg "Initializing - done"
}

canRunTest()
{
    testCase=$1
    _canRun="false"

    if [[ ${_inputTestCases} != "" ]]
    then
        # When test cases are specified on command line, see if current
        # test is part of it.
        for tc in ${_inputTestCases}
        do
            if [[ ${tc} == ${testCase} ]]
            then
                _canRun="true"
            fi
        done
    else
        # When no test cases on command line, always run it
        _canRun="true"
    fi
}

runTests()
{
    logMsg "Running perl tests"
    
    runLog=${_scriptHome}/${_runDir}/run.log
    logMsg "Output from tests will be logged to ${runLog}"

    ### Run tests for each of the destination build.
    for build in ${_destBuilds}
    do
        buildTestCases=`cat ${_scriptHome}/${_testDir}/builds/${build}/testlist`
        logMsg "Source build ${_srcBuild}, destination build ${build}, build testcases: ${buildTestCases}" >> ${runLog}
        for test in ${buildTestCases}
        do
            canRunTest ${test}
            if [[ ${_canRun} == "true" ]]
            then
                logMsg "Executing test -- ${test}" >> ${runLog}
                ${_perl} ${_scriptHome}/${_testDir}/testcases/${test} ${_product} ${_service} ${_srcBuild} ${build} >> ${runLog} 2>&1
            else
                logMsg "Skipping test -- ${test}" >> ${runLog}
            fi
        done
    done

    ### Verify that tests succeeded.
    for pattern in ${_errorPatterns}
    do
        debugMsg "Checking ${pattern} in ${runLog}"
        if [[ (`grep -c -i ${pattern} ${runLog}` -ne 0) ]]
        then
            exitOnError "Running perl tests - done with failures, see ${runLog} for details"
        fi
    done

    exitOnSuccess "Running perl tests - done with success, see ${runLog} for details"
}


main()
{
    initialize $*
    runTests
}

main $*
