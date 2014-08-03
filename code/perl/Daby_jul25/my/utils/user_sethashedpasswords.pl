#!/usr/bin/perl
use strict;
use warnings;
use Daby::Schema;

# $ perl -Ilib sethashedpasswords.pl 

my $schema = Daby::Schema->connect('dbi:mysql:daby', 'daby', 'daby');
my $user = $schema->resultset('User')->byName('smaikap')->first;
$user->password('temp123');
$user->update;
