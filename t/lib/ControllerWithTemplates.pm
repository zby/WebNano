use strict;
use warnings;

package ControllerWithTemplates;

use base 'WebNano::Controller';
use File::Spec::Functions 'catdir';

my $FULLPATH;
BEGIN { use Cwd (); $FULLPATH = Cwd::abs_path(__FILE__) }

sub template_search_path {
    my $self = shift;
    my $mydir = $FULLPATH;
    $mydir =~ s/.pm$//;
    return [ catdir( $mydir, 'templates' ) ];
}

1;
