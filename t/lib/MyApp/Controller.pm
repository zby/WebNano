package MyApp::Controller;

use Moose;
use MooseX::NonMoose;
extends 'WebNano::Controller';

has 'url_map' => ( is => 'ro', default => sub { { 'mapped url' => 'mapped_url' } } );

sub index_action {
    my $self = shift;
    return $self->render( 'index.tt' );
}

sub mapped_url { 'This is the mapped url page' }

1;

