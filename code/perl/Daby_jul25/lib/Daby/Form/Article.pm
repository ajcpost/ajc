package Daby::Form::Article;

use strict;
use warnings;
use HTML::FormHandler::Moose;
use Daby::BL::ContentStore;

extends 'HTML::FormHandler::Model::DBIC';
with 'HTML::FormHandler::Render::Simple';

has_field 'title'           => ( type => 'Text', required => 1, size => 80, minlength => 10, maxlength => 80 );
has_field 'tagids'          => ( type => 'Multiple', required => 1, label_column => 'tag', label => 'Tags', size=> 5 );
#has_field 'tagids'         => ( type => 'Multiple', required => 1, widget => 'RadioGroup', label_column => 'tag', label => 'Tags', size => 3);
has_field 'htmlcontent'     => ( type => 'TextArea', required => 1, label => 'Content', class => 'wysiwyg' );
has_field 'is_approved'     => ( type => 'Hidden' );
has_field 'submit'          => ( type => 'Submit', label => 'Save' );

after 'setup_form' => sub {   
    my $self = shift;
    my $item = $self->item;
         
    $self->field('htmlcontent')->value(Daby::BL::ContentStore::readContentFromFile($item->content_location));
};

around 'update_model' => sub { 
    my $orig = shift;
    my $self = shift;
    my $item = $self->item; 
    
    $self->schema->txn_do(sub { 
        $orig->($self, @_);
        my $location = Daby::BL::ContentStore::storeContentAsFile($self->value->{htmlcontent}, $item->content_location);
        my $summary = Daby::BL::ContentStore::generateSummary($self->value->{htmlcontent});
        
        $item->update({ content_summary => $summary, content_location => $location });
    });
};

no HTML::FormHandler::Moose;
1;
