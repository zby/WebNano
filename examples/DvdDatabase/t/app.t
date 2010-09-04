use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use DvdDatabase;
use File::Copy;
use Plack::Middleware::Session;
use Test::WWW::Mechanize::PSGI;

copy('t/data/dvdzbr.db','dvdzbr.db') or die "Copy failed: $!";
my $app = Plack::Middleware::Session->wrap( DvdDatabase->new()->psgi_callback );
my $mech = Test::WWW::Mechanize::PSGI->new( app => $app );
$mech->get_ok( '/session_check' );
$mech->content_contains( "Hello, you've been here for 1th time!" );
$mech->get_ok( '/session_check' );
$mech->content_contains( "Hello, you've been here for 2th time!" );

$mech->get_ok( '/user' );
$mech->content_contains( "No user logged in" );
$mech->get_ok( '/user?login=zby&password=aaa' );
$mech->content_contains( "Current user is zby" );
$mech->get('/');
$mech->get_ok( '/user' );
$mech->content_contains( "Current user is zby" );

done_testing();
