package WebNano::Renderer::TT;
use strict;
use warnings;

use Template;
use Class::XSAccessor { accessors => [ qw/ root _tt include_path / ], constructor => 'new', };
use File::Spec;

sub _to_list {
    if( ref $_[0] ){
        return @{ $_[0] };
    }
    elsif( ! defined $_[0] ){
        return ();
    }
    else{
        return $_[0];
    }
}

sub render {
    my( $self, %params ) = @_;
    my $template;
    my @input_path = _to_list( $params{search_path} );
    if( !@input_path ){
        @input_path = ( '' );
    }
    $self->include_path([]);
    for my $root( _to_list( $self->root ) ){
        for my $sub_path( @input_path ){
            push @{ $self->include_path }, File::Spec->catdir( $root, $sub_path );
        }
    }
    if( !$self->_tt ){
        $self->_tt( Template->new( INCLUDE_PATH => [ sub { $self->include_path } ] ) );
    }
    $self->_tt->process( $params{template}, $params{vars}, $params{output} );
}

1;

