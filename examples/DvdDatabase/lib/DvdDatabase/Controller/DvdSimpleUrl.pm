package DvdDatabase::Controller::DvdSimpleUrl;
use Moose;
use MooseX::NonMoose;

extends 'WebNano::Controller';

use DvdDatabase::Controller::Dvd::Form;

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
        my $rs = $self->app->schema->resultset( 'Dvd' );
        my $record = $rs->find( $id );
        if( ! $record ) {
            my $res = $self->req->new_response(404);
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
    my ( $self, $record ) = @_;

    return $self->render( record => $record );
}

sub delete {
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

sub edit {
    my ( $self, $record ) = @_;
    my $req = $self->req;
    my $form = DvdDatabase::Controller::Dvd::Form->new( 
        item   => $record,
        params => $req->parameters->as_hashref, 
    );
    if( $req->method eq 'POST' && $form->process() ){
        my $res = $req->new_response();
        $res->redirect( $self->self_url . $record->id . '/view' );
        return $res;
    }
    $form->field( 'submit' )->value( 'Update' );
    return $self->render( form => $form->render );
}

1;

