use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use lib 't/lib';
use MyApp;
use File::Copy;
use WebNano::TTTRenderer;

copy('t/data/dvdzbr.db','t/tmp/dvdzbr.db') or die "Copy failed: $!";

my $dt = WebNano::TTTRenderer->new( root => 't/data/templates' );
my $rendered;
$dt->render( template => 'dummy_template', vars => { some_var => 'some value' }, output => \$rendered );
ok( $rendered =~ /some_var: some value/, 'vars' );
ok( $rendered =~ /^Some text/, 'Slurping template file' );

test_psgi( 
    app => MyApp->new()->psgi_callback, 
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
        $res = $cb->(GET "SubController/with_template");
        like( $res->content, qr/This is a SubController page rendered with a template/ );

        $res = $cb->(GET "Product/some");
        like( $res->content, qr/This is the example template for ControllerWithTemplates/ );
        $res = $cb->(GET "Product/another");
        like( $res->content, qr/This is template for Product/ );
        $res = $cb->(GET "Product/third");
        like( $res->content, qr/This is template for Product/ );

        $res = $cb->(GET "Book/some");
        like( $res->content, qr/This is the example template for ControllerWithTemplates/ );
        $res = $cb->(GET "Book/another");
        like( $res->content, qr/This is template for Product/ );
        $res = $cb->(GET "Book/third");
        like( $res->content, qr/This is template for Book/ );

        $res = $cb->(GET "/there_is_no_such_page");
        is( $res->code, 404 , '404 for non existing controller' );
        $res = $cb->(GET "/ThisIsNotController/");
        is( $res->code, 404 , '404 for a non controller' );
        $res = $cb->(GET "/streaming?who=zby");
        like( $res->content, qr/Hello, zby/ );
#        $res = $cb->(GET "/DoesNotCompile/");
#        is( $res->code, 500, '500 for controller that does not compile' );
#        in some circumstances the above code dies instead of issuing a 500
     } 
);

done_testing();
