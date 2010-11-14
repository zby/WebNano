use strict;
use warnings;

package WebNano::DirController;
use WebNano::FindController 'find_nested';
use base 'WebNano::Controller';

sub _self_path{
    my $class = shift;
    my $path = $class;
    $path =~ s/.*::Controller(?=(::|$))//;
    $path =~ s{::}{/};
    return $path . '/';
}

sub handle {
    my ( $class, %args ) = @_;
    my $path = delete $args{path};
    my $self = $class->new( %args );
    my $out = $self->local_dispatch( $path );
    return $out if $out;
    my( $path_part, $new_path ) = ( $path =~ qr{^([^/]*)/?(.*)} );
    $path_part =~ s/::|'//g if defined( $path_part );
    return if !length( $path_part );
    my $controller_class = find_nested( $class->_self_path . $path_part, $args{app}->controller_search_path );
    return if !$controller_class;
    return $controller_class->handle(
        %args,
        path => $new_path,  
        self_url  => $args{self_url} . $path_part . '/',
    );
}


1;



=pod

=head1 NAME

WebNano::DirController - WebNano controller class for root

=head1 VERSION

version 0.002

=head1 SYNOPSIS

    use base WebNano::DirController;

=head1 DESCRIPTION

This is the WebNano pass through base controller - used for root controllers
and all other controllers that have sub-controllers.

In a path C</SomeDeepController/OtherController/LeaveController/method> all
C<MyApp::Controoler>, C<MyApp::Controller::SomeDeepController> 
and C<MyApp::Controller::SomeDeepController::OtherController> need to be DirControllers.

If there is no suitable method in the current class, child controller classes
are tried out.  If there is found one that matches the path part then it is
instantiated with the current psgi env and it's handle method is called.

=head1 METHODS

=head2 handle

=head1 AUTHOR

Zbigniew Lukasiak <zby@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Zbigniew Lukasiak <zby@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

# ABSTRACT: WebNano controller class for root

