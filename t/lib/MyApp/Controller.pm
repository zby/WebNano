package MyApp::Controller;
use Moose;
extends 'WebNano::Controller';

sub serve_index {
    my $self = shift;
    return $self->render( 'index.tt' );
}

1;

