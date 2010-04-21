package MyApp::Controller::DvdWithBaseCRUD;
use Moose;
use MooseX::MethodAttributes;

extends 'WebNano::Controller::CRUD';

has '+form_class' => ( default => 'MyApp::Controller::Dvd::Form' );
has '+rs_name' => ( default => 'Dvd' );

1;
