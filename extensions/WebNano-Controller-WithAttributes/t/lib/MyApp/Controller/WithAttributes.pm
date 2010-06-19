package MyApp::Controller::WithAttributes;

use Moose;
use MooseX::MethodAttributes;
extends 'WebNano::Controller::WithAttributes';

sub index : Action { 'This is index' };
sub some_address : Action { 'This is some_address' };

1;

