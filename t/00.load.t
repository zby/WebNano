use strict;
use warnings;

use Test::More tests => 2;

BEGIN {
use_ok( 'WebNano' );
use_ok( 'WebNano::Controller' );
}

diag( "Testing WebNano $WebNano::VERSION" );
