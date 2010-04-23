package WebNano::Controller::CodeAttributesForMeta;
use Moose::Role;

sub find_action_ {
    my ( $self, $name ) = @_;
    my $meta = $self->meta->find_method_by_name($name);
    return unless $meta && grep { $_ eq 'Action' } @{ $meta->attributes };
    return $self->can( $name );
}

1;

__END__

=head1 NAME

WebNano::Controller::CodeAttributesForMeta - a role for marking Action methods by code attributes


=head1 VERSION

This document describes WebNano::Controller version 0.001

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 find_action_ 

Finds action by checking the meta class.


