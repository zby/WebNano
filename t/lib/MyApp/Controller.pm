package MyApp::Controller;

BEGIN{
    use Moose;
    extends 'WebNano::ControllerCA';
}

sub index : Action {
    my $self = shift;
    return $self->render( 'index.tt' );
}

1;

