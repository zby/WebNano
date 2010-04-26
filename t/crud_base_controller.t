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
        $res = $cb->(GET "/DvdWithBaseCRUD/list");
        like( $res->content, qr/Jurassic Park II/ );
        $res = $cb->(POST '/DvdWithBaseCRUD/5/edit', [ name => 'Not Jurassic Park' ] );
        ok( $res->is_redirect, 'Redirect after POST' );
        $res = $cb->(GET $res->header('Location'));
        like( $res->content, qr/Not Jurassic Park/ );
        $res = $cb->(POST '/DvdWithBaseCRUD/create', [ name => 'A new dvd', owner => 1 ] );
        ok( $res->is_redirect, 'Redirect after POST' );
        $res = $cb->(GET $res->header('Location'));
        like( $res->content, qr/A new dvd/ );
     } 
);

done_testing();
