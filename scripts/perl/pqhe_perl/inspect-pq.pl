#!/usr/bin/perl -w

use strict;
use warnings;

use FindBin;
BEGIN {
push(@INC, "$FindBin::Bin");
}

use Getopt::Long;
use File::Path;
use List::MoreUtils 'any';
use List::Util qw(first);
use Log::Log4perl qw(:easy);
use BaseTracker;
use OnDemandTaskTracker;
use CatPublishTracker;

my $ondemandTaskTracker = OnDemandTaskTracker->new();
my $scheduleTaskTracker = OnDemandTaskTracker->new();
my $catPublishTracker   = CatPublishTracker->new();

my $KEY_ONDEMANDTASK    = "ondemandtask";
my $KEY_SCHEDULETASK    = "scheduledtask";
my $KEY_CATALOGPUBLISH  = "catalogpublish";

my $KEY_STARTNODE       = "startnode";
my $KEY_OPLOGID         = "oplogid";
my $KEY_TRACKER         = "tracker";

my $KEY_LOG_FATAL       = "fatal";
my $KEY_LOG_ERROR       = "error";
my $KEY_LOG_WARN        = "warn";
my $KEY_LOG_INFO        = "info";
my $KEY_LOG_DEBUG       = "debug";
my $KEY_LOG_TRACE       = "trace";
my %DEBUG_LEVELS        = (
    $KEY_LOG_FATAL => $FATAL,
    $KEY_LOG_ERROR => $ERROR,
    $KEY_LOG_WARN  => $WARN,
    $KEY_LOG_INFO  => $INFO,
    $KEY_LOG_DEBUG => $DEBUG,
    $KEY_LOG_TRACE => $TRACE
);

my %OP_TYPES            = (
    $KEY_ONDEMANDTASK => {
        $KEY_STARTNODE => "ui",
        $KEY_OPLOGID => "ID12085",
        $KEY_TRACKER => $ondemandTaskTracker
     },
    $KEY_SCHEDULETASK => {
        $KEY_STARTNODE => "manager",
        $KEY_OPLOGID => "ID12085",
        $KEY_TRACKER => $scheduleTaskTracker
     },
    $KEY_CATALOGPUBLISH => {
        $KEY_STARTNODE => "globaltask",
        $KEY_OPLOGID => "ID12085",
        $KEY_TRACKER => $catPublishTracker
     }
);


sub usage {
    print "usage: $0 -optype <> -logdir <> [-debuglevel] \n";
    print "    -optype : Required, Type of the operation from " . join (",", keys %OP_TYPES) . "\n";
    print "    -logdir : Required, Location of the log files of interest. will create \"out\" folder in same\n";
    print "    -debuglevel : Optional, set the debug level to one of " . join (",", keys %DEBUG_LEVELS) . " during program execution \n";
    exit(-1);
}

sub validateArgs {
    my ($validOptions, $opType, $logDir, $debugLevel) = @_;

    if(!$validOptions || !defined $opType || !defined $logDir) {
        usage();
    }
    if (!exists $OP_TYPES{$opType}) {
        print "Value for -optype must be one of " . join (",", keys %OP_TYPES) . "\n";
        usage();
    }
    if (!exists $DEBUG_LEVELS{$debugLevel}) {
        print "Value for -debuglevel must be one of " . join (",", keys %DEBUG_LEVELS) . "\n";
        usage();
    }
    if (!-d $logDir) {
        print "Log directory $logDir doesn't exist \n";
        usage();
    }
}

sub main {
    my ($opType, $logDir, $debugLevel) = @_;
    my $validOptions = GetOptions(
        'optype=s' => \$opType,
        'logdir=s' => \$logDir,
        'debuglevel=s' => \$debugLevel
    );

    if (!defined $debugLevel) {
        $debugLevel=$KEY_LOG_INFO;
    }
    validateArgs ($validOptions, $opType, $logDir, $debugLevel);
    Log::Log4perl->easy_init($DEBUG_LEVELS{$debugLevel});

    my $opLogId   = $OP_TYPES{$opType}{$KEY_OPLOGID};
    my $startNode = $OP_TYPES{$opType}{$KEY_STARTNODE};
    my $tracker   = $OP_TYPES{$opType}{$KEY_TRACKER};

    $tracker->readLogs ($opLogId, $startNode, $logDir);
    $tracker->validateOps ();
    $tracker->printOps ();
    $tracker->logOps ($logDir);
}

main();
