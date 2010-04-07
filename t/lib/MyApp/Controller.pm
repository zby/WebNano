package MyApp::Controller;

use Moose;
extends 'WebNano::Controller';

sub index_action {
    my $self = shift;
    return $self->render( 'index.tt' );
}

1;

