#!/usr/bin/perl -w
##########################################################################
### Copyright (c) 2013 Ariba, Inc.
### All rights reserved. 
###
### $Id: //ariba/platform/tools/validateRCVers.pl# $
### Responsible: achitale
### 
### Utility to validate RC version across cluster nodes. The tool does 
### following validations:
### (1) All AppInstances must have RC version as per the version in
###     BucketStateTab table.
### (2) If cluster is not undergoing RealmRebalance, both buckets must
###     be on the same RC version. If cluster is undergoing RealmRebalance
###     bucket0 must have newer version than bucket1.
### (3) Buckets may not necessarily be on latest RC version, this is
###     reported but not as an error.
##########################################################################
 

use strict;
use FindBin;
use lib ("$FindBin::Bin", "$FindBin::Bin/../bin", "$FindBin::Bin/../lib", "$FindBin::Bin/../lib/perl");
use ariba::rc::InstalledProduct;
use ariba::Ops::Startup::Common;
use ariba::rc::Globals;
use ariba::rc::Passwords;
use ariba::Ops::Url;
use ariba::Ops::DBConnection;
use ariba::Ops::OracleClient;
use Getopt::Long;
use File::Path;
use List::Util 'first';
use XML::XPath;
use XML::XPath::XMLParser;

my $RC_VERSION_FIELD        = "RCVersion";
my $CLUSTER_STATE_COMPLETE  = "Complete";
my $CLUSTER_STATE_REBALANCE = "RealmRebalance";
my $CLUSTER_STATE_SQL       = "select transitionstate from clustertransitiontab";
my $BUCKET_RC_SQL           = "select realmtocommunityversion from bucketstatetab where bucket=";
my $LATEST_RC_SQL           = "select max(version) from communitytab";

my $debug = 0;

sub usage {
    print "usage: $0 -product <product name> -service<service> [-cluster <cluster> -debug]\n"; 
    print "    -product : Required, Name of the product (buyer, s4)\n"; 
    print "    -service : Required, Name of the service (itg, dev3) \n"; 
    print "    -cluster : Optional, Name of the cluster (primary) \n";
    print "    -debug : Optional, Will log additional output \n";
    exit(ariba::Ops::Startup::Common::EXIT_CODE_ERROR()); 
}

sub logMsg {
    my $msg = shift;
    my $time = localtime;
    print "Log ::" . $time . ":: " . $msg . "\n";
}

sub debugMsg {
    my $msg = shift;
    my $time = localtime;
    if ($debug) {
        print "Debug ::" . $time . ":: " . $msg . "\n";
    }
}

sub installedProduct {
    my ($productName, $serviceName) = @_;
    my $product;
    if (ariba::rc::InstalledProduct->isInstalled($productName, $serviceName)) {
        $product = ariba::rc::InstalledProduct->new($productName, $serviceName);
    } else {
        die "Unable to find product: $productName on service : $serviceName\n";
    }
    return $product;
}

sub dumpMismatchedNodes {
    my ($bucket, $bucketRC, $refMap, @mismatchedNodes) = @_;
    my %nodeRCVersionMap = %$refMap;
    
    if (scalar (@mismatchedNodes)) {
        logMsg ("<<ERR>> Not all Bucket " . $bucket . " nodes are on RC version " . $bucketRC);
        my $msg = "[ ";
        foreach my $ai (@mismatchedNodes) {
            $msg .=  "[" . $ai->logicalName() . "," . $ai->instanceName() . "," . $nodeRCVersionMap{$ai->logicalName()} . "]";
        }
        $msg .= " ]";
        debugMsg($msg);
    }
}

sub compareNodeAndBucketVersions {
    my ($bucket0RC, $bucket1RC, $refMap, $product) = @_;

    logMsg("Comparing Node RC versions...");
    my %nodeRCVersionMap = %$refMap;
    my @appInstances = $product->appInstances();
    @appInstances = grep { $_->isTomcatApp()} @appInstances;

    my @B0MismatchedNodes;
    my @B1MismatchedNodes;
    my $ai;
    foreach $ai (@appInstances) {
        my $nodeRC = $nodeRCVersionMap{$ai->logicalName()};
        my $expectedRC = ($ai->recycleGroup() == 0) ? $bucket0RC : $bucket1RC;
        if ($nodeRC != $expectedRC) {
            my $mismatchedNodes = ($ai->recycleGroup() == 0) ? \@B0MismatchedNodes : \@B1MismatchedNodes;
            push @{$mismatchedNodes}, $ai;
         }
    }
    dumpMismatchedNodes (0, $bucket0RC, $refMap, @B0MismatchedNodes);
    dumpMismatchedNodes (1, $bucket1RC, $refMap, @B0MismatchedNodes);
    logMsg ("Comparing Node RC versions...done");
    my $ret = (scalar (@B0MismatchedNodes) | scalar (@B1MismatchedNodes)) ? 1 : 0;
    return $ret;
}

sub compareBucketVersions {
    my ($clusterState, $bucket0RC, $bucket1RC, $latestRC) = @_;

    logMsg ("Comparing Bucket versions...");
    my $ret;

    if (uc $clusterState eq uc $CLUSTER_STATE_REBALANCE) {
        ($bucket0RC > $bucket1RC) ? ($ret = 0) : ($ret = 1);
        logMsg ("<<ERR>> Bucket0 is not on newer RC version") if ($ret);
    }
    elsif (uc $clusterState eq uc $CLUSTER_STATE_COMPLETE) {
        ($bucket0RC == $bucket1RC) ? ($ret = 0) : ($ret = 1);
        logMsg ("<<ERR>> Buckets do not have same RC version") if ($ret == 1);

        if ($bucket0RC != $latestRC || $bucket1RC != $latestRC) {
            logMsg ("<<WARN>> Buckets are not on the latest RC version");
        }
    }

    logMsg ("Comparing Bucket versions...done");
    return $ret;
}

sub getDBRCVersions {
    my $product = shift;

    my ($tx) = ariba::Ops::DBConnection->connectionsFromProducts($product);
    my $oracleClient = ariba::Ops::OracleClient->new($tx->user(), $tx->password(), $tx->sid(), $tx->host());
    $oracleClient->connect();

    my $clusterState = $oracleClient->executeSql ($CLUSTER_STATE_SQL);
    my $bucket0RC = $oracleClient->executeSql ($BUCKET_RC_SQL . 0);
    my $bucket1RC = $oracleClient->executeSql ($BUCKET_RC_SQL . 1);
    my $latestRC = $oracleClient->executeSql ($LATEST_RC_SQL);
    $oracleClient->disconnect();

    return ($clusterState, $bucket0RC, $bucket1RC, $latestRC);
}

sub getNodeRCVersions {
    my $product = shift;
    my @appInstances = $product->appInstances();
    @appInstances = grep { $_->isTomcatApp()} @appInstances;
    my %resultMap = { };
 
    for my $appInstance (@appInstances) {
        my $logicalName = $appInstance->logicalName();
        my $urlString = $appInstance->monitorStatsURL();
        my $request = ariba::Ops::Url->new($urlString);
        my @allFields = $request->request(60);

        ### XML output (@allFields) is of the format:
        ###     <?xml version="1.0"?>
        ###     <xml>
        ###     <monitorStatus>
        ###     <applicationName>Buyer</applicationName>
        ###     ...
        ###     <RCVersion>5</RCVersion>
        ###     </monitorStatus>
        ###     </xml>
        my $rcVersionLine = first { /$RC_VERSION_FIELD/ } @allFields;
        my $rcVersion = -1;
        if (defined ($rcVersionLine)) {
            my $xp = XML::XPath->new($rcVersionLine);
            my $nodeset = $xp->find('/$RC_VERSION_FIELD');
            foreach my $node ($nodeset->get_nodelist)
            {
               $rcVersion = $node->string_value;
               last;
            }
        }
        $resultMap{$logicalName} = $rcVersion if defined($rcVersion);
    }
    return(%resultMap);
}
 
sub main {
    ### Command parsing & validation
    my ($productName, $serviceName, $cluster, $directory) = @_;
    my $validOptions = GetOptions(
        'product=s' => \$productName,
        'service=s' => \$serviceName,
        'cluster=s' => \$cluster,
        'debug' => \$debug
    );
    if(!defined $productName || !defined $serviceName || !$validOptions) {
        usage(); 
    }

    ### Setup environment
    ariba::rc::Passwords::initialize($serviceName);
    my $product  = installedProduct($productName, $serviceName);
    my $hostname = ariba::Ops::NetworkUtils::hostname();
    $cluster  = "primary" if !defined($cluster);
    ariba::Ops::Startup::Common::initializeProductAndBasicEnvironment($hostname, $cluster);

    ### Fetch RC versions from DB & from Nodes
    logMsg ("Fetching RC versions...");
    my ($clusterState, $bucket0RC, $bucket1RC, $latestRC) = getDBRCVersions($product);
    logMsg ("Cluster is in " . $clusterState . " state , Bucket 0 RC is " . $bucket0RC . 
            ", Bucket 1 RC is " . $bucket1RC . ", Latest RC is " . $latestRC);
    my %nodeRCVersionsMap = getNodeRCVersions($product);
    logMsg ("Fetching RC versions...done");

    ### Do the validations
    my $ret;
    $ret = compareBucketVersions ($clusterState, $bucket0RC, $bucket1RC, $latestRC);
    $ret |= compareNodeAndBucketVersions ($bucket0RC, $bucket1RC, \%nodeRCVersionsMap, $product);
    if ($ret) {
        logMsg ("RC validation failed!!!");
        exit 1;
    }
    logMsg ("RC validation successful!!!");
    exit 0;
}

main();
 
__END__
