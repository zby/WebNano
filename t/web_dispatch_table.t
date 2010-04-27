use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use lib 't/lib';
use MyApp;
use File::Copy;

test_psgi( 
    app => MyApp->get_handler, 
    client => sub {
        my $cb = shift;
        my $res = $cb->(GET "/WebDispatchTable");
        like( $res->content, qr/This is index in web_dispatch table/ );
        my $res = $cb->(GET "/WebDispatchTable/some_address");
        like( $res->content, qr/This is some_address in web_dispatch table/ );
     } 
);

done_testing();
