package Daby::Form::Comment;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';

has '+item_class' => ( default => 'Comment' );

has_field 'content' => (
  type => 'TextArea',
  cols => 200,
  rows => 10,
  required => 1,
  do_label => 0,
  tags => { wrapper_tag => 'p' },
);

has_field 'submit' => (
  type => 'Submit',
  value => 'Save',
  label => 'Save',
);

no HTML::FormHandler::Moose;
1;
