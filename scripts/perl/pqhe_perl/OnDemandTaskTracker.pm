package OnDemandTaskTracker;

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

    my @addMsgs      = grep { $_->{$BaseTracker::KEY_LOGID} eq $BaseTracker::LOGID_ADD } @pqMsgs;
    my @getMsgs      = grep { $_->{$BaseTracker::KEY_LOGID} eq $BaseTracker::LOGID_GET } @pqMsgs;
    my @rollbackMsgs = grep { $_->{$BaseTracker::KEY_LOGID} eq $BaseTracker::LOGID_ROLLBACK } @pqMsgs;
    my @confirmMsgs  = grep { $_->{$BaseTracker::KEY_LOGID} eq $BaseTracker::LOGID_CONFIRM } @pqMsgs;

    ### Must be at least one get and confirm
    $self->addToError ($op, "Found 0 GET messages. Must be at least one.", $flowType) if (scalar @getMsgs < 1);
    $self->addToError ($op, "Found 0 CONFIRM messages. Must be at least one.", $flowType) if (scalar @confirmMsgs < 1);


    ### For each rollback, match corresponding get message
    foreach my $rollbackMsg (@rollbackMsgs) {
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

    ## Search the PQ response ID
    my $pqReqId = $op->{$BaseTracker::KEY_PQREQ};
    my $pqRsps = $self->getPQRspId ($pqId, $pqReqId);
    if (scalar @$pqRsps != 1) {
        my $errMsg = "Found " . @$pqRsps . "( " . join(",", @$pqRsps) . " ) responses to this request. Must be one.";
        $self->addToError ($op, $errMsg, "RSP");
        return;
    }

    my $pqRspId   = @$pqRsps[0];
    my @pqRspMsgs = @{$self->{$BaseTracker::PQ_HASH}{$pqRspId}};
    $self->validatePQMsgs($op, "RSP", @pqRspMsgs);

    $LOGGER->debug("Building flow for " . $pqReqId . " -- done");
}
