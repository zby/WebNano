package SubClassApp;
use Moose;
extends 'MyApp';

sub _build_config {
    my( $self ) = @_;
    return $self->get_config( 't/data/subclassapp' );
}

sub controller_search_path { [ ref(shift), 'MyApp' ] };


1;

