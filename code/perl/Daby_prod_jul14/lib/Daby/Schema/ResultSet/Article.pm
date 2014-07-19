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
  my ($self, $page, $articleState) = @_;

  return $self->search( {
      -and => [
        -or => [ 
          article_type => $Daby::BL::Constants::ARTICLE_TYPE_NORMAL
        ],
        article_state => $articleState,
      ], }, {page => $page, order_by => 'updated desc', rows => 6} );
}

sub byUser {
  my ($self, $uID, $page, $articleState) = @_;

  return $self->search( {
      -and => [
        -or => [ 
          article_type => $Daby::BL::Constants::ARTICLE_TYPE_NORMAL
        ],
        article_state => $articleState,
        userid => $uID,
      ], }, {page => $page, order_by => 'updated desc', rows => 6} );
}

sub byTag {
  my ($self, $tID, $page, $articleState) = @_;

  return $self->search( {
      -and => [
        'article_tags.tagid'=> $tID,
        -or => [ 
          article_type => $Daby::BL::Constants::ARTICLE_TYPE_NORMAL
        ],
        article_state => $articleState,
      ], }, {join => 'article_tags', page => $page, order_by => 'updated desc', rows => 6} );
}

1;
