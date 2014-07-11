#!/usr/bin/perl
use strict;
use warnings;
use Daby::Schema;

# $ perl -Ilib sethashedpasswords.pl 

my $schema = Daby::Schema->connect('dbi:mysql:daby', 'daby', 'daby');
my @users = $schema->resultset('User')->all;
foreach my $user (@users) {
    $user->password('GoDaby123');
    $user->update;
}
