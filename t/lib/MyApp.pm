use strict;
use warnings;

package MyApp;
use base 'WebNano';
use Object::Tiny::RW 'config';
use Config::Any;
use WebNano::Renderer::TTiny;

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new( @_ );
    my $cfg = Config::Any->load_stems({ stems => [ $self->config_file ], use_ext => 1 }); 
    my @values = values %{$cfg->[0]};
    my $config = $values[0];
    $self->config( $config );
    $self->renderer( WebNano::Renderer::TTiny->new( %{ $config->{renderer} } ) );
    return $self;
}

sub config_file { 't/data/app' }

1;

