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

=head1 NAME

WebNano - A minimalistic PSGI based web framework

=head1 VERSION

This document describes WebNano version 0.001

=head1 SYNOPSIS

See the example in t/lib/MyApp

=head1 DESCRIPTION

The design goal numer one here is to provide basic functionality that should cover most 
of use cases and a easy way to override it and extend.
The design goal number two is to delegate as much as possible to specialized
CPAN modules with minimal hassle.  

The main functionality is simple mapping (dispatching) of HTTP request paths into method
calls as in the following example:

    '/' -> 'MyApp::Controller->index_action()'
    '/page' -> 'MyApp::Controller->page_action()'
    '/Some/Very/long/path' -> 'MyApp::Controller::Some::Very->long_action( 'path' )

The name of the action subroutine needs to end with '_action' postfix or alternatively 
the mapping of the last part of the path to the subroutine name can be provided with
'url_map' which can be an array of sub names or a hash of mappings (like run_modes 
in CGI::Application).

The examples in 'extensions' show how one can extend this basic dispatching with
other dispatching 'flavours': 

WebDispatchTable shows how to create a DSL for dispatching (ala Dancer):

    get '/some_address' => sub { 'This is some_address in web_dispatch table' };

CodeAttributesForMeta shows how to add an 'Action' code attribute (ala Catalyst):

    sub index : Action { 'This is the index page' }

CRUD shows how to create an encapsulated CRUD controller code

This mapping is done inside Controller code - so it can be easily overridden
and extended on per directory basis.  This should allow one to create
self-contained controllers that fully encapsulate some specialized functionality.

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


=head1 AUTHOR

Zbigniew Lukasiak  C<< <zby@cpan.org> >>



