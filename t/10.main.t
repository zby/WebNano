use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use lib 't/lib';
use MyApp;
use File::Copy;

copy('t/data/dvdzbr.db','t/tmp/dvdzbr.db') or die "Copy failed: $!";

test_psgi( 
    app => MyApp->get_handler, 
    client => sub {
        my $cb = shift;
        my $res = $cb->(GET "/");
        like( $res->content, qr/This is the home page/ );
        $res = $cb->(GET "/mapped url");
        like( $res->content, qr/This is the mapped url page/ );
        $res = $cb->(GET "SubController/some_method");
        like( $res->content, qr/This is a method with _action postfix/ );
        $res = $cb->(GET "SubController/safe_method");
        like( $res->content, qr/This is the safe_method page/ );
        $res = $cb->(GET "/there_is_no_such_page");
        is( $res->code, 404 , '404 for non existing controller' );
     } 
);

done_testing();
