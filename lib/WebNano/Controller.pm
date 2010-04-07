package WebNano::Controller;
use Mouse;
use Class::MOP;

has application => ( is => 'ro' );
has request     => ( is => 'ro', isa => 'Plack::Request', required => 1 );
has self_url    => ( is => 'ro', isa => 'Str', required => 1 );

sub render {
    my ( $self, $template, $vars ) = @_;
    my $out;
    my $t = $self->application->renderer;
    $vars ||= {};
    $vars->{self_url} = $self->self_url;
    if( $t->process($template, $vars, \$out) ){
        return $out;
    }
    die $t->error;
}

sub controller_for {
    my ( $self, $path_part ) = @_;
    my $controller_class = ref($self) . '::' . $path_part;
    Class::MOP::load_class( $controller_class );
    return $controller_class->new( 
        application => $self->application, 
        request => $self->request, 
        self_url => $self->self_url . $path_part  . '/',
    );
}

sub find_action_ {
    my ( $self, $name ) = @_;
    my $method = $name . '_action';
    return $method if $self->can( $method );
    return;
}

sub handle {
    my ( $self, @args ) = @_;
    my $path_part = shift @args;
    $path_part =~ s/::|'//g if defined( $path_part );
    $path_part = 'index' if !defined( $path_part ) || !length( $path_part );
    if ( my $action = $self->find_action_( $path_part ) ){
        return $self->$action( @args );
    }
    elsif( my $new_controller = eval{ $self->controller_for( $path_part ) } ){
        return $new_controller->handle( @args );
    }
    else{
        my $res = $self->request->new_response(404);
        $res->content_type('text/plain');
        $res->body( 'No such page' );
        return $res;
    }
};

1;

__END__

=head1 NAME

WebNano - Really minimalistic web framework


=head1 VERSION

This document describes WebNano::Controller version 0.001

=head1 SYNOPSIS

    extend WebNano;
  
=head1 DESCRIPTION

=head1 METHODS

=head2 handle

Returns a Plack::Response object or a string containing the HTML page.

=head2 controller_for

Finds a next controller to forward to according to the first path part.

=head2 render

Renders a template.

=head2 is_action

Checks if a method is callable from the web.

=head1 ATTRIBUTES

=head2 application
=head2 request
=head2 self_url


