use strict;
use warnings;

package WebNano;

use WebNano::FindController 'find_nested';

use Plack::Response;
use Scalar::Util qw(blessed);
use Object::Tiny::RW 'renderer';
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
    my $c_class = find_nested( '', $self->controller_search_path );
    $path =~ s{^/}{};
    die 'Cannot find root controller' if !$c_class;
    my $out = $c_class->handle( 
        path => $path, 
        app => $self, 
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

A minimal WebNano application can be an
app.psgi file like this:

    {
        package MyApp;
        use base 'WebNano';
    }
    
    {
        package MyApp::Controller;
        use base 'WebNano::Controller';
        
        sub index_action {
            my $self = shift;
            return 'This is my home';
        }
    }
    
    my $app = MyApp->new();
    $app->psgi_callback;


You can then run it with C<plackup> (see L<http://search.cpan.org/dist/Plack/scripts/plackup>).
A more practical approach is to split this into three different files.

=head1 DESCRIPTION

Every WebNano application has at least three parts - the application
class, at least one controller class and the
L<app.psgi|http://search.cpan.org/~miyagawa/Plack/scripts/plackup> file (or
something else that uses L<http://search.cpan.org/dist/Plack/lib/Plack/Runner.pm>
run the app).

The application object is instantiated only once and is used to hold all the
other constand data objects - like connection to the database, a template
renderer object (if it is too heavy to be created per request) and generally
stuff that is too heavy to be rebuild with each request.  In contrast the
controller objects are recreated for each request a new.

The dispatching implemented by WebNano is simple mapping of HTTP request paths into method
calls as in the following examples:

    '/page' -> 'MyApp::Controller->page_action()'
    '/Some/Very/long/path' -> 'MyApp::Controller::Some::Very->long_action( 'path' )

The first type of dispatching is done by the plain L<WebNano::Controller> - to get actions
dispatched to controllers in subdirs you need to subclass L<WebNano::DirController>
(which is also a subclass of C<WebNano::Controller>).
So your root controllers should usually start with C<use base 'WebNano::DirController'>.
Other controllers also can subclass C<WebNano::DirController> - but if they do 
their own dispatching to sub-controllers then they need to subclass plain C<WebNano::Controller>,
otherwise this automatic dispatching, sidestepping the custom-made code could become
a security risk.

Additionally if the last part of the path is empty then C<index> is added to it - so C</> is
mapped to C<index_action> and C</SomeController/> is mapped to
C<MyApp::SomeController-E<gt>index_action>.

If someone does not like the C<_action> postfixes then he can use the
C<url_map> controller attribute which works like the C<run_modes> attribute in
C<CGI::Application> - that is provides a map for method dispatching:

    $self->url_map( { 'mapped url' => 'mapped_url' } );

or a list of approved methods to be dispached by name:

    $self->url_map( [ 'safe_method' ] );

More advanced dispatching is done by overriding the C<local_dispatch> method in
the Controller class:

    around 'local_dispatch' => sub {
        my( $orig, $self, $path) = @_;
        my( $id, $method, @args ) = split qr{/}, $path;
        $method ||= 'view';
        if( $id && $id =~ /^\d+$/ && $self->is_record_method( $method ) ){
            my $rs = $self->app->schema->resultset( 'Dvd' );
            my $record = $rs->find( $id );
            if( ! $record ) {
                my $res = $self->req->new_response(404);
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
Note the need to check if the called method is an allowed one.
If the first part of the url is not a number - then the request is dispatched in
the normal way.

The design goal numer one here is to provide basic functionality that should cover most 
of use cases and a easy way to override it and extend. In general it is easy
to write your own dispatcher that work for your limited use case - and here
you just need to do that, you can override the dispatching only for a
particular controller and you don't need to warry about the general cases.

The example in F<extensions/WebNano-Controller-DSL/> shows how to create a DSL
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

=head2 Things that you can do with WebNano even though it does not actively support them

There is a tendency in other frameworks to add interfaces to any other CPAN
library. With WebNano I want to keep it small, both in code and in it's
interface, and avoid adding new WebNano interfaces to things that can be used
directly, but instead I try to make that direct usage as simple as possible.

In particular a WebNano script is a PSGI application and you can use all the Plack
tools with it.  
For example to use sessions you can add following line to your app.psgi file:

    enable 'session'

Read
L<http://search.cpan.org/dist/Plack-Middleware-Session/lib/Plack/Middleware/Session.pm>
about the additional options that you can enable here.  See also
L<http://search.cpan.org/dist/Plack/lib/Plack/Builder.pm>
to read about the sweetened syntax you can use in your app.psgi file
and  L<http://search.cpan.org/search?query=Plack+Middleware&mode=all>
to find out what other Plack::Middleware packages are available.

The same goes for MVC. WebNano does not have any methods or attributes for
models, not because I don't structure my web application using the 'web MVC'
pattern - but rather because I don't see any universal attribute or method of
the possible models.  Users are free to add their own methods.  For example most
of my code uses L<http://search.cpan.org/dist/DBIx-Class/lib/DBIx/Class.pm> 
- and I add these lines to my application:

    has schema => ( is => 'ro', isa => 'DBIx::Class::Schema', lazy_build => 1 );
    
    sub _build_schema {
       my $self = shift;
       my $config = $self->config->{schema};
       return DvdDatabase::DBSchema->connect( $config->{dbi_dsn},
    $config->{user}, $config->{pass}, $config->{dbi_params} );
    }

then I use it with C<$self-E<gt>app-E<gt>schema> in the controller objects.

As to Views - I've added some support for two templating engines for WebNano,
but this is only because I wanted to experiment with 'template inheritance'.  If
you don't want to use 'template inheritance' you can use Template::Tookit
directly in your controller actions or you can use directly any templating
engine in your controller actions - like 
C<$self-E<gt>app-E<gt>my_templating-E<gt>process('template_name' )> 
or even C<$self-E<gt>my_templating-E<gt>process( ... )> as long as it
returns a string.

=head3 Streamming

You can use the original L<http://search.cpan.org/dist/PSGI/PSGI.pod#Delayed_Reponse_and_Streaming_Body>
The streaming_action method in F<t/lib/MyApp/Controller.pm> can be used as an example.

=head3 Authentication

Example code in the application class:

    around handle => sub {
        my $orig = shift;
        my $self = shift;
        my $env  = shift;
        if( $env->{'psgix.session'}{user_id} ){
            $env->{user} = $self->schema->resultset( 'User' )->find( $env->{'psgix.session'}{user_id} );
        }
        else{
            my $req = Plack::Request->new( $env );
            if( $req->param( 'username' ) && $req->param( 'password' ) ){
                my $user = $self->schema->resultset( 'User' )->search( { username => $req->param( 'username' ) } )->first;
                if( $user->check_password( $req->param( 'password' ) ) ){
                    $env->{user} = $user;
                    $env->{'psgix.session'}{user_id} = $user->id;
                }
            }
        }
        $self->$orig( $env, @_ );
    };


=head3 Authorization

Example:

    around 'local_dispatch' => sub {
        my $orig = shift;
        my $self = shift;
        if( !$self->env->{user} ){
            return $self->render( template => 'login_required.tt' );
        }
        $self->$orig( @_ );
    };

C<local_dispatch> is called before the controll is passed to child controllers,
so if you put that into the C<MyApp::Controller::Admin> controller - then both
all local actions and actions in child controllers (for example
C<MyApp::Controller::Admin::User>) would be guarded agains unauthorized usage.


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

=over

=back

=head1 SEE ALSO

L<WebNano::Renderer::TT> - Template Toolkit renderer with template inheritance

L<WebNano::Controller::CRUD> (experimental), 

L<http://github.com/zby/Nblog> - example blog engine using WebNano

=head1 DEPENDENCIES

See Makefile.PL

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-webnano@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.



