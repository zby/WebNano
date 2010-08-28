use strict;
use warnings;

package DvdDatabase::Controller::Dvd::Record;

use base 'WebNano::Controller';

use Object::Tiny::RW  'record';


sub index_action {
    my ( $self ) = @_;

    return $self->view_action( );
}

sub view_action {
    my ( $self ) = @_;

    return $self->render( 'record.tt', { record => $self->record } );
}

sub delete_action {
    my ( $self ) = @_;
    my $record = $self->record;
    if( $self->request->method eq 'GET' ){
        return $self->render( 'delete.tt', { record => $record } );
    }
    else{
        $record->delete;
        my $res = $self->request->new_response();
        $res->redirect( $self->self_url );
        return $res;
    }
}

sub edit_action {
    my $self = shift;
    my $req = $self->request;
    my $form = DvdDatabase::Controller::Dvd::Form->new( 
        item   => $self->record,
        params => $req->parameters->as_hashref, 
    );
    if( $req->method eq 'POST' && $form->process() ){
        my $res = $req->new_response();
        $res->redirect( $self->self_url . '/view' );
        return $res;
    }
    $form->field( 'submit' )->value( 'Update' );
    return $self->render( 'edit.tt', { form => $form->render } );
}

1;

