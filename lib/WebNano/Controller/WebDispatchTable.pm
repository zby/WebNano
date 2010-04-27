package WebNano::Controller::WebDispatchTable;

use Moose -traits => 'WebDispatchTable';
extends 'WebNano::Controller';

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

