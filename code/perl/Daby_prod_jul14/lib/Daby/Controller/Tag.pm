package Daby::Controller::Tag;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Daby::Controller::Tag - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
  my ( $self, $c ) = @_;

  my $type  = $c->req->param('viewType');
  $c->stash->{viewType} = $type;
  $c->stash(tags => [$c->model('DB::Tag')->fullSet]);
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
