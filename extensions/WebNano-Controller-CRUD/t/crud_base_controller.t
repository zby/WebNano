use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use lib 't/lib';
use lib 'extensions/lib';
use MyApp;
use File::Copy;

for my $controller( qw/DvdWithBaseCRUD OwnTemplates/ ){

    copy('t/data/dvdzbr.db','t/tmp/dvdzbr.db') or die "Copy failed: $!";

    test_psgi( 
        app => MyApp->new()->psgi_callback, 
        client => sub {
            my $cb = shift;
            $res = $cb->(GET "/$controller/");
            like( $res->content, qr/Jurassic Park II/ );
            $res = $cb->(POST "/$controller/5/edit", [ name => 'Not Jurassic Park' ] );
            ok( $res->is_redirect, 'Redirect after POST' );
            $res = $cb->(GET $res->header('Location'));
            like( $res->content, qr/Not Jurassic Park/ );
            $res = $cb->(POST "/$controller/create", [ name => 'A new dvd', owner => 1 ] );
            ok( $res->is_redirect, 'Redirect after POST' );
            $res = $cb->(GET $res->header('Location'));
            like( $res->content, qr/A new dvd/ );
            $res = $cb->(GET "/$controller/view/5");
            is( $res->code, 404 , '404 for view with no record' );
            $res = $cb->(GET "/$controller/555/view");
            is( $res->code, 404 , '404 for view with no record' );
         } 
    );
}

test_psgi( 
    app => MyApp->new()->psgi_callback, 
    client => sub {
        my $cb = shift;
        $res = $cb->(GET "/OwnTemplates/");
        like( $res->content, qr{This is t/data/templates/OwnTemplates/list.tt} );
        $res = $cb->(GET "/OwnTemplates/5/view");
        like( $res->content, qr{This is t/data/templates/OwnTemplates/record.tt} );
    }
);

done_testing();
