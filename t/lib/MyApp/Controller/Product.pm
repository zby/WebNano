use strict;
use warnings;

package MyApp::Controller::Product;

use base 'ControllerWithTemplates';

sub template_search_path {
    my $self = shift;
    return [ 'Product', @{ $self->SUPER::template_search_path( @_ ) } ];
}

sub some_action { shift->render( 'some_template' ) }
sub another_action { shift->render( 'another_template' ) }
sub third_action { shift->render( 'third_template' ) }

1;

