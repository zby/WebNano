use strict;
use warnings;

use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use Encode;
use URI::Escape;
use utf8;

my $PLAIN_TEST_KEY = 'param1';
my $UTF_TEST_KEY = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다';
my $UTF_TEST_VALUE = 'Příliš žluťoučký kůň úpěl ďábelské ódy';

test_psgi( 
    app => MyApp->new()->psgi_app, 
    client => sub {
        my $cb = shift;
        my $res = $cb->(POST "http://localhost/", [$PLAIN_TEST_KEY => $UTF_TEST_VALUE]);
        is(decode_utf8($res->content), $UTF_TEST_VALUE, 'UTF-8 values in POSTed form');
    }
);

test_psgi( 
    app => MyApp->new()->psgi_app, 
    client => sub {
        my $cb = shift;
        my $res = $cb->(POST "http://localhost/", [$UTF_TEST_KEY => $UTF_TEST_VALUE]);
        is(decode_utf8($res->content), $UTF_TEST_VALUE, 'UTF-8 keys and values in POSTed form');
    }
);

test_psgi( 
    app => MyApp->new()->psgi_app, 
    client => sub {
        my $cb = shift;
        my $res = $cb->(GET "http://localhost/?" . uri_escape_utf8($UTF_TEST_KEY) . '=' . uri_escape_utf8($UTF_TEST_VALUE));
        is(decode_utf8($res->content), $UTF_TEST_VALUE, 'UTF-8 values as GET parameters');
    }
);

done_testing;

{
    package MyApp;
    use base 'WebNano';
    1;
}

{
    package MyApp::Controller;
    use base 'WebNano::Controller';
    
    sub index_action {
        my $self = shift;
        return $self->req->param($PLAIN_TEST_KEY) || $self->req->param($UTF_TEST_KEY);
    }
    1;
}    
   
