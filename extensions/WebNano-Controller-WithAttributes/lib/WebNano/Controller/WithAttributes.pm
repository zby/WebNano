package WebNano::Controller::WithAttributes;
use URI::Escape 'uri_unescape';
use Moose;
use MooseX::NonMoose;
extends 'WebNano::Controller';


sub local_dispatch {
    my ( $self, $path ) = @_;
    my @parts = split /\//, $path;
    my $name = uri_unescape( shift @parts );
    $name = 'index' if !defined( $name ) || !length( $name );
    my $meta = $self->meta->find_method_by_name($name);
    return unless $meta && grep { $_ eq 'Action' } @{ $meta->attributes };
    my $action = $self->can( $name );
    return if !$action;
    my $out = $action->( $self, @parts );
    my $res;
    if( blessed $out and $out->isa( 'Plack::Response' ) ){
        $res = $out;
    }
    else{
        $res = $self->req->new_response(200);
        $res->content_type('text/html');
        $res->body( $out );
    }
    return $res;
}

1;

__END__

=head1 NAME

WebNano::Controller::WithAttributes - a role for marking Action methods by code attributes

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 local_dispatch

Finds action by checking the meta class.


