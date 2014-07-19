package Daby::Schema::ResultSet::Tag;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Daby::BL::Constants;

sub byID {
  my ($self, $tID) = @_;
  return $self->search({id => $tID});
} 

sub byName {
  my ($self, $tName) = @_;
  return $self->search({tag => $tName});
} 

sub recent {
  my ($self) = @_;
  return $self->search({}, {order_by => {-asc => ['tag']}, rows => 5});
}

sub fullSet {
  my ($self, $tID) = @_;
  return $self->search({}, {order_by => {-asc => ['tag']}});
}

1;
