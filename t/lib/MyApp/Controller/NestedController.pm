use strict;
use warnings;

package MyApp::Controller::NestedController;
use base 'WebNano::Controller';

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new( @_, url_map => [ 'safe_method' ]  );
    return $self;
}

sub safe_method { 'This is the safe_method page' }

sub some_method_action { 'This is a method with _action postfix' }

sub with_template_action { shift->render( 'some_template' ) }

1;

