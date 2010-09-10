package MyApp::Controller::DvdWithBaseCRUD;
use Moose;

extends 'WebNano::Controller::CRUD';

has '+form_class' => ( default => 'MyApp::Controller::Form' );
sub _build_rs_name { 'Dvd' };

sub index_action {
    my $self = shift;
    return $self->list_action;
}

1;
