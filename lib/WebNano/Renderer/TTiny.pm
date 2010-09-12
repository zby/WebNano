package WebNano::Renderer::TTiny;
use strict;
use warnings;

use Template::Tiny;
use Object::Tiny::RW qw/ root _tt_tiny INCLUDE_PATH TEMPLATE_EXTENSION /;
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
    my( $self, %vars ) = @_;
    my $c = $vars{c};

    my @search_path;
    if( $c ){
        my $path = ref $c;
        $path =~ s/.*::Controller(::)?//;
        $path =~ s{::}{/};
        @search_path = ( $path, @{ $c->template_search_path });
    }
    if( !@search_path ){
        @search_path = ( '' );
    }
    my $template = $vars{template};
    if( !$template ){
        my @caller = caller(2);
        $template =  $caller[3];
        $template =~ s/_action$//;
        $template =~ s/^.*:://;
        $template .= '.' . $self->TEMPLATE_EXTENSION if $self->TEMPLATE_EXTENSION;
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
    my @static_search_path;
    if( !$full_template ){
        @static_search_path = _to_list( $self->INCLUDE_PATH );
        STATIC_LOOP:
        for my $path ( @static_search_path ){
            my $to_check;
            $to_check = File::Spec->catfile( $path, $template );
            if( -f $to_check ){ 
                $full_template = $to_check;
                last STATIC_LOOP;
            }
        }
    }
    die "Cannot find $template in search path: @search_path, @static_search_path" if !defined $full_template;
    open my $fh, $full_template or die "Cannot read from $full_template: $!";
    my $string = do { local $/; <$fh> };
    if( !$self->_tt_tiny ){
        $self->_tt_tiny( Template::Tiny->new() );
    }
    my $out;
    $self->_tt_tiny->process( \$string, \%vars, \$out );
    return $out;
}

1;

__END__

# ABSTRACT: Dynamic search paths for Template::Tiny

=head1 SYNOPSIS

in MyApp.pm: 

    $self->renderer( 
        WebNano::Renderer::TTiny->new( root => 't/data/templates' )
    );
    
in MyApp::Controller:

    return $self->render( template => 'some_template.tt', some_var => 'some_value );

=head1 DESCRIPTION

This is a wrapper around
L<Template::Tiny|http://search.cpan.org/~adamk/Template-Tiny/lib/Template/Tiny.pm>
- 'Template Toolkit reimplemented in as little code as possible'.

The only public method here is render - it expects as input a hash with the
following data:

=over

=item template - the name of the template file

=item c - the controller

=back

The template is then looked for in the directories in C<INCLUDE_PATH> and in
directories constructed dynamically from the paths in C<root> and the controller
name.  For example if 'root' contains C<[ 'template', 'additional_templates' ]>
and the controller name is C<MyApp::Controller::SubController> then the template
will be looked for in C<template/SubController> and
C<additional_templates/SubController>.  This mechanism is designed so that it is
possible for a way of subclassing templates along with subclassing controllers.
If this is too complicated - you can provide no value for the C<root> attribute
and use only C<INCLUDE_PATH>.

When the template is found - the C<process> method on the internal
C<Template::Tiny> object is called.  A reference to the whole hash passed to
C<render> is passed to the C<process> call - so that all the values are
available in the template itself.

If no template name is passed - then it is guessed from the name of the
controller method that called C<render> (this is done using L<caller>) and the
C<TEMPLATE_EXTENSION> attribute.

=head1 ATTRIBUTES and METHODS

=head2 render

=head2 INCLUDE_PATH

Static list of template search directories.

=head2 root

List of directories that are dynamically concatenated with controller names to form
a dynamic search list of template directories.

You can use INCLUDE_PATH or root or both.

=head2 TEMPLATE_EXTENSION

Postfix added to action name to form the template name ( for example 'edit.tt'
from action 'edit' and TEMPLATE_EXTENSION 'tt' ).

