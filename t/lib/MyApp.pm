package MyApp;
use Moose;
extends 'WebNano';
use Bread::Board;
use Config::Any;
use Template;
use MyApp::DBSchema;

has schema => ( is => 'ro' );

sub bb {
    container 'MyApp' => as { 
        service renderer => (
            class => 'Template',
        );
        service schema => (
            block => sub {
                my $config = shift->params;
                return MyApp::DBSchema->connect( $config->{dbi_dsn}, $config->{user}, $config->{pass}, $config->{dbi_params} )
            },
        );
        service application => (
            class  => 'MyApp',
            dependencies => [ depends_on('renderer'), depends_on('schema') ],
            lifecycle    => 'Singleton',
        );
    }; 
}

sub get_handler {
    my( $self, $conf_file ) = @_;
    my $bb = $self->bb;
    my $config = $self->get_config( $conf_file || 't/data/app' );
    for my $key ( keys %$config ){
        my $service = $bb->fetch( $key );
        $service->dependencies( $self->mk_deps( $config->{$key} ) );
    }
    $bb->fetch('application')->get->handler();
}

sub mk_deps {
    my( $self, $params ) = @_;
    return if !defined $params;
    my %hash;
    for my $key ( keys %$params ){
        $hash{$key} = Bread::Board::Literal->new( name => 'aaa', value => $params->{$key} );
    }
    return \%hash;
}


sub get_config {
    my( $self, $conf_file ) = @_; 
    
    my $cfg = Config::Any->load_stems({ stems => [ $conf_file ], use_ext => 1 }); 
    my @values = values %{$cfg->[0]};
    return $values[0];
}

no Bread::Board; # removes keywords

1;


