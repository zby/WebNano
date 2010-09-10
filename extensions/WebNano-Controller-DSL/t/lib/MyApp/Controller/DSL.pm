use strict;
use warnings;

package MyApp::Controller::DSL;

use WebNano::Controller::DSL::Moose;

extends 'WebNano::Controller::DSL';

get '/' => sub { 'This is index in web_dispatch table' };
get '/some_address' => sub { 'This is some_address in web_dispatch table' };

1;

