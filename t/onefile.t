use strict;
use warnings;

use Test::More;
use Plack::Test;
use HTTP::Request::Common;

test_psgi( 
    app => MyApp->new()->psgi_callback, 
    client => sub {
        my $cb = shift;
        my $res = $cb->(GET "/");
        is( $res->content, 'This is my home' );
    }
);

done_testing;

{
    package MyApp;
    use base 'WebNano';
}

{
    package MyApp::Controller;
    use base 'WebNano::Controller';
    
    sub index_action {
        my $self = shift;
        return 'This is my home';
    }
}    
   
