package MyApp::Controller::SubController;
use Moose;
use MooseX::NonMoose;

extends 'WebNano::Controller';

has 'url_map' => ( is => 'ro', default => sub { [ 'safe_method' ] } );

sub safe_method { 'This is the safe_method page' }

sub some_method_action { 'This is a method with _action postfix' }

1;

