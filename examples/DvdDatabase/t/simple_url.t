use strict;
use warnings;

use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use DvdDatabase;
use File::Copy;
use Plack::Middleware::Session;
use Test::WWW::Mechanize::PSGI;

for my $controller( qw/DvdSimpleUrl/ ){
    copy('t/data/dvdzbr.db','dvdzbr.db') or die "Copy failed: $!";

    my $app = Plack::Middleware::Session->wrap( DvdDatabase->new()->psgi_callback );
    test_psgi( 
        app => $app,
        client => sub {
            my $cb = shift;
            my $res;
            $res = $cb->(GET "/$controller");
            like( $res->content, qr/Jurassic Park II/ );
            $res = $cb->(POST "/$controller/5/edit", [ name => 'Not Jurassic Park', owner => 1 ] );
            warn $res->content;
            ok( $res->is_redirect, 'Redirect after POST' );
            $res = $cb->(GET $res->header('Location'));
            like( $res->content, qr/Not Jurassic Park/ );
            $res = $cb->(GET "/$controller/5/view");
            like( $res->content, qr/Not Jurassic Park/, 'view' );
            $res = $cb->(GET "/$controller/view/5");
            is( $res->code, 404 , '404 for view with no record' );
            $res = $cb->(GET "/$controller/555/view");
            is( $res->code, 404 , '404 for view with no record' );
         } 
    );
}

done_testing();
