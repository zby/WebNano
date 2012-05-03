use strict;
use warnings;

package DvdDatabase::Controller::DvdSimpleUrl_HandlerOv;
use Moose;
use MooseX::NonMoose;

extends 'WebNano::Controller';

use DvdDatabase::Controller::Dvd::Form;
use DvdDatabase::Controller::Dvd::Record;

sub handle {
    my ( $class, %args ) = @_;
    my @path = @{ $args{path} };
    my $id = $path[0];
    if( $id && $id =~ /^\d+$/ ){
        my $rs = $args{app}->schema->resultset( 'Dvd' );
        my $record = $rs->find( $id );
        if( ! $record ) {
            my $res = Plack::Response->new(404);
            $res->content_type('text/plain');
            $res->body( 'No record with id: ' . $id );
            return $res;
        }
        return DvdDatabase::Controller::Dvd::Record->handle( 
            %args,
            path => [ @path[ 1 .. $#path ] ],
            self_url => $args{self_url} . "$id/",
            record => $record,
        );
    }
    my $self = $class->new( %args );
    return $self->local_dispatch();
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
