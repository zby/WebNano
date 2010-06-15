package WebNano::Renderer::TT;
use strict;
use warnings;

use Template;
use Class::XSAccessor { accessors => [ qw/ root _tt global_path INCLUDE_PATH / ], };
use File::Spec;

sub new {
    my( $class, %args ) = @_;
    my $self = bless { 
        global_path => [ _to_list( delete $args{INCLUDE_PATH} ) ],
        root => delete $args{root},
    }, $class;
    # Use a weakend copy of self so we dont have loops preventing GC from working
    my $copy = $self;
    Scalar::Util::weaken($copy);
    $args{INCLUDE_PATH} = [ sub { $copy->INCLUDE_PATH } ];
    $self->_tt( Template->new( \%args ) );
    return $self;
}


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
    my @path = @{ $self->global_path };
    for my $root( _to_list( $self->root ) ){
        for my $sub_path( @input_path ){
            push @path, File::Spec->catdir( $root, $sub_path );
        }
    }
    $self->INCLUDE_PATH( \@path );
    $self->_tt->process( $params{template}, $params{vars}, $params{output} );
}

1;

