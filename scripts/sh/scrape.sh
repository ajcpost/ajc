#!/bin/sh

#######################################################################################
### Tool to scrape startup time of a JVM node across two builds. It determins the
### node identity using a combination of host/port/role, finds appropriate log buildAFile
### across both builds and extracts the chrono startup times.
###
### 
### For each log buildAFile in buildA directory
### - extract the role/host/port/community of the node
### - extract various chrono timings from buildA log
### - find relevant log buildAFile from buildB directory using role/host/port combination
### - extract various chrono timings from buildB log
### - dump the timings to a CSV buildAFile
###
### Note
### - Very rudimentary, not many checks, no consideration to performance
### - Heavily dependent on log buildAFile format, will break if format changes
### - Expects fixed directory structure, must run from a directory where
###   build logs are copied.
#######################################################################################

buildA=r3
buildB=13s1

for buildAFile in `ls $buildA`
do
    role=`echo $buildAFile | awk '{split($0,a,"_"); split(a[2],b,"-"); print b[1];}' | sed 's/[0-9]//g'`
    host=`echo $buildAFile | awk '{split($0,a,"--");split(a[1],b,"-");split(b[3],c,"lab1");print c[1]}'`
    port=`cat $buildA/$buildAFile | grep ID3997 | grep "\.Port" | cut -d "=" -f2 | sed "s/(//g" | sed "s/)//g"`
    community=`cat $buildA/$buildAFile | grep ID3997 | grep CommunityID | cut -d "=" -f2 | sed "s/(//g" | sed "s/)//g"`

    if [[ $role != "UI" && $role != "TaskCXML" ]]
    then
        continue
    fi

    echo "Processing buildA $buildAFile $role $host $port $community..."
    buildANumbers=`cat $buildA/$buildAFile | grep duration= | grep "\[ID" | grep -v ID10977 | awk '{split($0,a,"duration="); split(a[1],b,"stop ");split(b[2],c,"\(");split(a[2],d,"s");printf d[1]; printf " "}'`
    numMetric=`echo $buildANumbers | wc -w`
    if [ $numMetric -ne 64 ]
    then
        echo "Problem extracting startup times in $buildA/$buildAFile"
        exit 1
    fi

    #Ports changed between these two builds, so below doesn't work
    #buildBFile=`grep -l "\.Port=($port)"  $buildB/keep*$role*$host*.1`

    # Using community id to find matching nodes doesn't work well if there
    # is more than one node on same host for same role/community.
    # Ok to use temporarily, will skip non UI/Task based metrics
    buildBFile=`grep -l "CommunityID=($community)"  $buildB/keep*$role*$host*.1`
    numMatchingFiles=`echo $buildBFile | wc -w`
    if [ $numMatchingFiles -ne 1 ]
    then
        echo "Problem finding file in buildB, found - $buildBFile "
        exit 1
    fi
    
    echo "Processing buildB $buildBFile $role $host $port $community..."
    buildBNumbers=`cat $buildBFile | grep duration= | grep "\[ID" | grep -v ID10977 | awk '{split($0,a,"duration="); split(a[1],b,"stop ");split(b[2],c,"\(");split(a[2],d,"s");printf d[1]; printf " "}'`
    numMetric=`echo $buildBNumbers | wc -w`
    if [ $numMetric -ne 64 ]
    then
        echo "Problem extracting startup times in $buildB/$buildBFile"
        exit 1
    fi

    # Dump all the metrics to file
    echo "$buildAFile $buildBFile $community $role $buildANumbers "DIV" $buildBNumbers"
done
