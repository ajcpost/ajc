use utf8;
package Daby::Schema::Result::Role;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Daby::Schema::Result::Role

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=item * L<DBIx::Class::PassphraseColumn>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");

=head1 TABLE: C<role>

=cut

__PACKAGE__->table("role");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 role

  data_type: 'varchar'
  is_nullable: 0
  size: 30

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "role",
  { data_type => "varchar", is_nullable => 0, size => 30 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 user_roles

Type: has_many

Related object: L<Daby::Schema::Result::UserRole>

=cut

__PACKAGE__->has_many(
  "user_roles",
  "Daby::Schema::Result::UserRole",
  { "foreign.roleid" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 userids

Type: many_to_many

Composing rels: L</user_roles> -> userid

=cut

__PACKAGE__->many_to_many("userids", "user_roles", "userid");


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-07-01 14:25:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:EiS5lEGnA+iyV3MevYrUFQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;

sub hasRole {
  my ($self, $role) = @_;

  if ($self->role eq $role) {
      return 1;
  }
  return 0;
}

1;