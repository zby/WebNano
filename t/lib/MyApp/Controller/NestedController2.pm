use strict;
use warnings;

package MyApp::Controller::NestedController2;

use base 'WebNano::Controller';

sub some_method_action { 'This is a method with _action postfix in MyApp::Controller::NestedController2' }

sub with_template_action { shift->render( template => 'some_template' ) }

1;

