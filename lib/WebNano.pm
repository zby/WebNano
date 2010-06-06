use strict;
use warnings;

package WebNano;

our $VERSION = '0.001';
use Plack::Response;
use Scalar::Util qw(blessed);
use Class::XSAccessor { accessors => [ 'renderer' ], constructor => 'new' };
use Try::Tiny;

sub psgi_callback {
    my $self = shift;

    sub {
        $self->handle( shift );
    };
}

sub controller_search_path { [ ref(shift) ] };

sub find_controller {
    my ( $self, $path_part ) = @_;
    my $controller_class;
    my @path = @{ $self->controller_search_path };
    for my $base ( @path ){
        $controller_class = $base . '::' . $path_part;
        try{
            my $controller_file = $controller_class;
            $controller_file =~ s{::}{/}g;
            $controller_file .= '.pm';
            require $controller_file;
        }
        catch {
            if( $_ && $_ !~ /Can't locate .*$path_part.pm in \@INC/ ){
                die $_;
            }
        };
    }
    return $controller_class;
}

sub handle {
    my( $self, $env ) = @_;
    my $path = $env->{PATH_INFO};
    my $c_class = $self->find_controller( 'Controller' );
    $path =~ s{^/}{};
    my $out = $c_class->handle( 
        path => $path, 
        application => $self, 
        env => $env, 
        self_url => '/', 
        self_path => '/', 
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
        $res->body( $out );
        return $res->finalize;
    }
}

1;

__END__

=head1 NAME

WebNano - Really minimalistic PSGI based web framework


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


=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language used.
  
WebNano requires no configuration files or environment variables.


=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

None.


=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.


=head1 BUGS AND LIMITATIONS

=for author to fill in:
    A list of known problems with the module, together with some
    indication Whether they are likely to be fixed in an upcoming
    release. Also a list of restrictions on the features the module
    does provide: data types that cannot be handled, performance issues
    and the circumstances in which they may arise, practical
    limitations on the size of data sets, special cases that are not
    (yet) handled, etc.

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-webnano@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Zbigniew Lukasiak  C<< <zby@cpan.org> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009, Zbigniew Lukasiak C<< <zby@cpan.org> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
