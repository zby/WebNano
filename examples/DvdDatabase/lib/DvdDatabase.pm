package DvdDatabase;
use Moose;
use MooseX::NonMoose;
extends 'WebNano';
use Config::Any;
use Plack::Request;
use WebNano::Renderer::TTiny;

use DvdDatabase::DBSchema;

has config => ( is => 'ro', isa => 'HashRef', lazy_build => 1 );

sub _build_config {
    my( $self ) = @_;
    return $self->get_config( 'app' );
}

has schema => ( is => 'ro', isa => 'DBIx::Class::Schema', lazy_build => 1 );

sub _build_schema {
    my $self = shift;
    my $config = $self->config->{schema};
    return DvdDatabase::DBSchema->connect( $config->{dbi_dsn}, $config->{user}, $config->{pass}, $config->{dbi_params} );
}

has renderer => ( is => 'ro', lazy_build => 1 );
sub _build_renderer {
    my $self = shift;
    my $config = $self->config->{renderer};
    return WebNano::Renderer::TTiny->new( %$config );
}

sub get_config {
    my( $self, $conf_file ) = @_; 
    
    my $cfg = Config::Any->load_stems({ stems => [ $conf_file ], use_ext => 1 }); 
    my @values = values %{$cfg->[0]};
    return $values[0];
}

around handle => sub {
    my $orig = shift;
    my $self = shift;
    my $env  = shift;
    if( $env->{'psgix.session'}{user_id} ){
        $env->{user} = $self->schema->resultset( 'User' )->find( $env->{'psgix.session'}{user_id} );
    }
    else{
        my $req = Plack::Request->new( $env );
        if( $req->param( 'login' ) && $req->param( 'password' ) ){
            my $user = $self->schema->resultset( 'User' )->search( { username => $req->param( 'login' ) } )->first;
            if( $user->check_password( $req->param( 'password' ) ) ){
                $env->{user} = $user;
                $env->{'psgix.session'}{user_id} = $user->id;
            }
        }
    }
    $self->$orig( $env, @_ );
};


1;

__END__

=head1 NAME

DvdDatabase - A WebNano based example application.

=head1 SYNOPSIS

    zby@zby:~/progs/WebNano/examples/DvdDatabase$ plackup -Ilib 
    HTTP::Server::PSGI: Accepting connections at http://0:5000/

=head1 DESCRIPTION

CRUD operations on a database of DVD films.

