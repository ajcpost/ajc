use utf8;
package Daby::Schema::Result::Article;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Daby::Schema::Result::Article

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

=head1 TABLE: C<article>

=cut

__PACKAGE__->table("article");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 userid

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 title

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 content_summary

  data_type: 'varchar'
  is_nullable: 1
  size: 200

=head2 content_location

  data_type: 'varchar'
  is_nullable: 0
  size: 1000

=head2 created

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 updated

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 article_type

  data_type: 'integer'
  is_nullable: 0

=head2 article_state

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "userid",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "title",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "content_summary",
  { data_type => "varchar", is_nullable => 1, size => 200 },
  "content_location",
  { data_type => "varchar", is_nullable => 0, size => 1000 },
  "created",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "updated",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "article_type",
  { data_type => "integer", is_nullable => 0 },
  "article_state",
  { data_type => "integer", is_nullable => 0 },
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
  { "foreign.articleid" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 comments

Type: has_many

Related object: L<Daby::Schema::Result::Comment>

=cut

__PACKAGE__->has_many(
  "comments",
  "Daby::Schema::Result::Comment",
  { "foreign.articleid" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 userid

Type: belongs_to

Related object: L<Daby::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "userid",
  "Daby::Schema::Result::User",
  { id => "userid" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 tagids

Type: many_to_many

Composing rels: L</article_tags> -> tagid

=cut

__PACKAGE__->many_to_many("tagids", "article_tags", "tagid");


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-07-11 07:57:09
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:S4s9H07pwDSrEPuxdvgoPg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;

no HTML::FormHandler::Moose;
1;
