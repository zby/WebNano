use strict;
use warnings;

package MyApp::Controller::ToBeOverridden;
use base 'WebNano::Controller';

sub some_action { return __PACKAGE__ };

sub other_action { return __PACKAGE__ };

1;

