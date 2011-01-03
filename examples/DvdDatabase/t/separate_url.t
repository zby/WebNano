use strict;
use warnings;

use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use File::Copy;
use Test::WWW::Mechanize::PSGI;

use DvdDatabase;

for my $controller( qw/Dvd Dvd1 Dvd2/ ){
    copy('t/data/dvdzbr.db','dvdzbr.db') or die "Copy failed: $!";

    my $app = DvdDatabase->new()->psgi_app;
    test_psgi( 
        app => $app,
        client => sub {
            my $cb = shift;
            my $res;
            $res = $cb->(GET "/$controller");
            like( $res->content, qr/Jurassic Park II/ );
            $res = $cb->(POST "/$controller/record/5/edit", [ name => 'Not Jurassic Park', owner => 1 ] );
            ok( $res->is_redirect, 'Redirect after POST' );
            $res = $cb->(GET $res->header('Location'));
            like( $res->content, qr/Not Jurassic Park/ );
            $res = $cb->(GET "/$controller/record/5/view");
            like( $res->content, qr/Not Jurassic Park/ );
            $res = $cb->(GET "/$controller/view/5");
            is( $res->code, 404 , '404 for view with no record' );
            $res = $cb->(GET "/$controller/record/555/view");
            is( $res->code, 404 , '404 for view with no record' );
         } 
    );
}

done_testing();
