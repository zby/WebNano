use strict;
use warnings;

package WebNano::Controller::DSL;

use WebNano::Controller::Meta::Class::Trait::WebDispatchTable;
use Moose -traits => 'WebDispatchTable';
use MooseX::NonMoose;
extends 'WebNano::Controller';

sub handle {
    my ( $class, %args ) = @_;
    my $path = '/' . $args{path};
    my $action = $class->meta->web_dispatch()->{ $path };
    if( $action ){
        return $action->( %args );
    }
    else{
        my $req = $args{req};
        my $res = $req->new_response(404);
        $res->content_type('text/plain');
        $res->body( 'No such page' );
        return $res;
    }
};

1;

__END__

=head1 NAME

WebNano::Controller::DSL - A base controller implementing DSL based dispatching 

=head1 SYNOPSIS

  
   use Moose;
   extends 'WebNano::Controller::DSL';
   
   get '/' => sub { ... };

   get '/some_address' => sub { ... };
   


