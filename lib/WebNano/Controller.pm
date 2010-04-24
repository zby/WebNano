package WebNano::Controller;
use Any::Moose;
use Class::MOP;
use Try::Tiny;
use URI::Escape 'uri_unescape';
use Plack::Request;


has application => ( is => 'ro' );
has request     => ( is => 'ro', isa => 'Plack::Request', required => 1 );
has self_url    => ( is => 'ro', isa => 'Str', required => 1 );
has url_map     => ( is => 'ro', isa => 'Ref' );

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
    my ( $self, $path ) = @_;
    my( $path_part, $new_path ) = ( $path =~ qr{^([^/]*)/?(.*)} );
    $path_part =~ s/::|'//g if defined( $path_part );
    return if !length( $path_part );
    my $controller_class = ref($self) . '::' . $path_part;
    my $loaded;
    try{
        Class::MOP::load_class( $controller_class );
        $loaded = 1;
    }
    catch {
        if( $_ !~ /Can't locate .*$path_part.pm in \@INC/ ){
            die $_;
        }
    };
    return if !$loaded;
    my $new_controller = $controller_class->new( 
        application => $self->application, 
        request => $self->request, 
        self_url => $self->self_url . $path_part  . '/',
    );
    return ( $new_controller, $new_path );
}

sub local_dispatch {
    my ( $self, $path ) = @_;
    my @parts = split /\//, $path;
    my $name = uri_unescape( shift @parts );
    $name = 'index' if !defined( $name ) || !length( $name );
    my $action;
    if( my $map = $self->url_map ){
        if( ref $map eq 'HASH' ){
            $action = $self->can( $map->{$name} ) if $map->{$name};
        }
        if( ref $map eq 'ARRAY' ){
            $action = $self->can( $name ) if grep { $_ eq $name } @$map;
        }
    }
    my $method = $name . '_action';
    $action = $self->can( $method ) if !$action;
    return if !$action;
    my $out = $action->( $self, @parts );
    my $res;
    if( blessed $out and $out->isa( 'Plack::Response' ) ){
        $res = $out;
    }
    else{
        $res = $self->request->new_response(200);
        $res->content_type('text/html');
        $res->body( $out );
    }
    return $res;
}

sub handle {
    my ( $self, $path ) = @_;
    my $res = $self->local_dispatch( $path );
    return $res if defined $res;
    if( my ( $new_controller, $new_path ) = $self->controller_for( $path ) ){
        return $new_controller->handle( $new_path );
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

WebNano::Controller 

=head1 SYNOPSIS

    package MyApp::Controller;
    
    use Moose;
    extends 'WebNano::Controller';
    
    has '+url_map' => ( default => sub { { 'mapped url' => 'mapped_url' } } );
    
    sub index_action {
        my $self = shift;
        return $self->render( 'index.tt' );
    }
    
    sub mapped_url { 'This is the mapped url page' }
    
    1;


=head1 DESCRIPTION

The first parameter to the handle method is expected to be the name of the action
to be called.  The default value of that parameter is 'index'.
The corresponding method name is retrieved from the (optional) url_map
hash attribute or is created by adding the '_action' postfix.

The action method should return a a string containing the HTML page or
a Plack::Response object.

If there is no suitable method in the current class child controller classes 
are tried out (their name is mapped literally).  If there is found one that 
matches the path part then it is instantiated with the current request
and it's handle method is called.

=head1 METHODS

=head2 handle

Dispatches the request to the action methods as described above.

Returns a Plack::Response object or a string containing the HTML page.

=head2 controller_for

Finds a next controller to forward to according to the path.

=head2 render

Renders a template.

=head2 local_dispatch

Finds the method to be called for a path and dispatches to it.

=head1 ATTRIBUTES

=head2 url_map
=head2 application
=head2 request
=head2 self_url


