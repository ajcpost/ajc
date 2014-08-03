package Daby::Schema::ResultSet::Article;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Daby::BL::Constants;


### Don't apply any constraints in this case
sub byID {
  my ($self, $aID) = @_;
  return $self->search({id => $aID});
} 

sub fullSet {
  my ($self, $page, $articleState, $articleType) = @_;

  ### TBD, fix this

  return $self->search( {
      -and => [
        article_state => $articleState,
        article_type => $articleType
      ], }, {page => $page, order_by => 'updated desc', rows => 6} ) if defined ($articleType);
  return $self->search( {
      -and => [
        article_state => $articleState,
        article_type => { 'not in' => [$Daby::BL::Constants::ARTICLE_TYPE_TEST] }
      ], }, {page => $page, order_by => 'updated desc', rows => 6} );
}

sub byUser {
  my ($self, $uID, $page, $articleState, $articleType) = @_;

  ### TBD, fix this

  return $self->search( {
      -and => [
        userid => $uID,
        article_state => $articleState,
        article_type => $articleType
      ], }, {page => $page, order_by => 'updated desc', rows => 6} ) if defined ($articleType);
  return $self->search( {
      -and => [
        userid => $uID,
        article_state => $articleState,
        article_type => { 'not in' => [$Daby::BL::Constants::ARTICLE_TYPE_TEST] }
      ], }, {page => $page, order_by => 'updated desc', rows => 6} );
}

sub byTag {
  my ($self, $tID, $page, $articleState, $articleType) = @_;

  ### TBD, fix this

  return $self->search( {
      -and => [
        'article_tags.tagid'=> $tID,
        article_state => $articleState,
        article_type => $articleType
      ], }, {join => 'article_tags', page => $page, order_by => 'updated desc', rows => 6} ) if defined ($articleType);

  return $self->search( {
      -and => [
        'article_tags.tagid'=> $tID,
        article_state => $articleState,
        article_type => { 'not in' => [$Daby::BL::Constants::ARTICLE_TYPE_TEST] }
      ], }, {join => 'article_tags', page => $page, order_by => 'updated desc', rows => 6} );
}

#  return $self->search( {
#      -and => [
#        -or => [ 
#          article_type => $Daby::BL::Constants::ARTICLE_TYPE_NORMAL
#        ],
#        article_state => $articleState,
#        userid => $uID,
#      ], }, {page => $page, order_by => 'updated desc', rows => 6} );
#

1;
