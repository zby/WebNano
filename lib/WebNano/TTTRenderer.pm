package WebNano::TTTRenderer;
use strict;
use warnings;

use Template::Tiny;
use Class::XSAccessor { accessors => [ qw/ root _tt_tiny / ], constructor => 'new', };
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
    my @search_path = _to_list( $params{search_path} );
    if( !@search_path ){
        @search_path = ( '' );
    }
    LOOP:
    for my $path ( @search_path ){
        my $to_check;
        if( !$self->root || File::Spec->file_name_is_absolute( $path ) ){
            $to_check = File::Spec->catfile( $path, $params{template} );
            if( -f $to_check ){ 
                $template = $to_check;
                last LOOP;
            }
        }
        else{
            for my $root ( _to_list( $self->root ) ){
                $to_check = File::Spec->catfile( $root, $path, $params{template} );
                if( -f $to_check ){ 
                    $template = $to_check;
                    last LOOP;
                }
            }
        }
    }
    die "Cannot find $params{template} in search path: @search_path" if !defined $template;
    open my $fh, $template or die "Cannot read from $template: $!";
    my $string = do { local $/; <$fh> };
    if( !$self->_tt_tiny ){
        $self->_tt_tiny( Template::Tiny->new() );
    }
    $self->_tt_tiny->process( \$string, $params{vars}, $params{output} );
}

1;

