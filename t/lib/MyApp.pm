package MyApp;
use Moose;
extends 'WebNano';
use Bread::Board;
use Config::Any;
use Template;
use MyApp::DBSchema;

has schema => ( is => 'ro' );

sub get_handler {
    my $c = container 'MyApp' => as { 
        service config_name => 't/data/app';
        service config => (
            block => sub { 
                my $name = shift->param('config_name');
                my $cfg = Config::Any->load_stems({ stems => [ $name ], use_ext => 1 }); 
                my @values = values %{$cfg->[0]};
                return $values[0];
            },
            dependencies => [ depends_on('config_name') ],
            lifecycle    => 'Singleton',
        );
        service renderer => (
            block => sub {
                my $config = shift->param('config')->{renderer};
                my %config;
                %config = %$config if ref $config;
                return Template->new( %config )
            },
            dependencies => [ depends_on('config') ],
        );
        service schema => (
            block => sub {
                my $config = shift->param('config')->{schema};
                return MyApp::DBSchema->connect( $config->{dbi_dsn}, $config->{user}, $config->{pass}, $config->{dbi_params} )
            },
            dependencies => [ depends_on('config') ],
        );
        service application => (
            class  => 'MyApp',
            dependencies => [ depends_on('renderer'), depends_on('schema') ],
            lifecycle    => 'Singleton',
        );
    }; 
    $c->fetch('application')->get->handler();
}

no Bread::Board; # removes keywords

1;


