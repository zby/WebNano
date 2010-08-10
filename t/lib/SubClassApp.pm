use strict;
use warnings;

package SubClassApp;
use base 'MyApp';

sub config_file { 't/data/subclassapp' } 

sub controller_search_path { [ ref(shift), 'MyApp' ] };

1;

