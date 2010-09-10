use strict;
use warnings;

use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use lib 't/lib';
use MyApp;

test_psgi( 
    app => MyApp->new()->psgi_callback, 
    client => sub {
        my $cb = shift;
        my $res = $cb->(GET "/WithAttributes");
        like( $res->content, qr/This is index/ );
        $res = $cb->(GET "/WithAttributes/some_address");
        like( $res->content, qr/This is some_address/ );
     } 
);

done_testing();
