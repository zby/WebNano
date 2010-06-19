package DvdDatabase;
use Moose;
use MooseX::NonMoose;
extends 'WebNano';
use Config::Any;
use DvdDatabase::DBSchema;
use WebNano::TTTRenderer;

has config => ( is => 'ro', isa => 'HashRef', lazy_build => 1 );

sub _build_config {
    my( $self ) = @_;
    return $self->get_config( 't/data/app' );
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
    return WebNano::TTTRenderer->new( %$config );
}

sub get_config {
    my( $self, $conf_file ) = @_; 
    
    my $cfg = Config::Any->load_stems({ stems => [ $conf_file ], use_ext => 1 }); 
    my @values = values %{$cfg->[0]};
    return $values[0];
}

1;

__END__

=head1 NAME

DvdDatabase - A WebNano based example application.

=head1 SYNOPSIS

    zby@zby:~/progs/WebNano/examples/DvdDatabase$ plackup -Ilib 
    HTTP::Server::PSGI: Accepting connections at http://0:5000/

=head1 DESCRIPTION

CRUD operations on a database of DVD films.

