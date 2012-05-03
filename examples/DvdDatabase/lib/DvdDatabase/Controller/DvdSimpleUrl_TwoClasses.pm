use strict;
use warnings;

package DvdDatabase::Controller::DvdSimpleUrl_TwoClasses;
use Moose;
use MooseX::NonMoose;

extends 'WebNano::Controller';

use DvdDatabase::Controller::Dvd::Form;
use DvdDatabase::Controller::Dvd::Record;


around 'local_dispatch' => sub {
    my( $orig, $self ) = @_;
    my( $id, @args ) = @{ $self->path };
    if( $id && $id =~ /^\d+$/ ){
        my $rs = $self->app->schema->resultset( 'Dvd' );
        my $record = $rs->find( $id );
        if( ! $record ) {
            my $res = $self->req->new_response(404);
            $res->content_type('text/plain');
            $res->body( 'No record with id: ' . $id );
            return $res;
        }
        return DvdDatabase::Controller::Dvd::Record->handle( 
            path => [ @args ],
            app => $self->app,
            env => $self->env,
            self_url => $self->self_url . "$id/",
            record => $record,
        );
    }
    return $self->$orig();
};


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
        $res->redirect( $self->self_url . 'record/' . $record->id . '/view' );
        return $res;
    }
    $form->field( 'submit' )->value( 'Create' );
    return $self->render( template => 'edit.tt', form => $form->render );
}



1;
