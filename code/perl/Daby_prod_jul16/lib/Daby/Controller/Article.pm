package Daby::Controller::Article;
use Moose;
use namespace::autoclean;
use Data::Dumper;
use Template::Plugin::Table;
use Daby::BL::Constants;
use Daby::BL::Utils;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Daby::Controller::Article - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
  my ( $self, $c ) = @_;
  my $articleState  = $Daby::BL::Constants::ARTICLE_STATE_PUBLISHED;

  $self->process ($c, $articleState);
  $c->stash->{viewType} = 'display';
  $c->stash->{template} = 'article/list.tt';
}

sub show :Local {
  my ( $self, $c ) = @_;
  my $articleState  = $Daby::BL::Constants::ARTICLE_STATE_PUBLISHED;

  $self->process ($c, $articleState);
  $c->stash->{viewType} = 'display';
  $c->stash->{template} = 'article/list.tt';
}

sub mypublished :Local {
  my ( $self, $c ) = @_;
  my $articleState  = $Daby::BL::Constants::ARTICLE_STATE_PUBLISHED;

  $c->detach('/unauthorized_action') unless Daby::BL::Utils::isUserLogged($c);

  $self->process ($c, $articleState);
  $c->stash->{viewType} = 'display';
  $c->stash->{template} = 'article/list.tt';
}

sub mysubmitted :Local {
  my ( $self, $c ) = @_;
  my $articleState  = $Daby::BL::Constants::ARTICLE_STATE_SUBMITTED;

  $c->detach('/unauthorized_action') unless Daby::BL::Utils::isUserLogged($c);

  $self->process ($c, $articleState);
  $c->stash->{viewType} = 'display';
  $c->stash->{template} = 'article/list.tt';
}

sub mysaved :Local {
  my ( $self, $c ) = @_;
  my $articleState  = $Daby::BL::Constants::ARTICLE_STATE_SAVED;

  $c->detach('/unauthorized_action') unless Daby::BL::Utils::isUserLogged($c);

  $self->process ($c, $articleState);
  $c->stash->{viewType} = 'display';
  $c->stash->{template} = 'article/list.tt';
}

sub approve :Local {
  my ( $self, $c ) = @_;
  my $articleState  = $Daby::BL::Constants::ARTICLE_STATE_SUBMITTED;

  $c->detach('/unauthorized_action') unless Daby::BL::Utils::isUserLogged($c);
  $c->detach('/unauthorized_action') unless $c->user->hasRole($Daby::BL::Constants::ROLE_APPROVER);

  $self->process ($c, $articleState);
  $c->stash->{viewType} = 'approve';
  $c->stash->{template} = 'article/list.tt';
}

sub process {
  my ( $self, $c, $articleState ) = @_;

  ### Filter the list based on tagName or memberName
  ### Return back paginated rows
  my $page      = $c->req->param('page') || 1;

  my $tagName    = $c->req->param('tagName');
  my $memberName = $c->req->param('memberName');

  my $articles;
  if (defined $tagName && $tagName ne "") {
    $c->log->debug ("Will search articles by tag: " . $tagName );

    ### Detach if tag is not found
    my $tag = $c->model('DB::Tag')->byName($tagName)->first;
    $c->detach('/unauthorized_action') if !$tag;

    $articles = $c->model('DB::Article')->byTag ($tag->id, $page, $articleState);
    $c->stash->{tagName}  = $tagName;
  }
  elsif (defined $memberName && $memberName ne "") {
    $c->log->debug ("Will search articles by member: " . $memberName );

    ### Detach if user is not found
    my $user = $c->model('DB::User')->byName($memberName)->first;
    $c->detach('/unauthorized_action') if !$user;

    $articles = $c->model('DB::Article')->byUser ($user->id, $page, $articleState);
    $c->stash->{memberName} = $memberName;
  }
  else {
    $c->log->debug ("Returning full set ");
    $articles = $c->model('DB::Article')->fullSet ($page, $articleState);
  }

  $c->stash->{articles}   = [$articles->all];
  $c->stash->{pager}      = $articles->pager;
  $c->stash(users => [$c->model('DB::User')->recent]);
  $c->stash(tags  => [$c->model('DB::Tag')->recent]);
}


=encoding utf8

=head1 AUTHOR

Chitale, Ajay Shrikant

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
