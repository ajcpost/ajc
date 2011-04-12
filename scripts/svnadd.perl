#!/usr/bin/perl
#
# This command is used to recursively add items to a subversion repository. All directories and 
# files will be added.
#
# Dependencies:
#     The svn command must be installed. 
#
# Usage:
#
#     svnadd <directory/filename> [another directory/filename] [another directory/filename]...
#
# Support:
#
#     If you have trouble with this script, please contact:
#             Anthony Hildoer <anthony@hildoersystems.com>
#
# Version:
#
#     1.1_Alpha - 20080315 - Modified commmad line argument validation.
#             - Only follows/adds normal directories and files. The following now ignored:
#                 -symbolic links
#                 -named pipes (FIFO)
#                 -sockets
#                     -block special files
#                     -character special files
#                     -Filehandles to opened tty
#     1.0_Alpha - 20070927 - Initial release.
#
# Copyright:
#
#     Hildoer Systems 2007 
#
# Warranty:
#     
#     This product in no way comes with a warranty. Any use is strictly at your
#     own risk. If you have any concern regarding program behaviour, please feel
#     free to contact the developer. See "Support" for contact information. 
#
#####################################################################################
 
use strict;
use warnings;
 
my $start = "";
 
if (@ARGV < 1) {
 
    print "Please specify a directory or filename.\n";
 
    exit 1;    
 
} else {
 
    my $index = 0;
 
    # get all command line options 
    foreach $start (@ARGV) {
 
        if ( $start !~ /^\.svn$/) {
 
            if ( -f $start || -d $start) {
 
                processDirectory($start, "");
 
            } else { # only direct
 
                print "'$start' is not a directory or file.\n";
 
            }
        }    
 
    }
 
}
 
exit 0;
 
# SUBROUTINES
 
# add the file
sub addFile {
 
    my ($file, $indent) = @_;
 
    0 && print $indent."\tProcessing file: $file\n";
 
    my $result = `svn add "$file" 2>&1`;
 
    if ( `echo $?` != 0 ) {
        $result =~ s/\n/\n$indent\t/g;
        print $indent . "\tError: $result: $file\n";
    }
 
}
 
# check contents of $directory, process any directories contained therein. 
sub processDirectory {
 
    my ($rootFile, $indent) = @_;
 
        my $dirHandle;
    my $file;
    my @directories;
 
    if ( $rootFile =~ /^\.svn$/ || -l $rootFile || -p $rootFile || -S $rootFile || -b $rootFile || -c $rootFile || -t $rootFile ) {
        print $indent."Skipping: $rootFile\n";
        return 0;
    }
 
    print $indent."Processing file: $rootFile\n";
 
    addFile($rootFile, $indent);
 
    # unless file is a directory, don't try to open it.
    if (-d $rootFile) {
        print $indent."\tOpening directory\n";
    } else {
        return 0;
    }
 
    if (chdir($rootFile)) {
 
        opendir($dirHandle, ".");
 
        # iterate through contents of the directory
               foreach $file (sort readdir($dirHandle)) {
 
            # do not process the . and .. relative directory referenses
            if ( $file !~ /^\.$/ && $file !~ /^\.\.$/ ) {
 
                # if file is a directory, process it's contents before
                # setting permissions.
                if ( -d $file ) {
                    processDirectory($file, $indent."\t");
                } elsif ( -f $file ) {
                    addFile($file, $indent."\t");
                }
 
            }
 
        }
 
        chdir("..");
 
    } else {
 
        print $indent."Could not open directory: $rootFile. Skipping.\n";
        return -1;
    }
 
    return 0;
}

