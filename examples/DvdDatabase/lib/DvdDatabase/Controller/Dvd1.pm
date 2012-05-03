package DvdDatabase::Controller::Dvd1;
use Moose;
use MooseX::NonMoose;

extends 'WebNano::Controller';

use DvdDatabase::Controller::Dvd::Form;

has record_methods => ( 
    is => 'ro', 
    isa => 'HashRef', 
    default => sub { { view_action => 1, 'delete_action' => 1, edit_action => 1 } }
);

sub record_action {
    my( $self, $id, $method, @args ) = @_;
    my $rs = $self->app->schema->resultset( 'Dvd' );
    my $record = $rs->find( $id );
    my @path = @{ $self->path };
    $self->path( [ $method, $record, @path[ 2 .. $#path ] ] );
    return $self->local_dispatch();
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
        $res->redirect( $self->self_url . 'record/' . $record->id . '/view' );
        return $res;
    }
    $form->field( 'submit' )->value( 'Create' );
    return $self->render( template => 'edit.tt', form => $form->render );
}

sub view_action {
    my ( $self, $record ) = @_;
    if( !$record || !blessed($record) ) {
        my $res = $self->req->new_response(404);
        $res->content_type('text/plain');
        $res->body( 'No record found' );
        return $res;
    }

    return $self->render( template => 'record.tt', record => $record );
}

sub delete_action {
    my ( $self, $record ) = @_;
    if( !$record || !blessed($record) ) {
        my $res = $self->req->new_response(404);
        $res->content_type('text/plain');
        $res->body( 'No record found' );
        return $res;
    }

    if( $self->req->method eq 'GET' ){
        return $self->render( record => $record );
    }
    else{
        $record->delete;
        my $res = $self->req->new_response();
        $res->redirect( $self->self_url );
        return $res;
    }
}

sub edit_action {
    my ( $self, $record ) = @_;
    if( !$record || !blessed($record) ) {
        my $res = $self->req->new_response(404);
        $res->content_type('text/plain');
        $res->body( 'No record found' );
        return $res;
    }

    my $req = $self->req;
    my $form = DvdDatabase::Controller::Dvd::Form->new( 
        item   => $record,
        params => $req->parameters->as_hashref, 
    );
    if( $req->method eq 'POST' && $form->process() ){
        my $res = $req->new_response();
        $res->redirect( $self->self_url . '/' . $record->id . '/view' );
        return $res;
    }
    $form->field( 'submit' )->value( 'Update' );
    return $self->render( form => $form->render );
}

1;

