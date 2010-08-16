package WebNano::Renderer::TTiny;
use strict;
use warnings;

use Template::Tiny;
use Object::Tiny::RW qw/ root _tt_tiny /;
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
    my( $self, $c, $template, $vars ) = @_;
    $vars ||= {};
    $vars->{self_url} = $c->self_url;
    $vars->{c} = $c;

    my $path = $c->self_path;
    $path =~ s{^/}{};
    my @search_path = ( $path, @{ $c->template_search_path });
    if( !@search_path ){
        @search_path = ( '' );
    }
    my $full_template;
    LOOP:
    for my $path ( @search_path ){
        my $to_check;
        if( !$self->root || File::Spec->file_name_is_absolute( $path ) ){
            $to_check = File::Spec->catfile( $path, $template );
            if( -f $to_check ){ 
                $full_template = $to_check;
                last LOOP;
            }
        }
        else{
            for my $root ( _to_list( $self->root ) ){
                $to_check = File::Spec->catfile( $root, $path, $template );
                if( -f $to_check ){ 
                    $full_template = $to_check;
                    last LOOP;
                }
            }
        }
    }
    die "Cannot find $template in search path: @search_path" if !defined $full_template;
    open my $fh, $full_template or die "Cannot read from $full_template: $!";
    my $string = do { local $/; <$fh> };
    if( !$self->_tt_tiny ){
        $self->_tt_tiny( Template::Tiny->new() );
    }
    my $out;
    $self->_tt_tiny->process( \$string, $vars, \$out );
    return $out;
}

1;

