package MyApp::Controller::DvdWithBaseCRUD;
use Moose;

extends 'WebNano::Controller::CRUD';

has '+form_class' => ( default => 'MyApp::Controller::Form' );
has '+rs_name' => ( default => 'Dvd' );

sub index_action {
    my $self = shift;
    return $self->list;
}

1;
