use strict;
use warnings;

package MyApp;
use base 'WebNano';
use WebNano::TTTRenderer;

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new( @_ );
    $self->renderer( WebNano::TTTRenderer->new( root => 'templates' ) );
    return $self;
}

1;

