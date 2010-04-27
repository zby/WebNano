package MyApp::Controller::WebDispatchTable;

use WebNano::Controller::WebDispatchTable::Moose;

extends 'WebNano::Controller::WebDispatchTable';

get '/' => sub { 'This is index in web_dispatch table' };
get '/some_address' => sub { 'This is some_address in web_dispatch table' };

1;

