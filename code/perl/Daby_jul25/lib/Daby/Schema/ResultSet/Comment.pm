package Daby::Schema::ResultSet::Comment;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Daby::BL::Constants;

### Don't apply any constraints in this case
sub byID {
  my ($self, $cID) = @_;
  return $self->search({id => $cID});
}

### No limit!! Should we? TBD
sub byArticle {
  my ($self, $aID) = @_;
  return $self->search({articleid => $aID, comment_state => $Daby::BL::Constants::COMMENT_STATE_PUBLISHED});
} 

1;
