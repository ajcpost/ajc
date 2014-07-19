package Daby::Schema::ResultSet::User;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Daby::BL::Constants;

### Don't apply any constraints in this case
sub byID {
  my ($self, $uID) = @_;
  return $self->search({id => $uID});
} 

sub byName {
  my ($self, $uName) = @_;
  return $self->search({username => $uName});
}

sub recent {
  my ($self) = @_;

  return $self->search( {
        -or => [
          user_state => $Daby::BL::Constants::USER_STATE_ACTIVE
        ],}, {order_by => 'id desc', rows => 8} );
} 


sub fullSet {
  my ($self, $uID) = @_;

  return $self->search( {
        -or => [
          user_state => $Daby::BL::Constants::USER_STATE_ACTIVE
        ],}, {order_by => 'username'} );
} 

1;
