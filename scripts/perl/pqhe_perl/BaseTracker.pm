package BaseTracker;

use strict;
use warnings;
use Log::Log4perl;
use File::Path;
use Data::Dumper;
use Data::UUID;
use DateTime::Format::Strptime;
use List::Util qw(first);

### Constants used as keys in various in-memory data structures
### - Some of these must match what gets dumped in the log files, 
###   see parsePQPattern() below
our $OP_LOGS     = "OP_LOGS";
our $PQ_HASH     = "PQ_HASH";
our $PQ_REQHASH  = "PQ_REQHASH";
our $KEY_LOGID   = "logid";
our $KEY_PQID    = "pqid";
our $KEY_PQREQ   = "pqreq";
our $KEY_TIME    = "time";
our $KEY_EPOCH   = "epoch";
our $KEY_CLIENT  = "client";
our $KEY_RCLIENT = "remoteclient";
our $KEY_TASK    = "task";
our $KEY_REALM   = "realm";
our $KEY_PORT    = "port";
our $KEY_QUEUE   = "queue";
our $KEY_LINE    = "fullline";
our $KEY_LOGFILE = "logfile";
our $KEY_RESULT  = "result";
our $KEY_FLOW    = "flow";
our $KEY_ERROR   = "error";
our $KEY_MATCH   = "match";

### LOG IDs logged by QueueManager MemcacheHandler.
our $LOGID_ADD   = "ID12086";
our $LOGID_GET   = "ID12087";
our $LOGID_CONFIRM  = "ID12088";
our $LOGID_ROLLBACK = "ID12089";
our $KEY_COMMAND = "command";
our $KEY_ORDER   = "order";
our %PQ_LOGS      = (
    $LOGID_ADD => {
        $KEY_COMMAND => "ADD",
        $KEY_ORDER   => 1
    },
    $LOGID_GET => {
        $KEY_COMMAND => "GET",
        $KEY_ORDER   => 2
    },
    $LOGID_ROLLBACK => {
        $KEY_COMMAND => "ROLLBACK",
        $KEY_ORDER   => 2
    },
    $LOGID_CONFIRM => {
        $KEY_COMMAND => "CONFIRM",
        $KEY_ORDER   => 3
    }
);


### Internal constants
my $MAX_LOGFILES = 100;
my $LOGGER = Log::Log4perl::get_logger();
my $FLAG   = 1;

sub new {
    my $class=shift;
    my $ref={}; 
    bless($ref, $class);
    return $ref;
}

sub getPQCmdString {
    my ($self, $pqLogId) = @_;

    ### Don't understand below syntax yet, 
    ### http://stackoverflow.com/questions/3222138/how-to-get-the-index-of-an-element-in-an-array
    ### my $idx = first { $PQ_LOGIDS[$_] eq $pqLogId } 0..$#PQ_LOGIDS;
    ### return $PQ_COMMANDS[$idx] || "unknown";
    my $command = $PQ_LOGS{$pqLogId}{$KEY_COMMAND};

}

### Append pq message to the e2e flow array for the given operation.
### Messages are pushed in "FLOW" array.
sub addToFlow {
    my ($self, $op, $flowType, $pqMsg) = @_;

    $LOGGER->debug("Adding for op id: $op->{$KEY_LOGID} with pq id: $op->{$KEY_PQID}");
    $LOGGER->trace(Dumper($pqMsg));
   
    #$LOGGER->info("-AJC-----");
    #$LOGGER->info(Dumper($op));
    #$LOGGER->info("-AJC-----");

    my $pqCmd   = $PQ_LOGS{$pqMsg->{$KEY_LOGID}}{$KEY_COMMAND};
    my $port    = $pqMsg->{$KEY_PORT};
    my $queue   = $pqMsg->{$KEY_QUEUE};
    my $time    = $pqMsg->{$KEY_TIME};
    my $rclient = $pqMsg->{$KEY_RCLIENT};
    $rclient    = $op->{$KEY_CLIENT} if ($pqMsg->{$KEY_LOGID} eq $LOGID_ADD && $flowType eq "REQ");
    my $pqId    = $pqMsg->{$KEY_PQID};
    my $pqReqId = $pqMsg->{$KEY_PQREQ};
    my $manager = $pqMsg->{$KEY_CLIENT};
    my $logFile = $pqMsg->{$KEY_LOGFILE};

    my $msg   =  "TYPE=\""     . $flowType . "\"";
    $msg     .=  ",Command=\"" . $pqCmd    . "\"";
    $msg     .=  ",Port=\""    . $port    . "\"";
    $msg     .=  ",Queue=\""   . $queue    . "\"";
    $msg     .=  ",Time=\""    . $time     . "\"";
    $msg     .=  ",Client=\""  . $rclient  . "\"";
    $msg     .=  ",PQID=\""    . $pqId     . "\"";
    $msg     .=  ",PQREQ=\""   . $pqReqId  . "\"";
    $msg     .=  ",Manager=\"" . $manager  . "\"";
    $msg     .=  ",LOG=\""     . $logFile  . "\"";

    push (@{$op->{$KEY_FLOW}}, $msg);
    $LOGGER->debug ($msg);
}

### Append validation failures for the given operation.
### Messages are pushed in "ERROR" array.
sub addToError {
    my ($self, $op, $msg, $flowType) = @_;

    $op->{$KEY_RESULT}="fail";
    my $errMsg   =  "TYPE=\"ERR\"";
    $errMsg     .=  ",message=\"In " . $flowType . " flow, " . $msg . "\"";

    push (@{$op->{$KEY_ERROR}}, $errMsg);
    $LOGGER->debug ($errMsg);
}


### Many PQ tasks are req/response model. Find the response id
### for a given request id.
###
### There should always be one match since the search logic uses
### "ADD" message with a specific "logid". Array is used so as 
### to catch multiple messages, if any, as a potential problem.
sub getPQRspId {
    my ($self, $pqId, $pqReqId) = @_;
    
    $LOGGER->debug ("Searching PQ response for id : " . $pqId . " request : " . $pqReqId);
    my @pqRsps = ();
    my $rsp    = $self->{$PQ_REQHASH}{$pqReqId};
    @pqRsps    = @$rsp if (defined $rsp);

    @pqRsps    = grep { $_ ne $pqId } @pqRsps;

    $LOGGER->debug ("Found (" . join(",", @pqRsps) . " ) PQ response for request : " . $pqReqId);
    return \@pqRsps;
}

sub sortOnTimeAndCommand {
    my ($a, $b) = @_;

    if ($a->{$KEY_EPOCH} < $b->{$KEY_EPOCH}) {
        return -1;
    }
    if ($a->{$KEY_EPOCH} == $b->{$KEY_EPOCH}) {
        my $aOrder = $PQ_LOGS{$a->{$KEY_LOGID}}{$KEY_ORDER};
        my $bOrder = $PQ_LOGS{$b->{$KEY_LOGID}}{$KEY_ORDER};
        if ($aOrder < $bOrder) {
            return -1;
        }
        if ($aOrder == $bOrder) {
            return 0;
        }
    }
    return 1;
}

### Create a Hash for each pqid, create an array of all messages of
### the same id and link in a hash based off the same id as key.
sub linkPQMessages {
    my ($self, $pqLogs) = @_;

    foreach my $pqLog (@{$pqLogs}) {
        my $pqId    = $pqLog->{$KEY_PQID};
        my $pqReqId = $pqLog->{$KEY_PQREQ};
        my $pqLogId = $pqLog->{$KEY_LOGID};
        push (@{$self->{PQ_HASH}{$pqId}}, $pqLog);

        next if ($pqLogId ne $LOGID_ADD);
        next if (!defined $pqReqId);
        push (@{$self->{PQ_REQHASH}{$pqReqId}}, $pqId);
    }

    ### Ensure message ordering is correct based on timestamp
    foreach my $pqId (keys %{$self->{PQ_HASH}}) {
        my @arr = @{$self->{PQ_HASH}{$pqId}};
        #my @sortedArr = sort { $a->{epoch} <=> $b->{epoch} } @arr;
        my @sortedArr = sort { sortOnTimeAndCommand($a, $b) } @arr;
        $self->{PQ_HASH}{$pqId} = \@sortedArr;
    }
}

sub parseTimePattern {
    my ($self, $logLine) = @_;

    ### logLine has time at the beginning, with following format:
    ###   "Sun Aug 12 00:21:54 PST 2012 (T2:*:*:*:23ftw1:UI1225002)..."
    #$logLine =~ /^(.*)\(/; ### Why this doesn't work? TBD
    $logLine =~ /^([\w\s:]+)/;
    my $timedata = $1;
    $timedata =~ s/\s+$//;
    $LOGGER->trace("Time pattern: $timedata");
    #my $time = Time::Piece->strptime($timedata, "%A %B %d %H:%M:%S PST %Y");
    my $parser = DateTime::Format::Strptime->new(
                                   pattern => '%A %B %d %H:%M:%S PST %Y',
                                   on_error => 'croak',);
    my $time = $parser->parse_datetime($timedata);
    return ($timedata, $time->epoch)
}

sub parsePQPattern {
    my ($self, $logLine) = @_;

    ### logLine has content of interest in following format:
    ###   "pqbegin[pqid=msg-1;pqreq=null;remoteclient=null;]pqend"
    ### where:
    ### - id is the pq message
    ### - req is the previous pq message for which "id" is being sent
    ### - remoteclient is the client connected for the session
    $logLine =~ /pqbegin\[(.*)\]pqend/;
    my $pqdata = $1;
    $LOGGER->trace("PQ pattern: $pqdata");
    my %hash = split /[;=]/, $pqdata;
    return %hash;
}

sub readIDLines {
    my ($self, $logDir, $ids, $startNode) = @_;

    ### Get list of log files to process
    opendir DIR, $logDir or die $!;
    my @files = readdir DIR;
    closedir DIR;   

    $LOGGER->debug ("Looking for IDs: ". join(",", @$ids) . " for $startNode files");
    my @logLines;
    my $index=0;
    foreach my $file (@files) {
        next if ($file !~ m/keepRunning.*--.*$startNode.*/i);

        #$file =~ /^keepRunning.*--(.*[\w]+)/;
        $file =~ /^keepRunning.*--(.*)-.*/;
        my $client = $1;
        my $fullPath = $logDir . "/" . $file;
        $LOGGER->debug ("File Path: $fullPath");

        open my $FILE, $fullPath or die $!;
        while (my $line = <$FILE>) {
            chomp $line;  ### Remove newlines, comments and empty lines
            foreach my $id (@$ids) {
                next if ($line !~ m/\[$id\]:/i);
                
                $logLines[$index]{$KEY_LOGID}=$id;
                $logLines[$index]{$KEY_LINE}=$line;
                $logLines[$index]{$KEY_LOGFILE}=$fullPath;
                $logLines[$index]{$KEY_CLIENT}=$client;

                my ($timedata, $epoch) = $self->parseTimePattern ($line);
                $logLines[$index]{$KEY_TIME}=$timedata;
                $logLines[$index]{$KEY_EPOCH}=$epoch;

                my %pqPattern = $self->parsePQPattern ($line);
                $logLines[$index]{$KEY_PQID}=$pqPattern{$KEY_PQID};
                $logLines[$index]{$KEY_PQREQ}=$pqPattern{$KEY_PQREQ} || "";
                $logLines[$index]{$KEY_RCLIENT}=$pqPattern{$KEY_RCLIENT} || "";
                $logLines[$index]{$KEY_TASK}=$pqPattern{$KEY_TASK} || "";
                $logLines[$index]{$KEY_REALM}=$pqPattern{$KEY_REALM} || "";
                $logLines[$index]{$KEY_PORT}=$pqPattern{$KEY_PORT} || "";
                $logLines[$index]{$KEY_QUEUE}=$pqPattern{$KEY_QUEUE} || "";

                $logLines[$index]{$KEY_MATCH}="";

                $index++;
            }
        }
        close $FILE;
    }
    return @logLines;
}

sub readLogs {
    my ($self, $opLogId, $startNode, $logDir) = @_;
    
    $LOGGER->info ("Reading logs...");

    ### Fetch all lines matching the Operation log ids.
    $LOGGER->info ("Reading $startNode files to fetch log lines for operation");
    push (my @opLogIds, $opLogId);
    @{$self->{$OP_LOGS}} = $self->readIDLines ($logDir, \@opLogIds, $startNode);
    $LOGGER->info ("Found " . scalar @{$self->{$OP_LOGS}} . " operation log ids to track");
    $LOGGER->debug ( Dumper (@{$self->{$OP_LOGS}}));

    ### Fetch all lines matching PQ log ids.
    $LOGGER->info ("Reading MANAGER files to fetch log lines for PQ messages");
    my @pqLogIds = keys %PQ_LOGS;
    my @arr = $self->readIDLines ($logDir, \@pqLogIds, "MANAGER");
    $LOGGER->info ("Found " . scalar @arr . " PQ log ids to search from");
    $LOGGER->trace ( Dumper (@arr));

    ### Link PQ messages 
    $self->linkPQMessages(\@arr);
    $LOGGER->info ("Found " . scalar (keys %{$self->{$PQ_HASH}}) . " PQ message ids to search from");
    $LOGGER->debug ( Dumper ($self->{$PQ_HASH}));
    $LOGGER->info ("Found " . scalar (keys %{$self->{$PQ_REQHASH}}) . " PQ request ids in ADD ");
    $LOGGER->debug ( Dumper ($self->{$PQ_REQHASH}));

    $LOGGER->info ("Reading logs -- done");
}

sub validateOps {
    my ($self) = @_;
    $LOGGER->info ("Validating all operations ...");
    foreach my $op (@{$self->{$OP_LOGS}}) {
        $LOGGER->debug ("Validating ID: $op->{$KEY_LOGID}, Task: $op->{$KEY_TASK}, Realm: $op->{$KEY_REALM}");
        $LOGGER->trace(Dumper($op));
        $op->{$KEY_RESULT}="success";
        $self->validateOp ($op);
    }
    $LOGGER->info ("Validating all operations -- done");
}

sub printOps {
    my ($self) = @_;

    foreach my $op (@{$self->{$OP_LOGS}}) {
        $LOGGER->debug ("------------");
        $LOGGER->debug ("OP: " . $op->{$KEY_LOGID});
        $LOGGER->debug ("Initiated by: " . $op->{$KEY_CLIENT});
        $LOGGER->debug ("Initiated at: " . $op->{$KEY_TIME});
        $LOGGER->debug ("Result: " . $op->{$KEY_RESULT});
        if (defined $op->{$KEY_FLOW}) {
            my @arrToLog = @{$op->{$KEY_FLOW}};
            $LOGGER->debug ("Flow:");
            foreach my $log (@arrToLog) {
                $LOGGER->debug ("    " . $log);
            }
        }
        if (defined $op->{$KEY_ERROR}) {
            my @arrToLog = @{$op->{$KEY_ERROR}};
            $LOGGER->debug ("Errors:");
            foreach my $log (@arrToLog) {
                $LOGGER->debug ("    " . $log);
            }
        }
        $LOGGER->debug ("------------");
    }

}

sub logOps {
    my ($self, $logDir) = @_;

    $LOGGER->info ("Logging ops ...");

    ### Wipe out previous rundata, if any
    my $runDir = $logDir . "/outputdir";
    $LOGGER->info ("Cleaning up $runDir");
    mkdir $runDir unless -d $runDir;
    unlink glob "$runDir/*";
    
    $LOGGER->info ("Writing logs to $runDir");
    my $uuid = new Data::UUID;
    my $statusFile = $runDir . "/op-status.txt";
    open FH_STATUS, ">>$statusFile" or die $!;
    foreach my $op (@{$self->{$OP_LOGS}}) {

        ### First create a subfile, one for every op
        my $fileId = $uuid->create_str();
        my $subFile = $runDir . "/" . $fileId . ".txt";
        open FH_SUB, ">>$subFile" or die $!;

        ### Create detailed message for all flow/error and add to the subfile
        my $opLog;
        if (defined $op->{$KEY_FLOW}) {
            my @arrToLog = @{$op->{$KEY_FLOW}};
            foreach my $log (@arrToLog) {
                print FH_SUB $log . "\n";
            }
        }
        if (defined $op->{$KEY_ERROR}) {
            my @arrToLog = @{$op->{$KEY_ERROR}};
            foreach my $log (@arrToLog) {
                print FH_SUB $log . "\n";
            }
        }
        close FH_SUB;

        ### Create status entry and add to the mainfile
        my $statusLine = "$KEY_REALM=\"$op->{$KEY_REALM}\",";
        $statusLine   .= "$KEY_TASK=\"$op->{$KEY_TASK}\",";
        $statusLine   .= "$KEY_TIME=\"$op->{$KEY_TIME}\",";
        $statusLine   .= "$KEY_RESULT=\"$op->{$KEY_RESULT}\",";
        $statusLine   .= "subfile=\"$subFile\"";

        print FH_STATUS $statusLine . "\n";
    }
    close FH_STATUS;

    $LOGGER->info ("Logging ops -- done");
}
