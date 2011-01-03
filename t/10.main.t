use strict;
use warnings;

use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use lib 't/lib';
use MyApp;
use File::Copy;
use WebNano::Renderer::TTiny;
use WebNano::Controller;

test_psgi( 
    app => MyApp->new()->psgi_app, 
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
        $res = $cb->(GET "NestedController/self_url");
        like( $res->content, qr{^/NestedController/$}, 'self_url' );

        $res = $cb->(GET "NestedController2/some_method");
        like( $res->content, qr/This is a method with _action postfix in MyApp::Controller::NestedController2/ );
        $res = $cb->(GET "NestedController2/with_template");
        like( $res->content, qr/This is a MyApp::Controller::NestedController2 page rendered with a template/ );

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
        $res = $cb->(GET "/DoesNotCompile/");
        is( $res->code, 500, '500 for controller that does not compile' );
#        in some circumstances the above code dies instead of issuing a 500

        $res = $cb->(GET "Deep/Nested/some");
        is( $res->content, "This is 'some_action' in 'MyApp::Controller::Deep::Nested'" );
     } 
);

done_testing();
