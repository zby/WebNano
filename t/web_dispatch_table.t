use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use lib 't/lib';
use lib 'extensions/lib';
use MyApp;
use File::Copy;

test_psgi( 
    app => MyApp->new()->psgi_callback, 
    client => sub {
        my $cb = shift;
        my $res = $cb->(GET "/WebDispatchTable");
        like( $res->content, qr/This is index in web_dispatch table/ );
        $res = $cb->(GET "/WebDispatchTable/some_address");
        like( $res->content, qr/This is some_address in web_dispatch table/ );
     } 
);

done_testing();
