use strict;
use warnings;

package WebNano::Controller::Meta::Class::Trait::WebDispatchTable;
use Moose::Role;
Moose::Util::meta_class_alias('WebDispatchTable');

has web_dispatch => (
    is  => 'ro',
    isa => 'HashRef',
    default => sub { {} },
);

1;

