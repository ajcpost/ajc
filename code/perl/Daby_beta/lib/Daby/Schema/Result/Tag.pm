use utf8;
package Daby::Schema::Result::Tag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Daby::Schema::Result::Tag

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

=head1 TABLE: C<tag>

=cut

__PACKAGE__->table("tag");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 tag

  data_type: 'varchar'
  is_nullable: 0
  size: 30

=head2 description

  data_type: 'varchar'
  is_nullable: 0
  size: 200

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "tag",
  { data_type => "varchar", is_nullable => 0, size => 30 },
  "description",
  { data_type => "varchar", is_nullable => 0, size => 200 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 article_tags

Type: has_many

Related object: L<Daby::Schema::Result::ArticleTag>

=cut

__PACKAGE__->has_many(
  "article_tags",
  "Daby::Schema::Result::ArticleTag",
  { "foreign.tagid" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 articleids

Type: many_to_many

Composing rels: L</article_tags> -> articleid

=cut

__PACKAGE__->many_to_many("articleids", "article_tags", "articleid");


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-07-03 18:39:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3Poj+dn6fQinFIyP5arF7Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
