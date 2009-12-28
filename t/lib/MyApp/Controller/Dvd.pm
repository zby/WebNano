package MyApp::Controller::Dvd;
use Moose;
extends 'WebNano::Controller';

has valid_actions => ( is => 'ro', default => sub { qr/delete|edit|view/ } );

sub serve_index {
    my( $self ) = @_;
    my $rs = $self->application->schema->resultset( 'Dvd' );
    return $self->render( 'list.tt', { items => [ $rs->search ] } );
}

sub serve_record {
    my( $self, $id, $action ) = @_;
    my $rs = $self->application->schema->resultset( 'Dvd' );
    my $record = $rs->find( $id );
    if( ! $record ) {
        my $res = $self->request->new_response(404);
        $res->content_type('text/plain');
        $res->body( 'No record with id: ' . $id );
        return $res;
    }
    $action ||= 'view';
    if( $action =~ $self->valid_actions ){
        return $self->$action( $record );
    }
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

    my $form = DvdForm->new( 
        item   => $record,
        params => $req->params, 
    );
    if( $req->method eq 'POST' && $form->process() ){
        my $res = $req->new_response();
        $res->redirect( $self->self_url . 'record/' . $record->id . '/view' );
        return $res;
    }
    $form->field( 'submit' )->value( 'Update' );
    return $self->render( 'edit.tt', { form => $form->render } );
}

sub serve_create {
    my ( $self ) = @_;
    my $req = $self->request;

    my $form = DvdForm->new( 
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

{
    package DvdForm;
    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler::Model::DBIC';
    with 'HTML::FormHandler::Render::Simple';

    use DateTime;


    has '+item_class' => ( default => 'Dvd' );

    has_field 'tags' => ( type => 'Select', multiple => 1 );
    has_field 'hour' => ( type => 'Text', );
    has_field 'alter_date' => ( 
            type => 'Compound',
            apply => [
                {
                    transform => sub{ DateTime->new( $_[0] ) },
                    message => "Not a valid DateTime",
                }
            ],
        );
    has_field 'alter_date.year';        has_field 'alter_date.month';        has_field 'alter_date.day';
    has_field 'creation_date' => ( 
            type => 'Compound',
            apply => [
                {
                    transform => sub{ DateTime->new( $_[0] ) },
                    message => "Not a valid DateTime",
                }
            ],
        );
    has_field 'creation_date.year';        has_field 'creation_date.month';        has_field 'creation_date.day';
    has_field 'imdb_id' => ( type => 'Text', );
    has_field 'name' => ( type => 'TextArea', );
    has_field 'owner' => ( type => 'Select', );
    has_field 'current_borrower' => ( type => 'Select', );
    has_field 'submit' => ( widget => 'submit' )
}

1;
