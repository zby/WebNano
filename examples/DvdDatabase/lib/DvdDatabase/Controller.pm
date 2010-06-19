use strict;
use warnings;

package DvdDatabase::Controller;

use base 'WebNano::Controller';

sub index_action {
    my $self = shift;
    my $res = $self->request->new_response();
    $res->redirect( '/Dvd/' );
    return $res;
}

1;

