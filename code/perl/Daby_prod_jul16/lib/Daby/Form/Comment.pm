package Daby::Form::Comment;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';

has '+item_class' => ( default => 'Comment' );

#has_field 'content' => (
#  type => 'TextArea',
#  cols => 200,
#  rows => 10,
#  required => 1,
#  do_label => 0,
#  tags => { wrapper_tag => 'p' },
#);

has_field 'htmlcommentcontent' => ( type => 'TextArea', required => 1, label => 'Content', class => 'wysiwyg' );

has_field 'submit' => (
  type => 'Submit',
  value => 'Save',
  label => 'Save',
);

around 'update_model' => sub {
    my $orig = shift;
    my $self = shift;
    my $item = $self->item;

    $self->schema->txn_do(sub {
        $orig->($self, @_);
        my $location = Daby::BL::ContentStore::storeContentAsFile($self->value->{htmlcommentcontent}, $item->content_location);
        my $content  = "";
        $item->update({ content_location => $location, content => $content });
    });
};


no HTML::FormHandler::Moose;
1;
