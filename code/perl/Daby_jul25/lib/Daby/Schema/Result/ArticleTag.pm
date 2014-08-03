use utf8;
package Daby::Schema::Result::ArticleTag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Daby::Schema::Result::ArticleTag

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

=head1 TABLE: C<article_tag>

=cut

__PACKAGE__->table("article_tag");

=head1 ACCESSORS

=head2 articleid

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 tagid

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "articleid",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "tagid",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</articleid>

=item * L</tagid>

=back

=cut

__PACKAGE__->set_primary_key("articleid", "tagid");

=head1 RELATIONS

=head2 articleid

Type: belongs_to

Related object: L<Daby::Schema::Result::Article>

=cut

__PACKAGE__->belongs_to(
  "articleid",
  "Daby::Schema::Result::Article",
  { id => "articleid" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 tagid

Type: belongs_to

Related object: L<Daby::Schema::Result::Tag>

=cut

__PACKAGE__->belongs_to(
  "tagid",
  "Daby::Schema::Result::Tag",
  { id => "tagid" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-07-01 14:25:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Jca/tsVEJHmprf55WZI9rw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
