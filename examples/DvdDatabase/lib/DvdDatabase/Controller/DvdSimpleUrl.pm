package DvdDatabase::Controller::DvdSimpleUrl;
use Moose;
use MooseX::NonMoose;

extends 'WebNano::Controller';

use DvdDatabase::Controller::Dvd::Form;

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

sub record_path {
    my $self = shift;
    return defined( $self->path->[0] ) and $self->path->[0] =~ /^\d+$/;
}

sub action_postfix {
    my $self = shift;
    if( $self->record_path ){
        return '_record';
    }
    else{
        return '_action';
    }
}

sub action_name { 
    my $self = shift;
    if( $self->record_path ){
        if( defined $self->record ){
            return $self->path->[1];
        }
        else{
            return 'no';
        }
    }
    return $self->path->[0] || 'index';
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

sub view_record {
    my ( $self, ) = @_;
    return $self->render( record => $self->record );
}

sub delete_record {
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

sub edit_record {
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

