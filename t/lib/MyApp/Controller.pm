use strict;
use warnings;

package MyApp::Controller;

use base 'WebNano::Controller';


sub new {
    my $class = shift;
    my $self  = $class->SUPER::new( @_, 
        url_map => { 'mapped url' => 'mapped_url' } 
    );
    return $self;
}

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
        $writer->write( $self->request->param( 'who' ) );
        $writer->close();
    }
}

1;

