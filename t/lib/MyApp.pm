package MyApp;
use Moose;
extends 'WebNano';
use Config::Any;
use Template;
use MyApp::DBSchema;

has config => ( is => 'ro', isa => 'HashRef', lazy_build => 1 );

sub _build_config {
    my( $self ) = @_;
    return $self->get_config( 't/data/app' );
}

has schema => ( is => 'ro', isa => 'DBIx::Class::Schema', lazy_build => 1 );

sub _build_schema {
    my $self = shift;
    my $config = $self->config->{schema};
    return MyApp::DBSchema->connect( $config->{dbi_dsn}, $config->{user}, $config->{pass}, $config->{dbi_params} );
}

has renderer => ( is => 'ro', lazy_build => 1 );
sub _build_renderer {
    my $self = shift;
    my $config = $self->config->{renderer};
    return Template->new( $config );
}

sub get_handler { shift->new()->handler }

sub get_config {
    my( $self, $conf_file ) = @_; 
    
    my $cfg = Config::Any->load_stems({ stems => [ $conf_file ], use_ext => 1 }); 
    my @values = values %{$cfg->[0]};
    return $values[0];
}

1;

