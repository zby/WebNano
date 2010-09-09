use strict;
use warnings;

package SubClassApp;
use base 'MyApp';

sub renderer_config { root => [ 't/data/subclassapp_templates', 't/data/templates' ] }

sub controller_search_path { [ ref(shift), 'MyApp' ] };

1;

