use strict;
use warnings;

package WebNano::Controller;

use URI::Escape 'uri_unescape';
use Plack::Request;

use WebNano::FindController 'find_nested';
use Object::Tiny::RW  qw/ app env self_url url_map _req path /;

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
    my ( $self ) = @_;
    my @parts = @{ $self->path };
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
    $action = $self->can( $name . '_action' ) if !$action;
    if( ! $action ){
        my $method = uc( $self->env->{REQUEST_METHOD} );
        $action = $self->can( $name . '_' . $method ) if $method eq 'GET' || $method eq 'POST';
    }
    my $out;
    if( $action ){
        $out = $action->( $self, @parts );
    }
    warn 'No local action found in "' . ref($self) . qq{" for "$name"\n} if !defined( $out ) && $self->DEBUG;
    return $out;
}


sub _self_path{
    my $class = shift;
    my $path = $class;
    $path =~ s/.*::Controller(?=(::|$))//;
    $path =~ s{::}{/};
    return $path . '/';
}

sub dispatch_to_class {
    my ( $self, $to ) = @_;
    $to =~ s/::|'//g if defined( $to );
    return if !length( $to );
    my $class = ref $self;
    my $controller_class = find_nested( $class->_self_path . $to, $self->app->controller_search_path );
    if( !$controller_class ){
        warn qq{No subcontroller found in "$class" for "} . $class->_self_path . $to. qq{"\n} if $self->DEBUG;
        return;
    }
    warn qq{Dispatching to "$controller_class"\n} if $self->DEBUG;
    return $controller_class->handle(
        path => $self->path,
        app => $self->app,
        self_url  => $self->{self_url} . $to. '/',
        env => $self->env,
    );
}

sub handle {
    my ( $class, %args ) = @_;
    my $self = $class->new( %args );
    my $out = $self->local_dispatch();
    return $out if defined( $out ) || !$self->search_subcontrollers;
    my $path_part = shift @{ $self->path };
    return $self->dispatch_to_class( $path_part );
}

sub search_subcontrollers { 0 }

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

If there is no suitable method in the current class and the method search_subcontrollers
returns a true value then child controller classes
are tried out.  If there is found one that matches the path part then it is
instantiated with the current psgi env and it's handle method is called.

In a path C</SomeDeepController/OtherController/LeaveController/method> all
C<MyApp::Controoler>, C<MyApp::Controller::SomeDeepController> 
and C<MyApp::Controller::SomeDeepController::OtherController> need to 
override search_subcontrollers method to return 1.

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

=head2 search_subcontrollers

If search_subcontrollers returns true and there are no local actions
then subcontrollers are searched.

=head2 dispatch_to_class

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

=head2 path

