package Daby::Form::NewUser;
use HTML::FormHandler::Moose;
use HTML::FormHandler::Types ('NoSpaces', 'WordChars', 'NotAllDigits', 'SimpleStr' ); 
extends 'HTML::FormHandler::Model::DBIC';
with 'HTML::FormHandler::Render::Simple';

has '+item_class' => ( default => 'User' );

has_field 'username' => (
  type => 'Text',
  apply => [ NoSpaces, WordChars, NotAllDigits ], 
  required => 1,
  unique => 1,
  class => 'form-control',
  minlength => 5,
  maxlength => 25,
);
has_field 'password' => (
  type => 'Password',
  apply => [ NoSpaces, WordChars, NotAllDigits ], 
  required => 1,
  class => 'form-control',
  minlength => 6,
  maxlength => 25,
);
has_field 'password_confirm' => (
  type => 'PasswordConf',
  tags => { label_after => ': ' }, 
);
has_field 'email' => (
  type  => 'Email',
  required => 1,
  unique => 1,
  class => 'form-control',
  maxlength => 45,
);
has_field 'firstname' => (
  type => 'Text',
  apply => [ NoSpaces, WordChars, NotAllDigits ], 
  minlength => 2,
  maxlength => 25,
  class => 'form-control',
);
has_field 'lastname' => (
  type => 'Text',
  apply => [ NoSpaces, WordChars, NotAllDigits ], 
  minlength => 2,
  maxlength => 25,
  class => 'form-control',
);
has_field 'about_me' => (
  type => 'TextArea',
  cols => 100,
  rows => 10,
  class => 'form-control',
);
has_field 'submit' => (
  type => 'Submit',
  value => 'Submit',
);

##############################################
# For some strnage reasons, 'updated' isn't setting correctly.
# Relying on mysql "on update" functionality, see daby.sql
##############################################
#around 'update_model' => sub {
#  my $orig = shift;
#  my $self = shift;
#  my $item = $self->item;
#
#  $self->schema->txn_do(sub {
#    $orig->($self, @_);
#
#    if (!defined $self->item_id) {
#      $item->update({ created => DateTime->now,
#                      updated => DateTime->now,
#                      user_state => $Daby::BL::Constants::USER_STATE_ACTIVE}); 
#    }
#    else {
#      $item->update({ updated => DateTime->now }); 
#    }
#  });
#};
##############################################


no HTML::FormHandler::Moose;
1;
