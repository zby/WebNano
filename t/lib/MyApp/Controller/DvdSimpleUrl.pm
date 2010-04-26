package MyApp::Controller::DvdSimpleUrl;
use Moose;

extends 'WebNano::Controller';

use MyApp::Controller::Dvd::Form;

has record_methods => ( 
    is => 'ro', 
    isa => 'HashRef', 
    default => sub { { view => 1, 'delete' => 1, edit => 1 } }
);

around 'local_dispatch' => sub {
    my( $orig, $self, $path) = @_;
    my( $id, $method, @args ) = split qr{/}, $path;
    $method ||= 'view';
    if( $id && $id =~ /^\d+$/ && $self->record_methods->{ $method } ){
        my $rs = $self->application->schema->resultset( 'Dvd' );
        my $record = $rs->find( $id );
        if( ! $record ) {
            my $res = $self->request->new_response(404);
            $res->content_type('text/plain');
            $res->body( 'No record with id: ' . $id );
            return $res;
        }
        return $self->$method( $record, @args );
    }
    return $self->$orig( $path );
};

sub index_action {
    my( $self ) = @_;
    my $rs = $self->application->schema->resultset( 'Dvd' );
    return $self->render( 'list.tt', { items => [ $rs->search ] } );
}

sub create_action {
    my ( $self ) = @_;
    my $req = $self->request;

    my $form = MyApp::Controller::Dvd::Form->new( 
        params => $req->params, 
        schema => $self->application->schema,
    );
    if( $req->method eq 'POST' && $form->process() ){
        my $record = $form->item;
        my $res = $req->new_response();
        $res->redirect( $self->self_url . 'record/' . $record->id . '/view' );
        return $res;
    }
    $form->field( 'submit' )->value( 'Create' );
    return $self->render( 'edit.tt', { form => $form->render } );
}

sub view {
    my ( $self, $record ) = @_;

    return $self->render( 'record.tt', { record => $record } );
}

sub delete {
    my ( $self, $record ) = @_;
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

sub edit {
    my ( $self, $record ) = @_;
    my $req = $self->request;
    my $form = MyApp::Controller::Dvd::Form->new( 
        item   => $record,
        params => $req->params, 
    );
    if( $req->method eq 'POST' && $form->process() ){
        my $res = $req->new_response();
        $res->redirect( $self->self_url . '/' . $record->id . '/view' );
        return $res;
    }
    $form->field( 'submit' )->value( 'Update' );
    return $self->render( 'edit.tt', { form => $form->render } );
}

1;

