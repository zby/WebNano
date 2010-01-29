package MyApp::Controller;
use Moose;
use MooseX::MethodAttributes;
extends 'WebNano::Controller';

sub index : Action {
    my $self = shift;
    return $self->render( 'index.tt' );
}

1;

