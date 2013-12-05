#!/usr/bin/perl -w

##########################################################################
### Copyright (c) 2013 Ariba, Inc.
### All rights reserved. 
###
### $Id: //ariba/platform/tools/config/perl/dc-cleanup.pl#1 $
### Responsible: achitale
### 
### Utility to automate cleanup steps that are to be executed as part of
### MCL if DC RU or RR is aborted. MCL steps are currently detailed
### in the DC FMEA slide-deck:
###      https://wiki.ariba.com:8443/display/ENGDPTS/Dynamic+Capacity
### TODO: Add perforce location of actual MCL steps
###
### -----------------------------------------------------------------------
### option      | capacityChange/RU         |  realmRabalance/RR
### -----------------------------------------------------------------------
### rollback    | a) set cluster transition |  a) set cluster transition
###             |     state to complete     |      state to complete
###             | b) remove l2p files       |          
###             | c) refresh self topology  |          
###             |     for bucket1 nodes     |          
###             |                           |  b) rollback B0 RC version
###             |                           |  c) remove all RC versions
###             |                           |      newer than B1 RC
###             |                           |  d) stop pq receive affinity
### -----------------------------------------------------------------------
### rollforward | a) set cluster transition |  a) set cluster transition
###             |     state to complete     |      state to complete
###             | b) remove l2p files       |          
###             | c) refresh self topology  |          
###             |     for bucket0 nodes     |          
###             |                           |  b) rollforward B1 RC version
###             |                           |  c) stop pq receive affinity
### -----------------------------------------------------------------------
###
##########################################################################
 

use strict;
use FindBin;
use lib ("$FindBin::Bin", "$FindBin::Bin/../bin", "$FindBin::Bin/../lib", "$FindBin::Bin/../lib/perl");
use ariba::rc::InstalledProduct;
use ariba::rc::Utils;
use ariba::Ops::Startup::Common;
use ariba::rc::Globals;
use ariba::rc::Passwords;
use ariba::Ops::Url;
use ariba::Ops::DBConnection;
use ariba::Ops::OracleClient;
use ariba::Ops::L2PMap;
use ariba::Ops::TopologyManager;
use ariba::Ops::PlatformHighTopologyManager;
use Getopt::Long;
use Term::ReadKey;

my $RU           = "ru";
my $RR           = "rr";
my $ROLLBACK     = "rollback";
my $ROLLFORWARD  = "rollforward";
my $CONTINUE     = "continue";
my $SQL_GETRC    = "select realmtocommunityversion from bucketstatetab where bucket = ";
my $SQL_SETRC    = "update bucketstatetab set realmtocommunityversion = "; 
my $SQL_DELRC    = "delete from communitytab where version > ";
my $SQL_SETCT   = "update clustertransitiontab set transitionstate = ";
my $bucket0      = 0;
my $bucket1      = 1;
my $manualAction = 0;
my $devlab       = 0;

### Function pointers to cleanup steps
my %cleanups = (
    "rollbackCleanupForRU"     => \&rollbackCleanupForRU,
    "rollforwardCleanupForRU"  => \&rollforwardCleanupForRU,
    "rollbackCleanupForRR"     => \&rollbackCleanupForRR,
    "rollforwardCleanupForRR"  => \&rollforwardCleanupForRR
);

sub usage {
    print "usage: $0 -product <product name> -service<service> \n";
    print "          -usecase <$RU|$RR> \n";
    print "          -action <$ROLLFORWARD|$ROLLBACK>\n";
    print " -product  : Required, Name of the product (buyer, s4)\n"; 
    print " -service  : Required, Name of the service (itg, dev3) \n"; 
    print " -usecase  : Required, Name of the usecase ($RU, $RR>\n"; 
    print " -action   : Required, Name of the action ($ROLLFORWARD, $ROLLBACK)\n"; 
    exit(ariba::Ops::Startup::Common::EXIT_CODE_ERROR()); 
}

sub logMsg {
    my $msg = shift;
    my $time = localtime;
    print "Log ::" . $time . ":: " . $msg . "\n";
}

sub pause {
    while (ReadKey(-1)) { } # drain STDIN of previous input
    my $answer;
    do  {
        print "\n";
        print "Please involve engineering to take corrective actions\n";
        print "Enter '$CONTINUE' once corrective actions are taken\n";
        $answer = <STDIN>;
    } until ($answer =~ /^(?:$CONTINUE)$/i);

    ## Set global flag to indicate there was manual intervention
    $manualAction=1;
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

sub removeL2PMapFiles {
    my ($product, $sswsProduct) = @_;

    my $subName = (caller(0))[3];
    logMsg ("$subName ...");

    my $user = ariba::rc::Globals::deploymentUser($product->name(), $product->service());
    my $l2pFile = ariba::Ops::L2PMap::getL2PFilePath($sswsProduct, $product->name()) ;
    my @webServerHosts = $product->hostsForRoleInCluster("httpvendor", $product->currentCluster());
    logMsg ("L2P file: $l2pFile, Web Servers: @webServerHosts");
    my @failedHosts;
    for my $host (@webServerHosts) {
        my $ret = ariba::rc::Utils::removeFile($host, $user, $l2pFile);
        push @failedHosts, $host if (!$ret); ### ret is 0 for failures

        # On shared file system, skip after first delete
        if ($devlab) {
            last;
        }
    }
    if (scalar (@failedHosts)) {
        logMsg ("Failed to remove $l2pFile from @failedHosts");
        pause();
    }

    logMsg ("$subName done.");
}

sub executeSql {
    my ($product, $sql) = @_;
    my $ret = 0;
    my $value = 0;

    my ($tx) = ariba::Ops::DBConnection->connectionsFromProducts($product);
    my $oracleClient = ariba::Ops::OracleClient->new($tx->user(), $tx->password(), $tx->sid(), $tx->host());
    $oracleClient->connect();

    logMsg ("Executing $sql");
    $value = $oracleClient->executeSql ($sql);
    if ($oracleClient->error()) {
        logMsg ("Failed to execute $sql, error is " . $oracleClient->error());
        $ret = 1;
        pause();
    }
    $oracleClient->disconnect();
    return ($ret, $value);
}

sub setClusterStateToComplete {
    my $product = shift;

    my $subName = (caller(0))[3];
    logMsg ("$subName ...");

    executeSql ($product, $SQL_SETCT . "'Complete'");

    logMsg ("$subName done.");
}

sub setBucketRCVersion {
    my ($product, $bucket, $version) = @_;

    my $subName = (caller(0))[3];
    logMsg ("$subName ...");

    executeSql ($product, $SQL_SETRC . $version . " where bucket = " . $bucket);
 
    logMsg ("$subName done.");
}

sub rollbackRCVersion {
    my ($product) = @_;

    my $subName = (caller(0))[3];
    logMsg ("$subName ...");

    my ($ret, $bucket1RC) = executeSql ($product, $SQL_GETRC . $bucket1);
    if (!$ret) {
        setBucketRCVersion ($product, $bucket0, $bucket1RC);
    }

    logMsg ("$subName done.");
}

sub rollforwardRCVersion {
    my ($product) = @_;

    my $subName = (caller(0))[3];
    logMsg ("$subName ...");

    my ($ret, $bucket0RC) = executeSql ($product, $SQL_GETRC . $bucket0);
    if (!$ret) {
        setBucketRCVersion ($product, $bucket1, $bucket0RC);
    }

    logMsg ("$subName done.");
}

sub removeNewerRCVersions {
    my ($product) = @_;

    my $subName = (caller(0))[3];
    logMsg ("$subName ...");

    my ($ret, $currentRC) = executeSql ($product, $SQL_GETRC . $bucket1);
    if (!$ret) {
        executeSql ($product, $SQL_DELRC . $currentRC);
    }
 
    logMsg ("$subName done.");
}

sub refreshNodeTopology {
    my ($product, $bucket) = @_;

    my $subName = (caller(0))[3];
    logMsg ("$subName ...");

    ### Fetch instances from the passed bucket
    my @appInstances = $product->appInstances();
    my @appInstancesInBucket = grep { $_->recycleGroup() == $bucket } @appInstances;

    ### Execute the DA
    my $refreshTopologyDA="refreshTopologyAction";
    my @expectedResponse = qw(OK);
    logMsg ("Executing DA $refreshTopologyDA on nodes in bucket $bucket");
    my ($ret,$failedNodesRef) = ariba::Ops::PlatformHighTopologyManager::executeDirectAction($refreshTopologyDA, \@expectedResponse,\@appInstancesInBucket);
    if ($ret) {
        logMsg ("DA $refreshTopologyDA failed on hosts @{$failedNodesRef}");
        pause();
    }

    logMsg ("$subName done.");
}

sub stopPQReceiveAffinity {
    my ($product, $bucket) = @_;

    my $subName = (caller(0))[3];
    logMsg ("$subName ...");

    ### Fetch the QM instances from the passed bucket
    my @appInstances = $product->appInstances();
    my @appInstancesInBucket = grep { $_->recycleGroup() == $bucket } @appInstances;
    my @qmInstancesInBucket = grep { $_->logicalName() =~ /Manager/i } @appInstancesInBucket;

    ### Execute the DA
    my $stopAffinityDA="endTransitionURL";
    my @expectedResponse = qw(OK);
    logMsg ("Executing DA $stopAffinityDA on QM nodes @qmInstancesInBucket in bucket $bucket");
    my ($ret,$failedNodesRef) = ariba::Ops::PlatformHighTopologyManager::executeDirectAction($stopAffinityDA, \@expectedResponse, \@qmInstancesInBucket, 'executeOnAllAppInstanes');
    if ($ret) {
        logMsg ("DA $stopAffinityDA failed on hosts @{$failedNodesRef}");
        pause();
    }

    logMsg ("$subName done.");
}

sub rollbackCleanupForRU {
    my ($product, $sswsProduct) = @_;
    removeL2PMapFiles($product, $sswsProduct);
    setClusterStateToComplete($product);
    refreshNodeTopology($product, $bucket1);
}

sub rollforwardCleanupForRU {
    my ($product, $sswsProduct) = @_;
    removeL2PMapFiles($product, $sswsProduct);
    setClusterStateToComplete($product);
    refreshNodeTopology($product, $bucket0);
}

sub rollbackCleanupForRR {
    my ($product, $sswsProduct) = @_;
    setClusterStateToComplete($product);
    rollbackRCVersion($product);
    removeNewerRCVersions($product);
    stopPQReceiveAffinity($product, $bucket1);
}

sub rollforwardCleanupForRR {
    my ($product, $sswsProduct) = @_;
    setClusterStateToComplete($product);
    rollforwardRCVersion($product);
    stopPQReceiveAffinity($product, $bucket0);
}

sub main {

    ### Command parsing & validation
    my ($productName, $serviceName, $usecase, $action) = @_;
    my $validOptions = GetOptions(
        'product=s' => \$productName,
        'service=s' => \$serviceName,
        'usecase=s' => \$usecase,
        'action=s' => \$action,
    );
    if(!defined $productName || !defined $serviceName || !$validOptions ||
       !defined $usecase || !defined $action) {
        usage(); 
    }
    if($usecase ne $RU && $usecase ne $RR) {
        logMsg ("Valid values for usecase are $RU or $RR");
        usage(); 
    }
    if($action ne $ROLLBACK && $action ne $ROLLFORWARD) {
        logMsg ("Valid values for action are $ROLLBACK or $ROLLFORWARD");
        usage();
    }

    ### Setup environment
    ariba::rc::Passwords::initialize($serviceName);
    my $installedProduct  = installedProduct($productName, $serviceName);
    my $installedSswsProduct  = installedProduct("ssws", $serviceName);
    my $hostname = ariba::Ops::NetworkUtils::hostname();
    ariba::Ops::Startup::Common::initializeProductAndBasicEnvironment($hostname, $installedProduct->currentCluster());
    my @devlabServices = ariba::rc::Globals::servicesForDatacenter('devlab');
    if (grep /^$serviceName$/, @devlabServices) {
        $devlab=1;
    }

    ### Run cleanup steps, one of rollback or rollforward, for ru or rr 
    my $methodName = (lc $action) . "CleanupFor" . (uc $usecase);
    logMsg ("$methodName");
    if ($cleanups{$methodName}) {
        logMsg ("\n");
        logMsg ("--------------------------------------------------------");
        logMsg ("Doing cleanup for $action MCL after DC $usecase abort...\n");

        $cleanups{$methodName}->($installedProduct, $installedSswsProduct);

        logMsg ("\n");
        if ($manualAction) {
            logMsg ("Cleanup for $action MCL after DC $usecase abort - done with manual actions");
        }
        else {
            logMsg ("Cleanup for $action MCL after DC $usecase abort - done");
        }
        logMsg ("--------------------------------------------------------\n");
    }
    else {
        logMsg ("Did not find $methodName");
        exit(ariba::Ops::Startup::Common::EXIT_CODE_ERROR());
    }
    exit(ariba::Ops::Startup::Common::EXIT_CODE_OK());
}

main();
 
__END__
