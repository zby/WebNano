use strict;
use warnings;

package WebNano::DirController;
use WebNano::FindController 'find_nested';
#use base 'WebNano::Controller';

sub _self_path{
    my $self = shift;
    my $path = ref $self;
    $path =~ s/.*::Controller(?=(::|$))//;
    $path =~ s{::}{/};
    return $path . '/';
}

sub external_dispatch {
    my ( $self, %args ) = @_;
    my $path = delete $args{path};
    my $path_part = shift @$path;
    $path_part =~ s/::|'//g if defined( $path_part );
    return if !length( $path_part );
    my $controller_class = find_nested( $self->_self_path . $path_part, $self->app->controller_search_path );
    if( !$controller_class ){
        my $class = ref $self;
        warn qq{No subcontroller found in "$class" for "} . $self->_self_path . $path_part . qq{"\n} if $self->DEBUG;
        return;
    }
    warn qq{Dispatching to "$controller_class"\n} if $self->DEBUG;
    return $controller_class->handle(
        %args,
        path => $path,
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

