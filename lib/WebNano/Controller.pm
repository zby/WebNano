use strict;
use warnings;

package WebNano::Controller;

use URI::Escape 'uri_unescape';
use Plack::Request;

use Object::Tiny::RW  qw/ app env self_url url_map _req /;

sub DEBUG { shift->app->DEBUG }

sub req { 
    my $self = shift;
    return $self->_req if defined $self->_req;
    my $req = Plack::Request->new( $self->env );
    $self->_req( $req );
    return $req;
}

sub template_search_path { [] }

sub render {
    my $self = shift;
    return $self->app->renderer->render( c => $self, @_ );
}

sub local_dispatch {
    my ( $self, @parts ) = @_;
    my $name = uri_unescape( shift @parts );
    $name = 'index' if !defined( $name ) || !length( $name );
    my $action;
    if( my $map = $self->url_map ){
        if( ref $map eq 'HASH' ){
            $action = $self->can( $map->{$name} ) if $map->{$name};
        }
        if( ref $map eq 'ARRAY' ){
            $action = $self->can( $name ) if grep { $_ eq $name } @$map;
        }
    }
    my $method = $name . '_action';
    $action = $self->can( $method ) if !$action;
    my $out;
    if( $action ){
        $out = $action->( $self, @parts );
    }
    warn 'No local action found in "' . ref($self) . qq{" for "$name"\n} if !defined( $out ) && $self->DEBUG;
    return $out;
}

sub handle {
    my ( $class, %args ) = @_;
    my $path = delete $args{path};
    my $self = $class->new( %args );
    return $self->local_dispatch( @$path );
};

1;

__END__

# ABSTRACT: WebNano Controller

=head1 SYNOPSIS
With Moose:

    package MyApp::Controller;
    
    use Moose;
    use MooseX::NonMoose;

    extends 'WebNano::Controller';
    
    has '+url_map' => ( default => sub { { 'Mapped Url' => 'mapped_url' } } );
    
    sub index_action {
        my $self = shift;
        return $self->render( 'index.tt' );
    }
    
    sub mapped_url { 'This is the mapped url page' }
    
    1;


=head1 DESCRIPTION

This is the WebNano base controller. It's handle method dispatches the request
to appropriate action method or to a next controller.

The action method should return a string containing the HTML page, 
a Plack::Response object or a code ref.

=head1 METHODS

=head2 handle

This is a class method - it receives the arguments, creates the controller
object and then uses it's L<local_dispatch> method.

Should return a Plack::Response object, a string containing the HTML page, a code ref
or undef (which is later interpreted as 404).

=head2 render

Renders a template.

=head2 local_dispatch

Finds the method to be called for a given path and dispatches to it.

=head2 req 

Plack::Reqest made from env

=head2 template_search_path

=head2 DEBUG

By default returns the DEBUG flag from the application.  When this returns C<true> then
some additional logging is directed to STDOUT.

=head1 ATTRIBUTES

=head2 url_map

A hash that is used as path part to method map.

=head2 app

Links back to the application object.

=head2 env

L<PSGI environment|http://search.cpan.org/~miyagawa/PSGI/PSGI.pod#The_Environment>

=head2 self_url


