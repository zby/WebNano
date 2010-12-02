package DvdDatabase::Controller::Dvd2;
use Moose;
use MooseX::NonMoose;

extends 'WebNano::Controller';

use DvdDatabase::Controller::Dvd::Form;

around 'local_dispatch' => sub {
    my( $orig, $self, $path, $id, $method, @args ) = @_;
    if( defined $path && $path eq 'record' ){
        my $rs = $self->app->schema->resultset( 'Dvd' );
        my $record = $rs->find( $id );
        if( ! $record ) {
            my $res = $self->req->new_response(404);
            $res->content_type('text/plain');
            $res->body( 'No record with id: ' . $id );
            return $res;
        }
        unshift @args, $record;
        return $self->$orig( $method, @args );
    }
    if( defined $path && $path =~ m{^(view|edit|delete)} ){
        my $res = $self->req->new_response(404);
        $res->content_type('text/plain');
        $res->body( 'No page found' );
        return $res;
    }
    return $self->$orig( $path, $id, $method, @args );
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

sub view_action {
    my ( $self, $record ) = @_;

    return $self->render( record => $record );
}

sub delete_action {
    my ( $self, $record ) = @_;
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

