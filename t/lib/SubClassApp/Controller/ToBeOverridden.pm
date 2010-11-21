use strict;
use warnings;

package SubClassApp::Controller::ToBeOverridden;
use base 'WebNano::Controller';

sub some_action { return __PACKAGE__ };

sub templated_action { return shift->render() }

1;

