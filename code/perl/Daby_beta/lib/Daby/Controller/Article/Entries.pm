package Daby::Controller::Article::Entries;
use Moose;
use namespace::autoclean;
use Daby::Form::Comment;
use Daby::Form::Article;
use Daby::BL::Constants;
use Daby::BL::ContentStore;
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller'; }

has 'comment_form' => (
  isa => 'Daby::Form::Comment',
  is => 'rw',
  lazy => 1,
  default => sub { Daby::Form::Comment->new }
);

=head1 NAME

Daby::Controller::Article::Entries - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(1) {
  my ($self, $c, $aID) = @_;

  ### Block if row is not found, this will prevent someone
  ### giving dummy ids in URL resulting in exception stack
  my $row = $c->model('DB::Article')->byID($aID)->first;
  $c->detach('/unauthorized_action') if !$row;

  ### Add the article and comments to stash
  $c->stash(article => $row);
  $c->stash(htmlcontent => Daby::BL::ContentStore::readContentFromFile($row->content_location));
  $c->stash(comments => [$c->model('DB::Comment')->byArticle($aID)]);

  if ($c->user_exists) {
    ### Allow new comments only if User is logged in
    $c->stash(template => 'article/entries/index.tt', form => $self->comment_form);

    ### Store new comment to DB
    $row = $c->model('DB::Comment')->new_result({});
    $row->articleid($aID);
    $row->userid($c->user->id);
    return unless $self->comment_form->process (
      item => $row,
      params => $c->req->params,
    );

    # Refresh the page.
    $c->res->redirect($c->uri_for_action('/article/entries/index', $aID));
  }
  else {
    return;
  }
}

sub create :Local :Args(0) {
  my ($self, $c) = @_;

  ### Checks
  my $row = $c->model('DB::User')->byID($c->user->id)->first; 
  if (!$c->user_exists  || !$row) {
    $c->detach('/unauthorized_action');
  }

  ### This routine is called from two places
  ### - via link to create the article, this should display the form
  ### - as part of form's post action, this should do db save and
  ###   reroute

  ### Push user id in the form, this will be used in update_model to
  ### set the article table column.
  $c->stash->{item} = $c->model('DB::Article')->new_result({userid => $c->user->id}); 
  my $form = Daby::Form::Article->new( item => $c->stash->{item}  );
  $c->stash(template => 'article/entries/create.tt', form => $form );

  ### Display the form. This API will return false and hence redisplay
  ### the form if any of the validation fails
  return unless $form->process(
     params => $c->req->params,
     schema => $c->model('DB')->schema,
  );
  ### Redirect to submitted page
  $c->res->redirect($c->uri_for_action('/article/mysubmitted', {memberName => $c->user->username}));
}

sub edit :Local :Args(1) {
  my ($self, $c, $aID) = @_;

  ### Checks
  ### - if user is not logged-in
  ### - if article is not found
  ### - if user doesn't own the article and is not an approver
  my $row     = $c->model('DB::Article')->byID($aID)->first; 
  my $userrow = $c->model('DB::User')->byID($c->user->id)->first; 
  if (!$c->user_exists  ||
      !$row || 
      !$userrow || 
      ($c->user->id != $row->userid->id && !$c->user->hasRole($Daby::BL::Constants::ROLE_APPROVER))) {
    $c->detach('/unauthorized_action');
  }

  $c->stash->{item} = $row;
  my $form = Daby::Form::Article->new( item => $c->stash->{item}  );
  $c->stash(template => 'article/entries/edit.tt', form => $form );

  return unless $form->process(
    item_id => $row->id,
    params => $c->req->params,
    schema => $c->model('DB')->schema,
  );
  ### Redirect to submitted page
  $c->res->redirect($c->uri_for_action('/article/mysubmitted', {memberName => $c->user->username}));
}

sub changestate :Local :Args(2) {
  my ($self, $c, $aID, $changeState) = @_;

  ### Detach 
  ### - if user is not logged-in or is not an approver
  ### - if article is not found
  my $row = $c->model('DB::Article')->byID($aID)->first; 
  if (!$c->user_exists  ||
    !$row || 
    (!$c->user->hasRole($Daby::BL::Constants::ROLE_APPROVER))) {
    $c->detach('/unauthorized_action');
  }

  if ($changeState eq "approve") {
    $row->article_state ($Daby::BL::Constants::ARTICLE_STATE_PUBLISHED);
    $row->update;
  }
  elsif ($changeState eq "revoke") {
    $row->article_state ($Daby::BL::Constants::ARTICLE_STATE_REVOKED);
    $row->update;
  }
  else {
    ### Do nothing
    $c->log->debug ("Change state called with invalid argument: " . $changeState);
  }
  $c->res->redirect($c->uri_for_action('/article/approve'));
}

sub delete :Local :Args(1) {
  my ($self, $c, $aID) = @_;

  ### Detach 
  ### - if user is not logged-in
  ### - if article is not found
  ### - if user doesn't own the article and is not an admin user
  my $row     = $c->model('DB::Article')->byID($aID)->first; 
  my $userrow = $c->model('DB::User')->byID($c->user->id)->first; 
  if (!$c->user_exists  ||
      !$row || 
      !$userrow || 
     ($c->user->id != $row->userid->id && !$c->user->hasRole($Daby::BL::Constants::ROLE_APPROVER))) {
      $c->detach('/unauthorized_action');
  }

  $c->stash(article => $row);
  $c->stash(comments => [$c->model('DB::Comment')->byArticle($aID)]);

  ### This routine is called from two places
  ### - via link to edit the article, this should display the form
  ### - as part of form's post action, this should do db update and
  ###   reroute
  my $submit = $c->req->params->{submit};
  if (defined $submit) {
    ### Form's post action
    if ($submit eq 'Yes') {
      $row->delete; 
      $c->stash(htmlcontent => Daby::BL::ContentStore::deleteFileContent($row->content_location));
      $c->res->redirect($c->uri_for_action('/article/index'));
    }
    else {
      $c->res->redirect($c->uri_for_action('/article/entries/index', $aID));
    }
  }
  ### if $submit is not defined, default route will display the form
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
