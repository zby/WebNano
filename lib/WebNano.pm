package WebNano;

our $VERSION = '0.001';
use Any::Moose;
use Plack::Request;
use Scalar::Util qw(blessed);
use Class::MOP;

has renderer => ( is => 'ro' );

sub handler {
    my $self = shift;

    sub {
        my $req = Plack::Request->new(shift);
        my $c_class = ref($self) . '::Controller';
        Class::MOP::load_class( $c_class );
        my $controller = $c_class->new( application => $self, request => $req, self_url => '/' );
        my @args = split /\//, $req->path;
        shift @args;
        my $out = $controller->handle( @args );
        my $res;
        if( blessed $out and $out->isa( 'Plack::Response' ) ){
            $res = $out;
        }
        else{
            $res = $req->new_response(200);
            $res->content_type('text/html');
            $res->body( $out );
        }
        return $res->finalize;
    };
}

1;

__END__

=head1 NAME

WebNano - Really minimalistic web framework


=head1 VERSION

This document describes WebNano version 0.001


=head1 SYNOPSIS

    extend WebNano;

See the example in t/lib/MyApp

=head1 DESCRIPTION

This is a minimalistic web framework - the main design goal of it is to delegate as much
as possible to specialized CPAN modules with minimal hassle. 

It currently uses: PSGI/Plack tools to ease deployment and testing and Bread::Board
to build the application components.  What is left is just dispatching (routing) - this
is built around the following design ideas:

=head2 Controllers (like Catalyst) with methods per sub-address 


=head2 Dispatching (routing) in controllers

This makes controllers more independent from the whole application and 
mixable with more flexibility.
This also leads to the elegant design of recursive dispatching -
you start from the root controller it then serves the request or
chooses another controller where the same thing happens
(sometimes called tree of resposibility - extension of the chain of responsibility 
design pattern).

=head2 Controller object live in the request scope (new controller per request)

If you need to build a heavy
structure used in the controller you can always build it as the
application attribute and use it in the controller as it has access to
the application object, but since all the work of controllers is done
in the request scope (i.e. creating the request) - then it makes sense
that the whole object lives in that scope.  This is the same as
Tatsumaki handlers (and controllers in Rails, Django and probably
other frameworks) - but different from Catalyst.


=head1 ATTRIBUTES and METHODS

=head2 handler

Returns a subroutine (with closure) suitable for handling PSGI request arrays.

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
