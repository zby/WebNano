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
    my $c = $params{c};
    my @input_path;
    if( $c ){
        @input_path = $c->self_path;
        push @input_path, @{ $c->template_search_path } if $c->template_search_path;
    }
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
    my $tt = $self->_tt;
    my $output;
    $tt->process( $params{template}, \%params, \$output ) 
        || die $tt->error();
    return $output;
}

1;

__END__

=head1 NAME

WebNano::Renderer::TT - Template Tookit renderer for WebNano

=head1 SYNOPSIS

    use WebNano::Renderer::TT;
    $renderer = WebNano::Renderer::TT->new( root => [ 't/data/tt1', 't/data/tt2' ] );
    $out = '';
    $renderer->render( template => 'template.tt', search_path => [ 'subdir1', 'subdir2' ], output => \$out );

=head1 DESCRIPTION

