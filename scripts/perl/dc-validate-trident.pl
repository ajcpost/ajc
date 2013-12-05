#!/usr/bin/perl -w

##########################################################################
### Copyright (c) 2013 Ariba, Inc.
### All rights reserved. 
###
### $Id: //ariba/platform/tools/config/perl/dc-cleanup.pl#1 $
### Responsible: achitale
### 
### Utility to ensure that configuration in following files is in
### sync during and after DC RU/RR.
###     modjk-ss-webserver.conf
###     jkmount-ss-webserver.conf
###     l2pmap.txt (applicable only during RU)
###
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
my $devlab       = 0;

### Function pointers to cleanup steps
my @eventNames = (
    "PreBucket0stop", "PostBucket0stop",
    "PreBucket0start", "PostBucket0start",
    "PreBucket1stop", "PostBucket1stop",
    "PreBucket1start", "PostBucket1start"
);

sub usage {
    print "usage: $0 -product <product name> -service<service> \n";
    print "          [-usecase <$RU|$RR>] \n";
    print "          [-event <event name>]\n";
    print "          [-oldbuild <build label>]\n";
    print "          [-newbuild <build label>]\n";
    print " -product  : Required, Name of the product (buyer, s4)\n"; 
    print " -service  : Required, Name of the service (itg, dev3) \n"; 
    print " -usecase  : Optional, Name of the usecase ($RU, $RR>\n"; 
    print " -oldbuild : Optional, Old build label\n"; 
    print " -newbuild : Optional, New build label\n"; 
    exit(ariba::Ops::Startup::Common::EXIT_CODE_ERROR()); 
}

sub logMsg {
    my $msg = shift;
    my $time = localtime;
    print "Log ::" . $time . ":: " . $msg . "\n";
}

sub installedProduct {
    my ($productName, $serviceName, $buildName) = @_;
    my $product;
    if (ariba::rc::InstalledProduct->isInstalled($productName, $serviceName, $buildName)) {
        $product = ariba::rc::InstalledProduct->new($productName, $serviceName, $buildName);
    } else {
        die "Unable to find product: $productName, buildName: $buildName on service : $serviceName\n";
    }
    return $product;
}

sub validateArguments {
    my ($productName, $serviceName, $usecase, $event, $oldBuild, $newBuild) = @_;

    my $subName = (caller(0))[3];
    logMsg ("$subName ...");

    if (!defined $productName || !defined $serviceName || !$validOptions) {
        usage(); 
    }
    if (defined $usecase && ($usecase ne $RU && $usecase ne $RR)) {
        logMsg ("Valid values for usecase are $RU or $RR");
        usage(); 
    }
    if (defined $usecase && !defined $event)
        logMsg ("event is mandatory when usecase option is passed");
        usage(); 
    }
    if (defined $usecase && $usecase eq $RU) {
        if (!defined $oldBuild || !defined $newBuild || !defined $event) { 
            logMsg ("For RU usecase, oldbuild, newbuild and event arguments are mandatory");
            usage(); 
        }
    }
    if (defined $usecase && $usecase eq $RR) {
        if (defined $oldBuild || defined $newBuild || !defined $event) {
            logMsg ("For RU usecase, only event argument is required");
            usage(); 
        }
    }
    if (defined $event && !($events{$event}) {
        logMsg ("Valid values for event are @events");
        usage(); 
    }

    logMsg ("$subName done.");
}

sub getApplicableAppInstances {
    my ($oldProduct, @newProduct, $event) = @_;

    my $subName = (caller(0))[3];
    logMsg ("$subName ...");

    logMsg ("Applicable app instances for -");
    logMsg ("    Old build:  $oldProduct->buildName(), New build: $newProduct->buildName());
    logMsg ("    Event: $event");

    ### UI/Task appinstances only
    my @oldAppInstances   = $oldProduct->appInstances();
    my @newAppInstances   = $oldProduct->appInstances();
    @oldAppInstances      = grep { $_->logicalName() =~ /UI|_Task/ } @oldAppInstances;
    @newAppInstances      = grep { $_->logicalName() =~ /UI|_Task/ } @newAppInstances;

    ### At certain events, modjk config has either old or new workers.
    ### - Note that this is dependent on CTF being launched at the start of 
    ###   event callback while modjk updates at the end of event callback.
    ### - There's no need to differentiate between RU & RR case.
    return @oldAppInstances if (!defined $event);
    return @oldAppInstances if ($event eq "PreBucket0stop" || $event eq "PostBucket0stop");
    return @newAppInstances if ($event eq "PreBucket1start" || $event eq "PostBucket1start");
    
    ### All other cases, return bucket1 of old build and bucket0 of new build.
    ### In RR case, both old/new build point to current build so it still works.
    my @oldAppInstances = grep { $_->recycleGroup() == 1 } @oldAppInstances;
    my @newAppInstances = grep { $_->recycleGroup() == 0 } @newAppInstances;
    return (@oldAppInstances , @newAppInstances);
}

sub validateModJK {
    my ($localDest, @appInstances, $useCase, $event) = @_;

    my $subName = (caller(0))[3];
    logMsg ("$subName ...");

    my $ret = 0;
    for $role in ("ss-webserver", "ss-adminserver", "ss-testserver) {
        my %records;
        my $file = $localDest . "/modjk- " . $role . ".conf";
        open (my $fh, "<", $file) or die "Can't open the file $file: ";
        while (my $line =<$fh>)
        {
            ### Remove comments and empty lines
            next if $line =~ /^#/;
            next if $line =~ /\S/;

            ### split each line into key/val based on "=" delimiter
            my($key, $value) = split("=", $line);
            $records{$key}  .= exists $records{$key} ? ",$val" : $val;
        }

        logMsg ("Checking $file against appinstances");
        for $my ai (@appInstances) {

            ### Check worker definition exists and has right host/port
            my $aiHostKey = "worker." . $ai->workerName() . ".host";
            my $val = $records{$aiHostKey};
            if ($val eq $ai->host()) {
                $ret = 1;
                logMsg ("Mismatch for $ai->logicalName());
                logMsg ("   expected host: $ai->host(), found host: $val");
            }

            my $aiPortKey = "worker." . $ai->workerName() . ".port";
            $val = $records{$aiPortKey};
            if ($val eq $ai->httpPort()) {
                $ret = 1;
                logMsg ("Mismatch for $ai->logicalName());
                logMsg ("   expected port: $ai->host(), found port: $val");
            }

            ### Durin RR only one of the bucket will be in balancer workers as below:
            ### - Note that this is dependent on CTF being launched at the start of 
            ###   event callback while modjk updates at the end of event callback.
            ###
            ### PreBucket0start, PostBucket0start : B1 workers only
            ### PreBucket1stop, PostBucket1stop   : B0 workers only
            if ($usecase eq $RR) {
                if ($ai->recycleGroup == 0 && ($event eq "PreBucket0start" || $event eq "PostBucket0start")) {
                    next;
                }
                if ($ai->recycleGroup == 1 && ($event eq "PreBucket1stop" || $event eq "PostBucket1stop")) {
                    next;
                }
            }

            ### Check the instnace is part of balancer
            my $aiBalancerKey = "worker." . $oldProduct->product() . $ai->alias() . "_C" . $ai->community() . ".balance_workers";
            $val = $records{$aiPortKey};
            if ($val =~ /$ai->workerName()/) {
                $ret = 1;
                logMsg ("Mismatch for $ai->logicalName());
                logMsg ("   expected in balancer list, found balancer list: $val");
            }
        }
    }

    logMsg ("$subName done.");
    return $ret;
}

sub copyConfigFiles {
    my ($product, $host, $localDest) = @_;

    my $rootDir            = ariba::rc::Globals::rootDir("ssws", $product->service())
    my $remoteConfigPath   = $rooDir . "/config";
    my $remoteTopologyPath = $rootDir . "/docroot/topology/" . $product->name();
    my $user               = ariba::rc::Globals::deploymentUser($productName, $serviceName);

    ### transferFromSrcToDest success is 1, failure is 0
    logMsg ("Copying from $host, src: $remoteConfigPath, $remoteTopologyPath dest: $localDest);
    my $ret = ariba::rc::Utils::transferFromSrcToDest($host, $user, $remoteConfigPath, undef, undef, $user, $localDest, undef, 0);
    $ret   &= ariba::rc::Utils::transferFromSrcToDest($host, $user, $remoteTopologyPath, undef, undef, $user, $localDest, undef, 0);
    logMsg ("Copy failed, no validation will be done for $host config files") if (!$ret);

    return ($ret);
}

sub validateTrident {
    my ($oldProduct, $newProduct, $sswsProduct, $useCase, $event) = @_;

    my $subName = (caller(0))[3];
    logMsg ("$subName ...");

    @appInstances = getApplicableAppInstances ($oldProduct, $newProduct, $event);
    $webHosts     = $oldProduct->hostsForRoleInCluster('httpvendor', $oldProduct->currentCluster());

    logMsg ("Validating config files for hosts: @webHosts, usecase: $usecase, event: $event);
    my $ret = 0;
    for my $host (@webHosts) {
        my $localDest  =  ariba::Ops::Startup::Common::tmpdir() . $host . time;
        mkpath($localDest) or die "Couldn't mkpath '$localDest': $!\n";
        my $copyDone   = copyConfigFiles ($oldProduct, $host);
        if ($copyDone) {
            $ret  |= validateModJK ($localDest, @appInstances, $usecase, $event);
            $ret  |= validateJKMount ($localDest, @appInstances, $usecase, $event);
            if ($usecase eq $RU) {
                $ret  |= validateL2P ($localDest, @appInstances, $usecase, $event);
            }
        }
        unlink($localDest);
    }

    logMsg ("$subName done.");
}

sub main {

    ### Command parsing & validation
    my ($productName, $serviceName, $usecase, $event, $oldBuild, $newBuild) = @_;
    my $validOptions = GetOptions(
        'product=s' => \$productName,
        'service=s' => \$serviceName,
        'usecase=s' => \$usecase,
        'event=s' => \$event,
        'oldBuild=s' => \$oldBuild,
        'newBuild=s' => \$newBuild
    );
    validateArguments ($productName, $serviceName, $usecase, $event, $oldBuild, $newBuild);

    ### Setup environment
    ### If build names are undefined, both old/new will point to currently 
    ### installed Product.
    ariba::rc::Passwords::initialize($serviceName);
    my $oldProduct  = installedProduct($productName, $serviceName, $oldBuild);
    my $newProduct  = installedProduct($productName, $serviceName, $newBuild);
    my $sswsProduct = installedProduct("ssws", $serviceName);
    my $hostname    = ariba::Ops::NetworkUtils::hostname();
    ariba::Ops::Startup::Common::initializeProductAndBasicEnvironment($hostname, $product->currentCluster());
    my @devlabServices = ariba::rc::Globals::servicesForDatacenter('devlab');
    if (grep /^$serviceName$/, @devlabServices) {
        $devlab=1;
    }

    my $ret = validateTrident ($oldProduct, $newProduct, $usecase, $event);
    if ($ret) {
        exit(ariba::Ops::Startup::Common::EXIT_CODE_ERROR());
    }
    exit(ariba::Ops::Startup::Common::EXIT_CODE_OK());
}

main();
 
__END__


