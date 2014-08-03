package Daby::Controller::Article::Entries;
use Moose;
use namespace::autoclean;
use DateTime;
use Daby::Form::Comment;
use Daby::Form::Article;
use Daby::BL::Constants;
use Daby::BL::Utils;
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

  my $row   = $c->model('DB::Article')->byID($aID)->first; 
  if (!$row) {
    $c->detach('/unauthorized_action');
  }

  if ($row->article_state == $Daby::BL::Constants::ARTICLE_STATE_REVOKED) {
      $c->detach('/unauthorized_action');
  }
  if ($row->article_state == $Daby::BL::Constants::ARTICLE_STATE_SAVED) {
    if ( !Daby::BL::Utils::isUserLogged ($c) || !Daby::BL::Utils::canEditArticle ($c, $aID) ) {
      $c->detach('/unauthorized_action');
    }
  }
  if ($row->article_state == $Daby::BL::Constants::ARTICLE_STATE_SUBMITTED) {
    if ( !Daby::BL::Utils::isUserLogged ($c) || !Daby::BL::Utils::canApproveArticle ($c, $aID) ) {
      $c->detach('/unauthorized_action');
    }
  }


  ### Add the article and comments to stash
  $c->stash(article => $row);
  my $htmlcontent = Daby::BL::ContentStore::readContentFromFile($row->content_location);
  $c->stash(htmlcontent => $htmlcontent);

  my @all_comments = $c->model('DB::Comment')->byArticle($aID);
  my @htmlcomments;
  for my $comment (@all_comments) {
    my $content = Daby::BL::ContentStore::readContentFromFile($comment->content_location);
    push (@htmlcomments, {user => $comment->userid->name, time => $comment->created, content => $content});
  }
  $c->stash(comments => [@all_comments]);
  $c->stash(htmlcomments => [@htmlcomments]);

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

sub createnormal :Local :Args(0) {
  my ($self, $c) = @_;

  $self->create ($c, $Daby::BL::Constants::ARTICLE_TYPE_NORMAL);
}

sub createteaser :Local :Args(0) {
  my ($self, $c) = @_;

  $self->create ($c, $Daby::BL::Constants::ARTICLE_TYPE_TEASER);
}

sub create {
  my ($self, $c, $articleType) = @_;

  if (!Daby::BL::Utils::isUserLogged ($c)) {
    $c->detach('/unauthorized_action');
  }

  ### This routine is called from two places
  ### - via link to create the article, this should display the form
  ### - as part of form's post action, this should do db save and
  ###   reroute

  ### Push user id in the form, this will be used in update_model to
  ### set the article table column.
  my $item = $c->model('DB::Article')->new_result({userid => $c->user->id, article_type => $articleType}); 
  $c->stash->{item} = $item;
  $c->stash->{article_type} = $articleType;
  my $form = Daby::Form::Article->new( item => $c->stash->{item});
  $c->stash(template => 'article/entries/create.tt', form => $form );

  ### Display the form. This API will return false and hence redisplay
  ### the form if any of the validation fails
  return unless $form->process(
     params => $c->req->params,
     schema => $c->model('DB')->schema,
  );
  ### Redirect to submitted page
  $c->res->redirect($c->uri_for_action('/article/mysaved'));
}

sub edit :Local :Args(1) {
  my ($self, $c, $aID) = @_;

  my $row   = $c->model('DB::Article')->byID($aID)->first; 
  if (!Daby::BL::Utils::isUserLogged ($c) || 
      !Daby::BL::Utils::canEditArticle ($c, $aID)) {
    $c->detach('/unauthorized_action');
  }

  $c->stash->{item} = $row;
  $c->stash->{article_type} = $row->article_type;
  my $form = Daby::Form::Article->new( item => $c->stash->{item} );
  $c->stash(template => 'article/entries/edit.tt', form => $form );

  return unless $form->process(
    item_id => $row->id,
    params => $c->req->params,
    schema => $c->model('DB')->schema,
  );
  ### Redirect to saved page
  $c->res->redirect($c->uri_for_action('/article/mysaved'));
}

sub changestate :Local :Args(2) {
  my ($self, $c, $aID, $changeState) = @_;

  my $row   = $c->model('DB::Article')->byID($aID)->first; 
  if (!Daby::BL::Utils::isUserLogged ($c)) {
    $c->detach('/unauthorized_action');
  }

  if ($changeState eq "approve" && Daby::BL::Utils::canApproveArticle ($c, $aID)) {
    $row->article_state ($Daby::BL::Constants::ARTICLE_STATE_PUBLISHED);
    $row->update;
    $c->res->redirect($c->uri_for_action('/article/approve'));
  }
  elsif ($changeState eq "revoke" && Daby::BL::Utils::canApproveArticle ($c, $aID)) {
    $row->article_state ($Daby::BL::Constants::ARTICLE_STATE_REVOKED);
    $row->update;
    $c->res->redirect($c->uri_for_action('/article/approve'));
  }
  elsif ($changeState eq "submit" && Daby::BL::Utils::canSubmitArticle ($c, $aID)) {
    $row->created(DateTime->now(time_zone => "local"));
    $row->article_state ($Daby::BL::Constants::ARTICLE_STATE_SUBMITTED);
    $row->update;
    $c->res->redirect($c->uri_for_action('/article/mysaved'));
  }
  else {
    $c->detach('/unauthorized_action');
  }
}

sub delete :Local :Args(1) {
  my ($self, $c, $aID) = @_;

  my $row   = $c->model('DB::Article')->byID($aID)->first; 
  if (!Daby::BL::Utils::isUserLogged ($c) || 
      !Daby::BL::Utils::canDeleteArticle ($c, $aID)) {
    $c->detach('/unauthorized_action');
  }

  $c->stash(article => $row);
  $c->stash(htmlcontent => Daby::BL::ContentStore::readContentFromFile($row->content_location));
  my @all_comments = $c->model('DB::Comment')->byArticle($aID);
  my @htmlcomments;
  for my $comment (@all_comments) {
    my $content = Daby::BL::ContentStore::readContentFromFile($comment->content_location);
    push (@htmlcomments, {user => $comment->userid->name, time => $comment->created, content => $content});
  }
  $c->stash(comments => [@all_comments]);
  $c->stash(htmlcomments => [@htmlcomments]);

  ### This routine is called from two places
  ### - via link to edit the article, this should display the form
  ### - as part of form's post action, this should do db update and
  ###   reroute
  my $submit = $c->req->params->{submit};
  if (defined $submit) {
    ### Form's post action
    if ($submit eq 'Yes') {
      ### Delete all comments
      my @all_comments = $c->model('DB::Comment')->byArticle($aID);
      for my $comment (@all_comments) {
        Daby::BL::ContentStore::deleteFileContent($comment->content_location);
        $comment->delete;
      }

      ### Now delete the article
      $row->delete; 
      Daby::BL::ContentStore::deleteFileContent($row->content_location);

      $c->res->redirect($c->uri_for_action('/article/mysaved'));
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
