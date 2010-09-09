use strict;
use warnings;

package MyApp;
use base 'WebNano';
use WebNano::Renderer::TTiny;

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new( @_ );
    $self->renderer( WebNano::Renderer::TTiny->new( $self->renderer_config() ) );
    return $self;
}

sub renderer_config { root => 't/data/templates' }

1;

