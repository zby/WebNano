package WebNano::ControllerCA;
use Moose;
extends 'WebNano::Controller';

sub find_action_ {
    my ( $self, $name ) = @_;
    my $meta = $self->meta->find_method_by_name($name);
    return unless $meta && grep { $_ eq 'Action' } @{ $meta->attributes };
    return $name;
}

1;

__END__

=head1 NAME

WebNano - Really minimalistic web framework


=head1 VERSION

This document describes WebNano::Controller version 0.001

=head1 SYNOPSIS

    extend WebNano;
  
=head1 DESCRIPTION

=head1 METHODS

=head2 handle

Returns a Plack::Response object or a string containing the HTML page.

=head2 controller_for

Finds a next controller to forward to according to the first path part.

=head2 render

Renders a template.

=head2 is_action

Checks if a method is callable from the web.

=head1 ATTRIBUTES

=head2 application
=head2 request
=head2 self_url


