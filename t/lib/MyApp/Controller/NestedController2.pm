package MyApp::Controller::NestedController2;
use Moose;
use MooseX::NonMoose;

extends 'WebNano::Controller';

sub some_method_action { 'This is a method with _action postfix in MyApp::Controller::NestedController2' }

sub with_template_action { shift->render( 'some_template' ) }

1;

