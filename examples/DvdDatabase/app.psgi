use warnings;
use strict;

use DvdDatabase;
use Plack::Builder;


my $app = DvdDatabase->new();
builder {
    enable 'Session';
    $app->psgi_callback;
}


