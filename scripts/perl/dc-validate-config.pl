#!/usr/bin/perl -w

##########################################################################
### Copyright (c) 2013 Ariba, Inc.
### All rights reserved. 
###
### $Id: //ariba/platform/tools/config/perl/dc-validate-config.pl#1 $
### Responsible: achitale
### 
### Utility to validate that configuration in following files is in
### sync w.r.t appInstances during and/or after DC RU/RR.
###     modjk-ss-*.conf
###     jkmount-ss-*.conf
###     l2pmap.txt (applicable only for RU)
###
### Algorithm
### ---------
### - Copy config files from all web servers to a temp directory
### - Determine what appInstances to validate against
###   (a) If run after RU/RR is over, pick all appinstances
###   (b) If run during RU/RR, pick based on the event
### - For each file
###   (a) Load each line as hash record
###   (b) For each appInstances
###       - form appropriate keys to search in the file
###       - match the value against appInstance's in-memory fields
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
use ariba::Ops::L2PMap;
use ariba::Ops::PropertyList;
use Getopt::Long;
use Term::ReadKey;
use File::Path;

$main::quiet       = 1;
my $debug          = 0;
my $RU             = "ru";
my $RR             = "rr";
my $EXACT          = "exact";
my $CONTAINS       = "contains";
my $NOTCONTAINS    = "notcontains";
my $SSWEBSERVER    = "ss-webserver";
my $SSADMINSERVER  = "ss-adminserver";
my @roleNames      = ($SSADMINSERVER, $SSWEBSERVER);
my @eventNames     = ("PreBucket0stop", "PostBucket0stop",
                     "PreBucket0start", "PostBucket0start",
                     "PreBucket1stop", "PostBucket1stop",
                     "PreBucket1start", "PostBucket1start");

sub usage {
    print "usage: $0  -product <product name> -service<service> \n";
    print "           [-usecase <usecase name>] \n";
    print "           [-event <event name>]\n";
    print "           [-oldbuild <build label>]\n";
    print "           [-newbuild <build label>]\n";
    print "           [-debug]\n";
    print " -product  : Required, Name of the product (buyer, s4)\n"; 
    print " -service  : Required, Name of the service (itg, dev3) \n"; 
    print " -usecase  : Optional, Name of the usecase ($RU, $RR)\n"; 
    print " -event    : Optional, Name of the event (@eventNames)\n"; 
    print " -oldbuild : Optional, Old build label\n"; 
    print " -newbuild : Optional, New build label\n"; 
    print " -debug    : Optional, Additional logging \n"; 
    exit(ariba::Ops::Startup::Common::EXIT_CODE_ERROR()); 
}

sub timeMsg {
    my $msg = shift;
    my $time = localtime;
    print "::" . $time . ":: " . $msg . "\n";
}

sub logMsg {
    my $msg = shift;
    print "-Log- " . $msg . "\n";
}

sub debugMsg {
    my $msg = shift;
    print "-Debug- " . $msg . "\n" if ($debug);
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
    my ($validOptions, $productName, $serviceName, $usecase, $event, $oldBuild, $newBuild) = @_;

    if (!defined $productName || !defined $serviceName || !$validOptions) {
        usage(); 
    }
    if (defined $usecase && ($usecase ne $RU && $usecase ne $RR)) {
        print "Valid values for usecase are $RU or $RR \n";
        usage(); 
    }
    if (defined $usecase && !defined $event) {
        print "event is mandatory when usecase option is passed \n";
        usage(); 
    }
    if (defined $usecase && $usecase eq $RU) {
        if (!defined $oldBuild || !defined $newBuild) { 
            print "For RU usecase, oldbuild and newbuild arguments are mandatory \n";
            usage(); 
        }
    }
    if (defined $usecase && $usecase eq $RR) {
        if (defined $oldBuild || defined $newBuild) {
            print "For RR usecase, oldbuild and newbuild arguments are not required \n";
            usage(); 
        }
    }
    if (defined $event && !grep(/^$event$/,@eventNames)) {
        print "Valid values for event are (@eventNames) \n";
        usage(); 
    }
}

sub isMatch  {
    my ($key, $expectedVal, $val, $matchType) = @_;

    my $ret = 0;
    if ( ($matchType eq $EXACT) && ($val eq $expectedVal) ) {
        $ret = 1;
    }
    elsif ( ($matchType eq $CONTAINS) && ($val =~ /$expectedVal/) ) {
        $ret = 1;
    }
    elsif ( ($matchType eq $NOTCONTAINS) && (!($val =~ /$expectedVal/)) ) {
        $ret = 1;
    }
    if (!$ret) {
        logMsg ("<ERR> Mismatched key -$key-, match type -$matchType-, expected -$expectedVal- found -$val-");
    }
    return $ret;
}

sub inBalancer {
    my ($ai, $usecase, $event) = @_;

    ### During RR at certain events only one of the bucket is part of balancer
    ### workers. So, skip balancer check if appInstance is in other bucket.
    ### - Note that this is dependent on CTF being launched at the start of 
    ###   event callback while modjk updates at the end of event callback.
    ###
    ### PreBucket0start, PostBucket0start : B1 workers only
    ### PreBucket1stop, PostBucket1stop   : B0 workers only
    my $ret = $CONTAINS;
    if ($usecase eq $RR) {
        if ($ai->recycleGroup == 0 && ($event eq "PreBucket0start" || $event eq "PostBucket0start")) {
            $ret = $NOTCONTAINS;
        }
        if ($ai->recycleGroup == 1 && ($event eq "PreBucket1stop" || $event eq "PostBucket1stop")) {
            $ret = $NOTCONTAINS;
        }
    }
    return $ret;
}

sub isValidL2P {
    my ($product, $role, $localDest, $appInstancesRef, $usecase, $event) = @_;

    my $file = $localDest . '/l2pmap.txt';
    my @appInstances = @{$appInstancesRef};
    logMsg ("Verifying contents of $file against app instance count " . scalar (@appInstances));

    ### L2P has several key/values for each worker in following format:
    ### L2PMap = {
    ###    C0_Admin1 = {
    ###         host = app136.lab1.ariba.com;
    ###         port = 10003;
    ###         failPort = 10005;
    ###    };
    ### };
    ###
    ### Load up all the contents in a property format
    my $l2pContent = ariba::Ops::PropertyList->newFromFile($file);

    ### For each app instance form appropriate key and look in the
    ### loaded properties for a match.
    my $ret = 1;
    for my $ai (@appInstances) {
        ### Form all the keys and validate expected val
        my $hostKey  = 'L2PMap.' . $ai->logicalName() . '.host';
        my $portKey  = 'L2PMap.' . $ai->logicalName() . '.port';
        my $nameKey  = 'L2PMap.' . $ai->logicalName() . '.physicalName';
        $ret  &= isMatch ($hostKey, $ai->host(), $l2pContent->valueForKeyPath($hostKey), $EXACT);
        $ret  &= isMatch ($portKey, $ai->httpPort(), $l2pContent->valueForKeyPath($portKey), $EXACT);
        $ret  &= isMatch ($nameKey, $ai->workerName(), $l2pContent->valueForKeyPath($nameKey), $EXACT);
    }

    logMsg ("Verifying contents of $file complete, with " . ($ret? "success" : "failure"));
    return $ret;
}

sub loadFile {
    my ($file, $delimiter, $funcRef) = @_;

    debugMsg ("Loading file $file");
    open my $fh, $file or die $!;
    my %workers;
    while (my $line = <$fh>) {
        ### Remove newlines, comments and empty lines
        chomp $line;
        next if (grep(/^#/,$line)); 
        next if (!grep(/\S/,$line)); 

        if (defined $funcRef) {
            $line = $funcRef->($line);
        }

        ### split each line into key/val based on delimiter
        my($key, $value) = split($delimiter, $line);
        $workers{$key}   = $value;
        debugMsg ("Adding key -$key- value -$value-");
     
        ### TODO, what does modjk do for duplicate keys
        ### below isn't working
        # $workers{$key}  .= (exists $workers{$key}) ? ",$value" : $value;
    }
    close $fh;
    debugMsg ("Loading file $file complete");
    debugMsg ("Added " . scalar keys(%workers) . " to hash");
    return (\%workers);
}

sub jkMountParser {
    my $line = shift;

    ### JKMount file requires additional parsing
    $line =~ s/\t/ /g;
    $line =~ s/^JkMount //g;
    return $line; 
}

sub isValidJKMount {
    my ($product, $role, $localDest, $appInstancesRef, $usecase, $event) = @_;

    my $file = $localDest . '/jkmount-' . $role . '.conf';
    my @appInstances = @{$appInstancesRef};
    logMsg ("Verifying contents of $file against app instance count " . scalar (@appInstances));

    ### JKMount has several key/values for each worker in following format:
    ### - JkMount /Buyer/nr/C1_UI1/*      Node7app440lab1
    ### - JkMount /Buyer/soap/C1/*        buyerTaskCXML_C1
    ### - JkMount /Buyer/httpchannel/C1   buyerTaskCXML_C1
    ###
    ### Load up all lines as workers
    my $workersRef = loadFile ($file, " ", \&jkMountParser);
    my %workers = %{$workersRef};

    ### For each app instance form appropriate key and look in the
    ### loaded hash table for a match.
    my $ret = 1;
    for my $ai (@appInstances) {
        ### Form all the keys and validate expected val
        ### TODO, fix the name conversion
        my $name  = $product->name();
        if ($name eq "buyer") {
            $name = "Buyer";
        }
        elsif ($name eq "s4") {
            $name = "Sourcing";
        }
        my $nrKey   = '/' . $name . "/nr/" . $ai->logicalName() . "/*";
        $ret       &= isMatch ($nrKey, $ai->workerName(), $workers{$nrKey}, $EXACT);
    }

    logMsg ("Verifying contents of $file complete, with " . ($ret? "success" : "failure"));
    return $ret;
}

sub isValidModJK {
    my ($product, $role, $localDest, $appInstancesRef, $usecase, $event) = @_;

    my $file = $localDest . '/modjk-' . $role . '.properties';
    my @appInstances = @{$appInstancesRef};
    logMsg ("Verifying contents of $file against app instance count " . scalar (@appInstances));

    ### Modjk has several key/values for each worker in following format:
    ### - worker.Node20app511lab1.port=20380
    ### - worker.Node20app511lab1.host=app511.lab1.ariba.com
    ###
    ### Modjk also has balancer list for each community UI/TaskCXML workers
    ### in following format:
    ### - worker.buyerUI_C1.balance_workers=Node9app440lab1,Node10app511lab1,Node1app511lab1
    ###
    ### Load up all lines as workers
    my $workersRef = loadFile ($file, "=");
    my %workers = %{$workersRef};

    ### For each app instance form appropriate key and look in the
    ### loaded hash table for a match.
    my $ret = 1;
    for my $ai (@appInstances) {
        ### Form all the keys and validate expected val
        my $hostKey     = 'worker.' . $ai->workerName() . '.host';
        my $portKey     = 'worker.' . $ai->workerName() . '.port';
        my $balancerKey = "null";
        if ($role eq $SSWEBSERVER) {
            $balancerKey = 'worker.' . $product->name() . $ai->alias() . "_C" . $ai->community() . '.balance_workers';
        }
        elsif ($role eq $SSADMINSERVER) {
            $balancerKey = 'worker.' . $product->name() . '.balance_workers';
        }

        $ret  &= isMatch ($hostKey, $ai->host(), $workers{$hostKey}, $EXACT);
        $ret  &= isMatch ($portKey, $ai->port(), $workers{$portKey}, $EXACT);
        $ret  &= isMatch ($balancerKey, $ai->workerName(), $workers{$balancerKey}, inBalancer($ai, $usecase, $event));
    }

    logMsg ("Verifying contents of $file complete, with " . ($ret? "success" : "failure"));
    return $ret;
}


sub getApplicableAppInstances {
    my ($oldProduct, $newProduct, $event) = @_;

    my @oldAppInstances   = $oldProduct->appInstances();
    my @newAppInstances   = $oldProduct->appInstances();
    debugMsg ("Old build app instances count " . scalar (@oldAppInstances));
    debugMsg ("New build app instances count " . scalar (@oldAppInstances));

    ### UI/TaskCXML/Admin appinstances only
    @oldAppInstances      = grep { $_->alias() =~ /UI|TaskCXML|Admin/ } @oldAppInstances;
    @newAppInstances      = grep { $_->alias() =~ /UI|TaskCXML|Admin/ } @newAppInstances;
    debugMsg ("Old build filtered app instances count " . scalar (@oldAppInstances));
    debugMsg ("New build filtered app instances count " . scalar (@oldAppInstances));

    ### At certain events, modjk config has either old or new workers.
    ### - Note that this is dependent on CTF being launched at the start of 
    ###   event callback while modjk updates at the end of event callback.
    return @oldAppInstances if (!defined $event);
    return @oldAppInstances if ($event eq "PreBucket0stop" || $event eq "PostBucket0stop");
    return @newAppInstances if ($event eq "PreBucket1start" || $event eq "PostBucket1start");
    
    ### All other cases, return bucket1 of old build and bucket0 of new build.
    ### In RR case, both old/new build point to current build so it still works.
    @oldAppInstances = grep { $_->recycleGroup() == 1 } @oldAppInstances;
    @newAppInstances = grep { $_->recycleGroup() == 0 } @newAppInstances;
    debugMsg ("Old build filtered bucket1 app instances count " . scalar (@oldAppInstances));
    debugMsg ("New build filtered bucket0 app instances count " . scalar (@oldAppInstances));

    return (@oldAppInstances , @newAppInstances);
}

sub copyConfigFiles {
    my ($product, $sswsProduct, $role, $host, $localDest) = @_;

    logMsg ("Copying files for -$role- from -$host- to -$localDest-");

    my $remoteConfig    = $sswsProduct->configDir();
    my $remoteL2PConfig = $sswsProduct->docRoot() . "/topology/" . $product->name();
    my $remoteModJK     = '/modjk-' . $role . '.properties';
    my $remoteJKMount   = '/jkmount-' . $role . '.conf';
    my $remoteL2P       = "/l2pmap.txt";

    my $copyDone        = 1;
    my $user            = ariba::rc::Globals::deploymentUser($product->name(), $product->service());
    $copyDone          &= ariba::rc::Utils::transferFromSrcToDest($host, $user, $remoteConfig, 
                                            $remoteModJK, undef, $user, $localDest, undef, 0);
    $copyDone          &= ariba::rc::Utils::transferFromSrcToDest($host, $user, $remoteConfig, 
                                            $remoteJKMount, undef, $user, $localDest, undef, 0);
    $copyDone          &= ariba::rc::Utils::transferFromSrcToDest($host, $user, $remoteL2PConfig, 
                                            $remoteL2P, undef, $user, $localDest, undef, 0);
    return ($copyDone);
}

sub validateConfig {
    my ($oldProduct, $newProduct, $sswsProduct, $usecase, $event) = @_;

    timeMsg ("==============================================");
    timeMsg ("Validating config files");
    timeMsg ("==============================================");

    logMsg ("Roles to validate -@roleNames-");
    logMsg ("Use case -$usecase- event -$event-");
    logMsg ("Old build ". $oldProduct->buildName() . ", New build " . $newProduct->buildName());

    my @appInstances = getApplicableAppInstances ($oldProduct, $newProduct, $event);
    logMsg ("AppInstances count " . scalar (@appInstances));

    my $valid = 1;
    for my $role (@roleNames) {

        ### Filter app instances for this role
        my @roleAppInstances = grep { $_->visibleVia() eq $role } @appInstances;
        logMsg ("AppInstances for -$role-, count " . scalar (@roleAppInstances));

        my @hostsForRole = $sswsProduct->hostsForRoleInCluster ($role, $oldProduct->currentCluster());
        logMsg ("Validating role -$role- on hosts -@hostsForRole-");
        for my $host (@hostsForRole) {

            my @hostSplit  =  split('\.', $host);
            my $localDest  =  ariba::Ops::Startup::Common::tmpdir() . "/dc/$role-" . $hostSplit[0] . "-" . time;
            mkpath($localDest) or die "Couldn't mkpath '$localDest': $!\n";

            my $copyDone   = copyConfigFiles ($oldProduct, $sswsProduct, $role, $host, $localDest);
            if ($copyDone) {
                logMsg ("File copy successful");
                $valid  &= isValidModJK ($oldProduct, $role, $localDest, \@roleAppInstances, $usecase, $event);
                $valid  &= isValidJKMount ($oldProduct, $role, $localDest, \@roleAppInstances, $usecase, $event);
                if ($usecase eq $RU) {
                    $valid  &= isValidL2P ($oldProduct, $role, $localDest, \@roleAppInstances, $usecase, $event);
                }
            }
            else {
                logMsg ("File copy failed");
                $valid  = 0;
            }

            rmtree($localDest);
        }
    }

    timeMsg ("==============================================");
    if ($valid) {
        timeMsg ("Config file validation is successful");
    }
    else {
        timeMsg ("<ERR> Config file validation failed");
    }
    timeMsg ("==============================================");
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
        'newBuild=s' => \$newBuild,
        'debug' => \$debug
    );
    validateArguments ($validOptions, $productName, $serviceName, $usecase, $event, $oldBuild, $newBuild);

    ### Setup environment. If build names are undefined, both old/new 
    ### will point to currently installed Product.
    ariba::rc::Passwords::initialize($serviceName);
    my $oldProduct  = installedProduct($productName, $serviceName, $oldBuild);
    my $newProduct  = installedProduct($productName, $serviceName, $newBuild);
    my $sswsProduct = installedProduct("ssws", $serviceName);
    my $hostname    = ariba::Ops::NetworkUtils::hostname();
    ariba::Ops::Startup::Common::initializeProductAndBasicEnvironment($hostname, $oldProduct->currentCluster());

    my $ret = validateConfig ($oldProduct, $newProduct, $sswsProduct, $usecase, $event);
    if (!$ret) {
        exit(ariba::Ops::Startup::Common::EXIT_CODE_ERROR());
    }
    exit(ariba::Ops::Startup::Common::EXIT_CODE_OK());
}

main();
 
__END__
