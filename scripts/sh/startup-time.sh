#!/bin/sh

#######################################################################################
### Tool to compare chrono startup time of a JVM node across two builds. It determins the
### node identity using a combination of host/port/role, finds appropriate log buildAFile
### across both builds and extracts the chrono startup times.
###
### 
### For each log file in buildA directory
### - extract the role/host/port/community of the node
### - extract various chrono timings from the log
### - find matching log file from buildB directory using role/host/port combination
### - extract various chrono timings from buildB log
### - dump timings to a space separated file
###
### Notes
### - See end of file for metrics captured
### - Works for S4 logs, Buyer will require tweaks for startup time, e.g. update "ASM Elapsed"
### - Very rudimentary, not many checks, no consideration to performance
### - Heavily dependent on log format, will break if format changes
### - Expects fixed directory structure, must run from a directory where
###   logs from two builds are copied.
### - Will fast fail rather than giving wrong data, e.g. if not all metrics are
##    captured or if matching log file is not found, etc.
#######################################################################################

buildA=before-patch
buildB=after-patch

for buildAFile in `ls $buildA`
do
    role=`echo $buildAFile | awk '{split($0,a,"_"); split(a[2],b,"-"); print b[1];}' | sed 's/[0-9]//g'`
    node=`echo $buildAFile | awk '{split($0,a,"--"); split(a[2],b,"-"); print b[1];}'`
    host=`echo $buildAFile | awk '{split($0,a,"--");split(a[1],b,"-");split(b[3],c,"lab1");print c[1]}'`
    port=`cat $buildA/$buildAFile | grep ID3997 | grep "$node\.Port" | cut -d "=" -f2 | sed "s/(//g" | sed "s/)//g"`
    community=`cat $buildA/$buildAFile | grep ID3997 | grep CommunityID | cut -d "=" -f2 | sed "s/(//g" | sed "s/)//g"`

    #if [[ $role != "UI" && $role != "TaskCXML" ]]
    #then
    #    continue
    #fi

    echo "Processing buildA $buildAFile $role $host $port $community..."
    buildAStartTime=`cat $buildA/$buildAFile | grep ID5411 | grep "on com" | awk '{split($0,a,"ASM Elapsed time: ");split(a[2],b," ");printf b[1]}'`
    buildAMinorGC=`cat $buildA/$buildAFile | awk '/\[ID9393\]: Base phase start /{ mark=1 }/\[ID5411\]: Initialization complete/{ mark=0 }; mark;' | grep "\[GC " | wc -l`
    buildAFullGC=`cat $buildA/$buildAFile | awk '/\[ID9393\]: Base phase start /{ mark=1 }/\[ID5411\]: Initialization complete/{ mark=0 }; mark;' | grep "\[Full GC " | wc -l`
    buildADurations=`cat $buildA/$buildAFile | grep duration= | grep "\[ID" | grep -v ID10977 | awk '{split($0,a,"duration="); split(a[1],b,"stop ");split(b[2],c,"\(");split(a[2],d,"s");printf d[1]; printf " "}'`
    numMetric=`echo $buildADurations | wc -w`
    if [ $numMetric -ne 64 ]
    then
        echo "Problem extracting startup times in $buildA/$buildAFile"
        exit 1
    fi

    # Ports changed between these two builds, so below doesn't work
    # Because of above, using community id to find matching nodes. This doesn't
    # work if theere is more than one node on same host for same role/community.
    # Ok to use temporarily, will skip non UI/Task based metrics.
    echo "Searching ... grep -l \.Port=($port)  $buildB/keep*$host*$role*.1"
    buildBFile=`grep -l "\.Port=($port)"  $buildB/keep*$host*$role*.1`
    #buildBFile=`grep -l "CommunityID=($community)"  $buildB/keep*$host*$role*.1`
    numMatchingFiles=`echo $buildBFile | wc -w`
    if [ $numMatchingFiles -ne 1 ]
    then
        echo "Problem finding matching log file in buildB, found - $buildBFile "
        exit 1
    fi
    
    echo "Processing buildB $buildBFile $role $host $port $community..."
    buildBStartTime=`cat $buildBFile | grep ID5411 | grep "on com" | awk '{split($0,a,"ASM Elapsed time: ");split(a[2],b," ");printf b[1]}'`
    buildBMinorGC=`cat $buildBFile | awk '/\[ID9393\]: Base phase start /{ mark=1 }/\[ID5411\]: Initialization complete/{ mark=0 }; mark;' | grep "\[GC " | wc -l`
    buildBFullGC=`cat $buildBFile | awk '/\[ID9393\]: Base phase start /{ mark=1 }/\[ID5411\]: Initialization complete/{ mark=0 }; mark;' | grep "\[Full GC " | wc -l`
    buildBDurations=`cat $buildBFile | grep duration= | grep "\[ID" | grep -v ID10977 | awk '{split($0,a,"duration="); split(a[1],b,"stop ");split(b[2],c,"\(");split(a[2],d,"s");printf d[1]; printf " "}'`
    numMetric=`echo $buildBDurations | wc -w`
    if [ $numMetric -ne 64 ]
    then
        echo "Problem extracting startup times in $buildB/$buildBFile"
        exit 1
    fi

    # Dump all the metrics to file
    echo "$buildA/$buildAFile $buildBFile $community $role $buildAStartTime $buildAMinorGC $buildAFullGC $buildADurations DIV $buildBStartTime $buildBMinorGC $buildBFullGC $buildBDurations"
done


#######################################################################################
# Chrono metrics captured
# -----------------------
#"Startup time"
#"Minor GC count"
#"Full GC count"
#"Initialize logging "
#"Initialize base cache "
#"Initialize Nodes "
#"Init BaseService "
#"Verify AribaDBCharset "
#"Init Global Locking "
#"Initialize server implementation "
#"Initialize public Application information "
#"Initialize safe java repository "
#"Init CCM "
#"Init database monitor "
#"Process intrinsic metadata "
#"Realm load parameters and get Schema "
#"Initialize runtime and services "
#"Validate variant configuration "
#"Process extrinsic metadata "
#"Finalize Layout "
#"Initialize Field Dependency Map "
#"Initialize Class Codes - default "
#"Initialize Class Codes - node init "
#"Initialize Class Codes - optimize "
#"Initialize/start metrics "
#"Initialize language ids cache "
#"Validate Behavior "
#"Initialize object model "
#"Check default language "
#"Initialize realm to node affinity "
#"Initialize user limit enforcement "
#"Register RPC listener "
#"Initialize event manager "
#"Initialize inspector modules "
#"Set register EJB delegate "
#"Registering Log State Observer "
#"Init Datacenter parameters "
#"Init metadata runtime reloading "
#"Init OSGi container "
#"Initialize Java Scripting "
#"Initialize SMTP Service "
#"Initialize CDS Service "
#"Initialize Service Implementations "
#"Register Custom Initializations "
#"Initialize PubSub Service "
#"Initialize logging "
#"Initialize Audit Service "
#"Initialize Exception Trap Service "
#"Initialize Encoding Map "
#"Initialize Backplane Service "
#"Initialize AribaSystem user "
#"Configure scheduled tasks "
#"Initialize ServerModule: ariba.auth.server.AuthSM "
#"Initialize ServerModule: ariba.user.server.UserSM "
#"Initialize ServerModule: ariba.basic.server.BasicSM "
#"Initialize ServerModule: ariba.admin.server.AdminSM "
#"Initialize ServerModule: ariba.collaborate.server.CollaborateSM "
#"Initialize ServerModule: ariba.analytics.server.AnalyticsSM "
#"Initialize ServerModule: ariba.sourcing.server.SourcingSM "
#"Initialize Java Scripting "
#"Initialize Variant Rules "
#"Initialize AMF "
#"Start AMF "
#"Finish initializing AMF schedulers "
#"Assigning nodes for schedulers "
#"Schedule scheduled tasks "
#"Schedule AMF tasks "
#######################################################################################
