package DvdDatabase::Controller::DvdSimpleUrl;
use Moose;
use MooseX::NonMoose;

extends 'WebNano::Controller';

use DvdDatabase::Controller::Dvd::Form;

has url_map => ( 
    is => 'ro', 
    isa => 'HashRef', 
    default => sub { { view => 'view', 'delete' => 'delete', edit => 'edit' } }
);

has record => (
    is => 'ro',
    lazy => 1,
    builder => '_build_record',
);
sub _build_record {
    my $self = shift;
    my $id = $self->path->[0];
    if( $id =~ /^\d+$/ ){
        return $self->app->schema->resultset( 'Dvd' )->find( $id );
    }
    return;
}

sub action_name { 
    my $self = shift;
    my @path = @{ $self->path };
    warn "@path";
    if( defined( $path[0] ) and $path[0] =~ /^\d+$/ ){
        if( defined $self->record ){
            warn $self->record;
            return $path[1];
        }
        else{
            return 'no_record';
        }
    }
    return $path[0];
}

sub index_action {
    my( $self ) = @_;
    my $rs = $self->app->schema->resultset( 'Dvd' );
    return $self->render( template => 'list.tt', items => [ $rs->search ] );
}

sub create_action {
    my ( $self ) = @_;
    my $req = $self->req;

    my $form = DvdDatabase::Controller::Dvd::Form->new( 
        params => $req->parameters->as_hashref, 
        schema => $self->app->schema,
    );
    if( $req->method eq 'POST' && $form->process() ){
        my $record = $form->item;
        my $res = $req->new_response();
        $res->redirect( $self->self_url . $record->id . '/view' );
        return $res;
    }
    $form->field( 'submit' )->value( 'Create' );
    return $self->render( template => 'edit.tt', form => $form->render );
}

sub view {
    my ( $self, ) = @_;

    return $self->render( record => $self->record );
}

sub delete {
    my ( $self, ) = @_;
    if( $self->req->method eq 'GET' ){
        return $self->render( record => $self->record );
    }
    else{
        $self->record->delete;
        my $res = $self->req->new_response();
        $res->redirect( $self->self_url );
        return $res;
    }
}

sub edit {
    my ( $self, ) = @_;
    my $req = $self->req;
    my $form = DvdDatabase::Controller::Dvd::Form->new( 
        item   => $self->record,
        params => $req->parameters->as_hashref, 
    );
    if( $req->method eq 'POST' && $form->process() ){
        my $res = $req->new_response();
        $res->redirect( $self->self_url . $self->record->id . '/view' );
        return $res;
    }
    $form->field( 'submit' )->value( 'Update' );
    return $self->render( form => $form->render );
}

1;

