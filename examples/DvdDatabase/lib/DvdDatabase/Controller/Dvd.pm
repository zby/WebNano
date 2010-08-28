use strict;
use warnings;

package DvdDatabase::Controller::Dvd;
use base 'WebNano::Controller';

use DvdDatabase::Controller::Dvd::Form;
use DvdDatabase::Controller::Dvd::Record;

sub index_action {
    my( $self ) = @_;
    my $rs = $self->application->schema->resultset( 'Dvd' );
    return $self->render( template => 'list.tt', items => [ $rs->search ] );
}

sub create_action {
    my ( $self ) = @_;
    my $req = $self->request;

    my $form = DvdDatabase::Controller::Dvd::Form->new( 
        params => $req->parameters->as_hashref, 
        schema => $self->application->schema,
    );
    if( $req->method eq 'POST' && $form->process() ){
        my $record = $form->item;
        my $res = $req->new_response();
        $res->redirect( $self->self_url . 'record/' . $record->id . '/view' );
        return $res;
    }
    $form->field( 'submit' )->value( 'Create' );
    return $self->render( template => 'edit.tt', form => $form->render );
}

sub record_action {
    my( $self, $id, $action ) = @_;
    my $rs = $self->application->schema->resultset( 'Dvd' );
    my $record = $rs->find( $id );
    if( ! $record ) {
        my $res = $self->request->new_response(404);
        $res->content_type('text/plain');
        $res->body( 'No record with id: ' . $id );
        return $res;
    }
    return DvdDatabase::Controller::Dvd::Record->handle( 
        path => $action,
        application => $self->application,
        env => $self->env,
        self_url => $self->self_url . "record/$id/",
        record => $record,
    );
}



1;
