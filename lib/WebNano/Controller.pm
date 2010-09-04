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

sub self_path{
    my $self = shift;
    my $path = ref $self;
    $path =~ s/.*::Controller(?=(::|$))//;
    $path =~ s{::}{/};
    return $path . '/';
}

sub external_dispatch {
    my ( $self, $path ) = @_;
    my( $path_part, $new_path ) = ( $path =~ qr{^([^/]*)/?(.*)} );
    $path_part =~ s/::|'//g if defined( $path_part );
    return if !length( $path_part );
    my $controller_class = $self->find_nested( $self->self_path . $path_part, $self->application->controller_search_path );
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
    return $self->external_dispatch( $path );
};

1;

__END__

=head1 NAME

WebNano::Controller 

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
to appropriate action method.

The action method should return a string containing the HTML page, 
a Plack::Response object or a code ref.

If there is no suitable method in the current class, child controller classes 
are tried out (their name is mapped literally).  If there is found one that 
matches the path part then it is instantiated with the current psgi env
and it's handle method is called.

=head1 METHODS

=head2 handle

Dispatches the request to the action methods as described above.

Should return a Plack::Response object, a string containing the HTML page, a code ref
or undef (which is later interpreted as 404).

=head2 controller_for

Finds a next controller to forward to according to the path.

=head2 render

Renders a template.

=head2 local_dispatch

Finds the method to be called for a path and dispatches to it.

=head1 ATTRIBUTES

=head2 url_map
=head2 application
=head2 env
=head2 self_url


