package Daby::Schema::ResultSet::UserRole;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

### No limit!! Should we? TBD
sub byUser {
  my ($self, $uID) = @_;
  return $self->search({userid => $uID});
} 

1;
