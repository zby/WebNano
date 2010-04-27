package MyApp::Controller::WebDispatchTable;

use Moose -traits => 'WebDispatchTable';
extends 'WebNano::Controller';

use WebNano::Controller::WebDispatchTable;

get '/' => sub { 'This is index in web_dispatch table' };
get '/some_address' => sub { 'This is some_address in web_dispatch table' };

sub handle {
    my ( $class, %args ) = @_;
    my $path = '/' . $args{path};
    my $action = $class->meta->web_dispatch()->{ $path };
    if( $action ){
        return $action->( %args );
    }
    else{
        my $req = $args{request};
        my $res = $req->new_response(404);
        $res->content_type('text/plain');
        $res->body( 'No such page' );
        return $res;
    }
};

1;

