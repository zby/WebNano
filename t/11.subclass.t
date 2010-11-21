use strict;
use warnings;

use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use lib 't/lib';
use SubClassApp;
use File::Copy;
use WebNano::Renderer::TTiny;

test_psgi( 
    app => SubClassApp->new()->psgi_callback, 
    client => sub {
        my $cb = shift;
        my $res = $cb->(GET "/");
        like( $res->content, qr/This is the home page/ );
        $res = $cb->(GET "/mapped url");
        like( $res->content, qr/This is the mapped url page/ );

        $res = $cb->(GET "NestedController/some_method");
        like( $res->content, qr/This is a method with _action postfix/ );
        $res = $cb->(GET "NestedController/safe_method");
        like( $res->content, qr/This is the safe_method page/ );
        $res = $cb->(GET "NestedController/with_template");
        like( $res->content, qr/This is a NestedController page rendered with a template/ );

        $res = $cb->(GET "NestedController2/some_method");
        like( $res->content, qr/This is a method with _action postfix in MyApp::Controller::NestedController2/ );
        $res = $cb->(GET "NestedController2/with_template");
        like( $res->content, qr/This is a SubClassApp::Controller::NestedController2 page rendered with a template/ );

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

test_psgi( 
    app => SubClassApp->new()->psgi_callback, 
    client => sub {
        my $cb = shift;
        my $res = $cb->(GET "ToBeOverridden/some");
        is( $res->content, 'SubClassApp::Controller::ToBeOverridden', 'overridden controller' );
        $res = $cb->(GET "ToBeOverridden/other");
        is( $res->code, 404 , 'actions are not merged' );
        $res = $cb->(GET "ToBeOverridden/templated");
        is( $res->content, "t/data/templates/ToBeOverridden/templated\n", 'templates are independent' );
     } 
);

done_testing();
