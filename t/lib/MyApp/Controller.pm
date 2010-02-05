package MyApp::Controller;

BEGIN{
    use Moose;
    extends 'WebNano::Controller';
}

sub index : Action {
    my $self = shift;
    return $self->render( 'index.tt' );
}

1;

