use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use lib 't/lib';
use MyApp;

test_psgi( 
    app => MyApp->new()->psgi_app, 
    client => sub {
        my $cb = shift;
        my $res = $cb->(GET "/DSL");
        like( $res->content, qr/This is index in web_dispatch table/ );
        $res = $cb->(GET "/DSL/some_address");
        like( $res->content, qr/This is some_address in web_dispatch table/ );
     } 
);

done_testing();
