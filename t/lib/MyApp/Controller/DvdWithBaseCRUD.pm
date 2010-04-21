package MyApp::Controller::DvdWithBaseCRUD;
use Moose;
use MooseX::MethodAttributes;

extends 'WebNano::Controller::CRUD';

has record_controller_class => ( is => 'ro', isa => 'Str', default => 'MyApp::Controller::DvdWithBaseCRUD::Record' );
has form_class => ( is => 'ro', isa => 'Str', default => 'CRUDDvdForm' );
has rs_name => ( is => 'ro', isa => 'Str', default => 'Dvd' );

package MyApp::Controller::DvdWithBaseCRUD::Record;
use Moose;
use MooseX::MethodAttributes;

extends 'WebNano::Controller::CRUD::Record';

has form_class => ( is => 'ro', isa => 'Str', default => 'CRUDDvdForm' );
has rs_name => ( is => 'ro', isa => 'Str', default => 'Dvd' );


{
    package CRUDDvdForm;
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
    has_field 'submit' => ( widget => 'submit' )
}

1;
