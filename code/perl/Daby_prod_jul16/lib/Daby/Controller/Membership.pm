package Daby::Controller::Membership;
use Moose;
use namespace::autoclean;
use Daby::Form::NewUser;
use Daby::Form::EditUser;
use Daby::BL::Utils;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Daby::Controller::Member - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
  my ( $self, $c ) = @_;

  ### Checks
  #$c->detach('/unauthorized_action') if !$c->user_exists;

  $c->stash(users => [Daby::BL::Utils::sortUsers($c)]);
  #$c->stash(users => [$c->model('DB::User')->fullSet]);
  $c->stash->{template} = 'membership/list.tt';
}

sub create :Local {
  my ( $self, $c ) = @_;

  $c->stash->{item} = $c->model('DB::User')->new_result({});
  my $form = Daby::Form::NewUser->new( item => $c->stash->{item}  );
  $c->stash(template => 'membership/create.tt', form => $form );

  ### Validate and insert data into database
  return unless $form->process(
    params => $c->req->parameters,
    schema => $c->model('DB')->schema
  );

  $c->authenticate({ username => $form->value->{username}, password => $form->value->{password} });
  $c->res->redirect($c->uri_for_action('/membership/index'));
}

sub edit :Local :Args(1) {
  my ( $self, $c, $uID ) = @_;

  ### Checks
  my $row = $c->model('DB::User')->byID($c->user->id)->first;
  if (!$c->user_exists  || 
      !$row ||
      $c->user->id != $uID) {
    $c->detach('/unauthorized_action');
  }

  my $form = Daby::Form::EditUser->new( item => $c->stash->{item}  );
  $c->stash(template => 'membership/edit.tt', form => $form );

  ### Validate and update user row in user table.
  return unless $form->process(
    item_id => $uID, 
    params => $c->req->params,
    schema => $c->model('DB')->schema,
  );

  $c->res->redirect($c->uri_for_action('/membership/index'));
}

sub delete :Local :Args(1) {
  my ( $self, $c, $uID ) = @_;

  ### Checks
  my $row = $c->model('DB::User')->byID($c->user->id)->first;
  if (!$c->user_exists  || 
      !$row ||
      $c->user->id != $uID) {
    $c->detach('/unauthorized_action');
  }

  my $submit = $c->req->params;
  if ($submit->{submit} eq 'Yes') {
    $c->model('DB::User')->byID($uID)->delete; 
    $c->res->redirect($c->uri_for_action('/logout/index'));
  }
  elsif ($submit->{submit} eq 'No') {
    $c->res->redirect($c->uri_for_action('membership/index'));
  }

  $c->detach($c->view("TT"));
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
