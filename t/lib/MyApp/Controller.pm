package MyApp::Controller;

use Moose;
extends 'WebNano::Controller';

has '+url_map' => ( default => sub { { 'mapped url' => 'mapped_url' } } );

sub index_action {
    my $self = shift;
    return $self->render( 'index.tt' );
}

sub mapped_url { 'This is the mapped url page' }

1;

