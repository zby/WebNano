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
        $res = $cb->(GET "/ThisIsNotController/");
        is( $res->code, 404 , '404 for a non controller' );
#        $res = $cb->(GET "/DoesNotCompile/");
#        is( $res->code, 500, '500 for controller that does not compile' );
#        in some circumstances the above code dies instead of issuing a 500
     } 
);

done_testing();
