package CatPublishTracker;

use strict;
use warnings;
use Log::Log4perl;
use File::Path;
use Data::Dumper;
use BaseTracker;

our @ISA = qw (BaseTracker);

my $LOGGER = Log::Log4perl::get_logger();

sub new {
    my $class=shift;
    my $ref={}; 
    bless($ref, $class);
    return $ref;
}

sub markIfMatch {
    my ($self, $getMsg, $actionMsg) = @_;
    my $getRClient    = $getMsg->{$BaseTracker::KEY_RCLIENT};
    my $getQueue      = $getMsg->{$BaseTracker::KEY_QUEUE};
    my $getEpoch      = $getMsg->{$BaseTracker::KEY_EPOCH};
    my $getMatch      = $getMsg->{$BaseTracker::KEY_MATCH};
    my $actionRClient = $actionMsg->{$BaseTracker::KEY_RCLIENT};
    my $actionQueue   = $actionMsg->{$BaseTracker::KEY_QUEUE};
    my $actionEpoch   = $actionMsg->{$BaseTracker::KEY_EPOCH};
    my $actionMatch   = $actionMsg->{$BaseTracker::KEY_MATCH};

    if ( ($getRClient  eq $actionRClient) &&
         ($getQueue    eq $actionQueue) &&
         ($getEpoch    <= $actionEpoch) &&
         ($getMatch    eq "" ) &&
         ($actionMatch eq "" ) ) {
        $getMsg->{$BaseTracker::KEY_MATCH}    = $actionMsg;
        $actionMsg->{$BaseTracker::KEY_MATCH} = $getMsg;
    }
}

sub validatePQMsgs {
    my ($self, $op, $flowType, @pqMsgs) = @_;

    ### Add all messages to flow list
    foreach my $pqMsg (@pqMsgs) {
        $self->addToFlow($op, $flowType, $pqMsg)
    }

    if (scalar @pqMsgs < 1 ) {
        $self->addToError ($op, "Found zero PQ messages", $flowType);
        return;
    }

    ### Verify first is add 
    if ($pqMsgs[0]->{$BaseTracker::KEY_LOGID} ne $BaseTracker::LOGID_ADD) {
        $self->addToError($op, "Expected ADD at the beginning", $flowType);
    }

    my @getMsgs      = grep { $_->{$BaseTracker::KEY_LOGID} eq $BaseTracker::LOGID_GET } @pqMsgs;
    my @rollbackMsgs = grep { $_->{$BaseTracker::KEY_LOGID} eq $BaseTracker::LOGID_ROLLBACK } @pqMsgs;
    my @confirmMsgs  = grep { $_->{$BaseTracker::KEY_LOGID} eq $BaseTracker::LOGID_CONFIRM } @pqMsgs;

    ### For each rollback, match corresponding get message
    my $uniqueRClients;
    foreach my $rollbackMsg (@rollbackMsgs) {
        my $rClient = $rollbackMsg->{$BaseTracker::KEY_RCLIENT};
        $uniqueRClients->{$rClient} = $rClient;
        foreach my $getMsg (@getMsgs) {
            $self->markIfMatch($getMsg, $rollbackMsg);
        }
    }

    ### For each confirm, match corresponding get message
    foreach my $confirmMsg (@confirmMsgs) {
        foreach my $getMsg (@getMsgs) {
            $self->markIfMatch($getMsg, $confirmMsg);
        }
    }

    ### Any unmarked msgs are problem, report
    my @unmatchedGetMsgs      = grep { $_->{$BaseTracker::KEY_MATCH} eq "" } @getMsgs;
    my @unmatchedRollbackMsgs = grep { $_->{$BaseTracker::KEY_MATCH} eq "" } @rollbackMsgs;
    my @unmatchedConfirmMsgs  = grep { $_->{$BaseTracker::KEY_MATCH} eq "" } @confirmMsgs;

    foreach my $msg (@unmatchedGetMsgs) {
        my $errMsg  = "Get message for $msg->{$BaseTracker::KEY_QUEUE} doesn't have rollback or confirm";
        $self->addToError($op, $errMsg, $flowType);
    }
    foreach my $msg (@unmatchedRollbackMsgs) {
        my $errMsg  = "Rollback message for $msg->{$BaseTracker::KEY_QUEUE} doesn't have corresponding get message";
        $self->addToError($op, $errMsg, $flowType);
    }
    foreach my $msg (@unmatchedConfirmMsgs) {
        my $errMsg  = "Confirm message for $msg->{$BaseTracker::KEY_QUEUE} doesn't have corresponding get message";
        $self->addToError($op, $errMsg, $flowType);
    }

    ### Verify Count of unique get-rollback messages matches 16
    my @rClients = keys %{$uniqueRClients};
    if (scalar @rClients != 16) {
        my $errMsg = "Got " . scalar @rClients . " unique responses from (" . join (",", @rClients) . "), expected 16";
        $self->addToError ($op, $errMsg, $flowType);
    }
}

sub validateOp {
    my ($self, $op) = @_;

    my $pqId = $op->{$BaseTracker::KEY_PQID};
    $LOGGER->debug("Building flow for " . $pqId . "...");

    my $ref = $self->{$BaseTracker::PQ_HASH}{$pqId};
    if (!defined $ref) {
        my $errMsg = "No PQ messages for request - $pqId";
        $self->addToError ($op, $errMsg, "REQ");
        return;
    }
    my @pqReqMsgs = @{$ref};
    $self->validatePQMsgs($op, "REQ", @pqReqMsgs);

    $LOGGER->debug("Building flow for " . $pqId . " -- done");
}
