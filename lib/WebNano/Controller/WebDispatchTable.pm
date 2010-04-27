package WebNano::Controller::WebDispatchTable;

use Moose ();
use Moose::Exporter;

Moose::Exporter->setup_import_methods(
    with_meta => [ 'get' ],
);

sub get {
    my( $meta, $path, $action ) = @_;
    $meta->web_dispatch()->{$path} = $action;
}

1;

