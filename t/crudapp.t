use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use lib 't/lib';
use MyApp;
use File::Copy;

copy('t/data/dvdzbr.db','t/tmp/dvdzbr.db') or die "Copy failed: $!";

test_psgi( 
    app => MyApp->new()->psgi_callback, 
    client => sub {
        my $cb = shift;
        my $res = $cb->(GET "/");
        $res = $cb->(GET "/Dvd");
        like( $res->content, qr/Jurassic Park II/ );
        $res = $cb->(POST '/Dvd/record/5/edit', [ name => 'Not Jurassic Park' ] );
        ok( $res->is_redirect, 'Redirect after POST' );
        $res = $cb->(GET $res->header('Location'));
        like( $res->content, qr/Not Jurassic Park/ );
        $res = $cb->(POST '/DvdSimpleUrl/5/edit', [ name => 'Not even trace of Jurrasic Park' ] );
        ok( $res->is_redirect, 'Redirect after POST' );
        $res = $cb->(GET $res->header('Location'));
        like( $res->content, qr/Not even trace of Jurrasic Park/ );
     } 
);

done_testing();
