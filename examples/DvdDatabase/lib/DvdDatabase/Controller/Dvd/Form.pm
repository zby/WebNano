package DvdDatabase::Controller::Dvd::Form;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
with 'HTML::FormHandler::Render::Simple';

use DateTime;


has '+item_class' => ( default => 'Dvd' );

has_field 'tags' => ( type => 'Select', multiple => 1 );
has_field 'hour' => ( type => 'Text', );
has_field 'alter_date' => ( 
        type => 'Compound',
        apply => [
            {
                transform => sub{ DateTime->new( $_[0] ) },
                message => "Not a valid DateTime",
            }
        ],
    );
has_field 'alter_date.year';        has_field 'alter_date.month';        has_field 'alter_date.day';
has_field 'creation_date' => ( 
        type => 'Compound',
        apply => [
            {
                transform => sub{ DateTime->new( $_[0] ) },
                message => "Not a valid DateTime",
            }
        ],
    );
has_field 'creation_date.year';        has_field 'creation_date.month';        has_field 'creation_date.day';
has_field 'imdb_id' => ( type => 'Text', );
has_field 'name' => ( type => 'TextArea', );
has_field 'owner' => ( type => 'Select', );
has_field 'current_borrower' => ( type => 'Select', );
has_field 'submit' => ( widget => 'submit' );

1;
