package WebNano::Controller::CRUD;
use Moose;
use MooseX::MethodAttributes;
use Class::MOP;

extends 'WebNano::Controller';
with 'WebNano::Controller::CodeAttributesForMeta';

around 'handle' => sub {
    my( $orig, $self, @args ) = @_;

    if( defined $args[0] and $args[0] =~ /^\d+$/ ){
        my $id = shift @args;
        my $rs = $self->application->schema->resultset( $self->rs_name );
        my $record = $rs->find( $id );
        if( ! $record ) {
            my $res = $self->request->new_response(404);
            $res->content_type('text/plain');
            $res->body( 'No record with id: ' . $id );
            return $res;
        }
        my $rec_class = $self->record_controller_class;
        my $new_controller = $rec_class->new(
            application => $self->application,
            request => $self->request,
            self_url => $self->self_url . "$id/",
            record => $record,
        );
        return $new_controller->handle( @args );
    }
    return $self->$orig( @args );
};


sub index : Action {
    my( $self ) = @_;
    my $rs = $self->application->schema->resultset( $self->rs_name );
    return $self->render( 'list.tt', { items => [ $rs->search ] } );
}

sub create : Action {
    my ( $self ) = @_;
    my $req = $self->request;

    my $form_class = $self->form_class;
    warn $form_class;
    Class::MOP::load_class( $form_class );
    warn 'aaaaaaaaa';
    my $form = $form_class->new( 
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
    package WebNano::Controller::CRUD::Record;
    use Moose;
    use MooseX::MethodAttributes;

    extends 'WebNano::Controller';
    with 'WebNano::Controller::CodeAttributesForMeta';

    has record => ( isa => 'DBIx::Class::Row', is => 'ro' );

    sub index : Action {
        my ( $self ) = @_;

        return $self->view( );
    }

    sub view : Action {
        my ( $self ) = @_;

        return $self->render( 'record.tt', { record => $self->record } );
    }

    sub delete : Action {
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

    sub edit : Action {
        my $self = shift;
        my $req = $self->request;
        my $form_class = $self->form_class;
        warn $form_class;
        Class::MOP::load_class( $form_class );
        warn 'aaaaaaa';
        warn ref $self->record;
        $DB::single = 1;
        my $form = $form_class->new( 
            item   => $self->record,
            params => $req->params, 
        );
        warn 'bbbbbb';
        if( $req->method eq 'POST' && $form->process() ){
            my $res = $req->new_response();
            $res->redirect( $self->self_url . '/view' );
            return $res;
        }
        $form->field( 'submit' )->value( 'Update' );
        return $self->render( 'edit.tt', { form => $form->render } );
    }
}

1;
