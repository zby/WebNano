use strict;
use warnings;

package MyApp::Controller;

use base 'WebNano::Controller';


sub index_action {
    my $self = shift;
    return 'Hello World';
}

sub templated_action {
    my $self = shift;
    return $self->render( 'templated' );
}


1;

