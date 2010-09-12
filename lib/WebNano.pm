use strict;
use warnings;

package WebNano;

use base 'WebNano::FindController';

our $VERSION = '0.001';
use Plack::Response;
use Scalar::Util qw(blessed);
use Object::Tiny::RW 'renderer';
use Try::Tiny;
use Encode;

sub psgi_callback {
    my $self = shift;

    sub {
        $self->handle( shift );
    };
}

sub controller_search_path { [ ref(shift) ] };

sub handle {
    my( $self, $env ) = @_;
    my $path = $env->{PATH_INFO};
    my $c_class = $self->find_nested( '', $self->controller_search_path );
    $path =~ s{^/}{};
    die 'Cannot find root controller' if !$c_class;
    my $out = $c_class->handle( 
        path => $path, 
        application => $self, 
        env => $env, 
        self_url => '/', 
    );
    if( not defined $out ){
        my $res = Plack::Response->new(404);
        $res->content_type('text/plain');
        $res->body( 'No such page' );
        return $res->finalize;
    }
    elsif( blessed $out and $out->isa( 'Plack::Response' ) ){
        return $out->finalize;
    }
    elsif( ref $out eq 'CODE' ){
        return $out;
    }
    else{
        my $res = Plack::Response->new(200);
        $res->content_type('text/html');
        $res->body( encode( 'utf8', $out ) );
        return $res->finalize;
    }
}

1;

__END__

# ABSTRACT: A minimalistic PSGI based web framework.

=head1 SYNOPSIS

in MyApp.pm

    package MyApp;
    use base 'WebNano';
    use WebNano::Renderer::TTiny;
    
    sub new { ... }


in MyApp/Controller.pm

    package MyApp::Controller;
    
    use base 'WebNano::Controller';
    
    sub index_action {
        my $self = shift;
        return 'This is my home';
    }

in app.psgi

    use MyApp;
    my $app = MyApp->new();
    $app->psgi_callback;
    

=head1 DESCRIPTION

A minimalistic WebNano application consists of three parts - the application
class, at least one controller class and the standard Plack
L<app.psgi|http://search.cpan.org/~miyagawa/Plack/scripts/plackup> file.

The application object is instantiated only once and is used to hold all the
other constand data objects - like connection to the database, a template
renderer object (if it is too heavy to be created per request) and generally
stuff that is too heavy to be rebuild with each request.  In contrast the
controller objects are recreated for each request a new.

The dispatching implemented by WebNano is simple mapping of HTTP request paths into method
calls as in the following examples:

    '/page' -> 'MyApp::Controller->page_action()'
    '/Some/Very/long/path' -> 'MyApp::Controller::Some::Very->long_action( 'path' )

Additionally if the path ends in '/' then 'index' is added to it - so '/' is
mapped to 'index_action' and '/SomeController/' is mapped to
MyApp::SomeController->index_action.

If someone does not like the '_action' postfixes then he can use the
'url_map' controller attribute which works like the 'run_modes' attribute in
CGI::Application - that is provides a map for method dispatching:

    $self->url_map( { 'mapped url' => 'mapped_url' } );

or a list of approved methods to be dispached by name:

    $self->url_map( [ 'safe_method' ] );

More advanced dispatching is done by overriding the 'local_dispatch' method in
the Controller class:

    around 'local_dispatch' => sub {
        my( $orig, $self, $path) = @_;
        my( $id, $method, @args ) = split qr{/}, $path;
        $method ||= 'view';
        if( $id && $id =~ /^\d+$/ ){
            my $rs = $self->application->schema->resultset( 'Dvd' );
            my $record = $rs->find( $id );
            if( ! $record ) {
                my $res = $self->request->new_response(404);
                $res->content_type('text/plain');
                $res->body( 'No record with id: ' . $id );
                return $res;
            }
            return $self->$method( $record, @args );
        }
        return $self->$orig( $path );
    };
    
This one checks if the first part of the path is a number - if it is it uses
it to look for a Dvd object by primary key.  If it cannot find such a Dvd then
it returns a 404. If it finds that dvd it then redispatches by the next path
part and passes that dvd object as the first parameter to that method call.

The design goal numer one here is to provide basic functionality that should cover most 
of use cases and a easy way to override it and extend. In general it is easy
to write your own dispatcher that work for your limited use case - and here
you just need to do that, you can override the dispatching only for a
particular controller and you don't need to warry about the general cases.

The example in extensions/WebNano-Controller-DSL/ shows how to create a DSL
for dispatching (ala Dancer):

    get '/some_address' => sub { 'This is some_address in web_dispatch table' };

=head2 Controller object live in the request scope (new controller per request)

If you need to build a heavy
structure used in the controller you can always build it as the
application attribute and use it in the controller as it has access to
the application object, but since all the work of controllers is done
in the request scope (i.e. creating the request) - then it makes sense
that the whole object lives in that scope.  This is the same as
Tatsumaki handlers (and controllers in Rails, Django and probably
other frameworks) - but different from Catalyst.

=head2 Streamming

WebNano does not have any features helping with streaming content, but it also
does not create any obstacles in using the original PSGI streamming interface.
See for example the streaming_action method in t/lib/MyApp/Controller.pm.

=head1 ATTRIBUTES and METHODS

=head2 psgi_callback

This is a method which returns a subroutine reference suitable for PSGI.
The returned subrourine ref is a closure over the application object.

=head2 controller_search_path 

Experimental.

=head2 handle

Application method that acts as the PSGI callback - takes environment
as input and returns the response.

=head2 renderer

Nearly every web application uses some templating engine - this is the
attribute to keep the templating engine object.  It is not mandatory that you
follow this rule.

=head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back

=head1 DEPENDENCIES

See Makefile.PL

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-webnano@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.



