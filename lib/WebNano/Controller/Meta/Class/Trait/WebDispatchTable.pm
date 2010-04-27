package WebNano::Controller::Meta::Class::Trait::WebDispatchTable;
use Moose::Role;

has web_dispatch => (
    is  => 'ro',
    isa => 'HashRef',
    default => sub { {} },
);

1;

