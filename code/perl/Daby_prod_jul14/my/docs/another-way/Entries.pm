package Daby::Controller::Article::Entries;
use Moose;
use namespace::autoclean;
use Daby::Form::Comment;
use Daby::Form::Article;
use Daby::Schema;


BEGIN { extends 'Catalyst::Controller'; }

has 'comment_form' => (
  isa => 'Daby::Form::Comment',
  is => 'rw',
  lazy => 1,
  default => sub { Daby::Form::Comment->new }
);

has 'article_form' => (
  isa => 'Daby::Form::Article',
  is => 'rw',
  lazy => 1,
  default => sub { Daby::Form::Article->new }
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
  my $form = Daby::Form::Article->new( item => $c->stash->{item}  );
  $c->stash(comments => [$c->model('DB::Comment')->byArticle($aID)]);
  $c->stash(template => 'article/entries/index.tt', form1 => $form );

  if ($c->user_exists) {
    ### Allow new comments only if User is logged in
    $c->stash(template => 'article/entries/index.tt', form2 => $self->comment_form);

    ### Store new comment to DB
    $row = $c->model('DB::Comment')->new_result({});
    $row->articleid($aID);
    $row->userid($c->user->id);
    $row->created(DateTime->now);
    return unless $self->comment_form->process(
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

  # Detach if user is not logged-in.
  $c->detach('/unauthorized_action') if !$c->user_exists;

  ### This routine is called from two places
  ### - via link to create the article, this should display the form
  ### - as part of form's post action, this should do db save and
  ###   reroute
  my $submit = $c->req->params->{submit};
  if (defined $submit) {
    my $row;
    if ($submit eq "Yes") {
      $row = $c->model('DB::Article')->new_result({}); 
      $row->title($c->req->params->{title});
      $row->content($c->req->params->{content});
      $c->log->debug ("AJC summernote: " . $c->req->params->{htmlcontent});
      $c->log->debug ("AJC title: " . $c->req->params->{title});
      $row->userid($c->user->id);
      $row->created(DateTime->now);
      $row->updated(DateTime->now);
      $row->article_state($Daby::Schema::ARTICLE_STATE_SUBMITTED);
      $row->article_type($Daby::Schema::ARTICLE_TYPE_NORMAL);
      return if !$row->title || !$row->content;
      $row->insert;
    }

    # Get the most recent article entry if one exists and display it, else go to the /article/index page.
    $row = $c->model('DB::Article')->byUser($c->user->id)->first; 
    if ($row) {
      $c->res->redirect($c->uri_for_action('/article/entries/index', $row->id));
    }
    else {
      $c->res->redirect($c->uri_for_action('/article/index'));
    }
  }

  ### if $submit is not defined, default route will display the form
  $c->stash->{item} = $c->model('DB::Article')->new_result({});
  my $form = Daby::Form::Article->new( {item => $c->stash->{item}} );
  $c->stash(template => 'article/entries/create.tt', form => $form);

}

sub edit :Local :Args(1) {
  my ($self, $c, $aID) = @_;

  ### Detach 
  ### - if user is not logged-in
  ### - if article is not found
  ### - if user doesn't own the article and is not an admin user
  my $row = $c->model('DB::Article')->byID($aID)->first; 
  if (!$c->user_exists  ||
    !$row || 
    ($c->user->id != $row->userid->id && !$c->user->hasRole($Daby::Schema::ROLE_APPROVER))) {
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
    if ($submit eq "Yes") {
      $row->title($c->req->params->{title});
      $row->content($c->req->params->{content});
      $row->updated(DateTime->now);

      ### TBD
      $row->article_state($Daby::Schema::ARTICLE_STATE_SUBMITTED);
      $row->article_type($Daby::Schema::ARTICLE_TYPE_NORMAL);
      return if !$row->title || !$row->content;
      $row->insert;
      $row->update;
    }
    $c->res->redirect($c->uri_for_action('/article/entries/index', $aID));
  }
  ### if $submit is not defined, default route will display the form

  $c->stash->{item} = $row;
  my $form = Daby::Form::Article->new( item => $c->stash->{item}  );
  $c->stash(template => 'article/entries/edit.tt', form => $form );

   return unless $form->process(
     item_id => $row->id,
     params => $c->req->params,
     schema => $c->model('DB')->schema,
   );
   $c->res->redirect($c->uri_for_action('/article/index'));
}

sub delete :Local :Args(1) {
  my ($self, $c, $aID) = @_;

  ### Detach 
  ### - if user is not logged-in
  ### - if article is not found
  ### - if user doesn't own the article and is not an admin user
  my $row = $c->model('DB::Article')->byID($aID)->first; 
  if (!$c->user_exists  ||
    !$row || 
    ($c->user->id != $row->userid->id && !$c->user->hasRole($Daby::Schema::ROLE_APPROVER))) {
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
