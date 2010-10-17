package MyApp::Controller;

use Moose;
use MooseX::NonMoose;
extends 'WebNano::DirController';

has 'url_map' => ( is => 'ro', default => sub { { 'mapped url' => 'mapped_url' } } );

sub index_action {
    my $self = shift;
    return $self->render( 'index.tt' );
}

sub mapped_url { 'This is the mapped url page' }

sub streaming_action {
    my $self = shift;
    return sub {
        my $respond = shift;

        my $writer = $respond->([
            200,
            [ 'Content-Type' => 'text/plain', ],
        ]);
        $writer->write( "Hello, " );
        $writer->write( $self->req->param( 'who' ) );
        $writer->close();
    }
}

1;

