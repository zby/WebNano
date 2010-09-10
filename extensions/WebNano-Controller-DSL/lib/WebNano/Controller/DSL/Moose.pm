use strict;
use warnings;

package WebNano::Controller::DSL::Moose;

use Moose ();
use Moose::Exporter;

Moose::Exporter->setup_import_methods(
    with_meta => [ 'get' ],
    also      => 'Moose',
);

sub get {
    my( $meta, $path, $action ) = @_;
    $meta->web_dispatch()->{$path} = $action;
}

1;

