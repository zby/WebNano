use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use DvdDatabase;
use File::Copy;
use Plack::Middleware::Session;
use Test::WWW::Mechanize::PSGI;

copy('t/data/dvdzbr.db','t/tmp/dvdzbr.db') or die "Copy failed: $!";

my $app = Plack::Middleware::Session->wrap( DvdDatabase->new()->psgi_callback );
test_psgi( 
    app => $app,
    client => sub {
        my $cb = shift;
        my $res;
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

my $mech = Test::WWW::Mechanize::PSGI->new( app => $app );
$mech->get_ok( '/session_check' );
$mech->content_contains( "Hello, you've been here for 1th time!" );
$mech->get_ok( '/session_check' );
$mech->content_contains( "Hello, you've been here for 2th time!" );
done_testing();
