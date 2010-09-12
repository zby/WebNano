use strict;
use warnings;

package WebNano::Controller;
use base 'WebNano::FindController';

use Try::Tiny;
use URI::Escape 'uri_unescape';
use Plack::Request;
use File::Spec::Functions qw/catfile catdir/;

use Object::Tiny::RW  qw/ application env self_url url_map _request /;

sub request { 
    my $self = shift;
    return $self->_request if defined $self->_request;
    my $req = Plack::Request->new( $self->env );
    $self->_request( $req );
    return $req;
}

sub template_search_path { [] }

sub render {
    my $self = shift;
    return $self->application->renderer->render( c => $self, @_ );
}

sub _self_path{
    my $self = shift;
    my $path = ref $self;
    $path =~ s/.*::Controller(?=(::|$))//;
    $path =~ s{::}{/};
    return $path . '/';
}

sub _external_dispatch {
    my ( $self, $path ) = @_;
    my( $path_part, $new_path ) = ( $path =~ qr{^([^/]*)/?(.*)} );
    $path_part =~ s/::|'//g if defined( $path_part );
    return if !length( $path_part );
    my $controller_class = $self->find_nested( $self->_self_path . $path_part, $self->application->controller_search_path );
    return if !$controller_class;
    return $controller_class->handle(
        path => $new_path,  
        self_url  => $self->self_url . $path_part . '/',
        env => $self->env,
        application => $self->application,
    );
}

sub local_dispatch {
    my ( $self, $path, @args ) = @_;
    my @parts = split /\//, $path;
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
    return if !$action;
    return $action->( $self, @args, @parts );
}

sub handle {
    my ( $class, %args ) = @_;
    my $path = delete $args{path};
    my $self = $class->new( %args );
    my $out = $self->local_dispatch( $path );
    return $out if defined $out;
    return $self->_external_dispatch( $path );
};

1;

__END__

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

If there is no suitable method in the current class, child controller classes
are tried out.  If there is found one that matches the path part then it is
instantiated with the current psgi env and it's handle method is called.

=head1 METHODS

=head2 handle

This is a class method - it receives the arguments, creates the controller
object and then uses it's L<local_dispatch> method, if that fails it tries to
find a suitable child controller class and forwards the request to it.

Should return a Plack::Response object, a string containing the HTML page, a code ref
or undef (which is later interpreted as 404).

=head2 render

Renders a template.

=head2 local_dispatch

Finds the method to be called for a given path and dispatches to it.

=head2 request

=head2 template_search_path

=head1 ATTRIBUTES

=head2 url_map

A hash that is used as path part to method map.

=head2 application

Links back to the application object.

=head2 env

L<PSGI environment|http://search.cpan.org/~miyagawa/PSGI/PSGI.pod#The_Environment>

=head2 self_url


