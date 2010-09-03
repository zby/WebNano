package WebNano::Controller::CRUD;
use Moose;
use MooseX::NonMoose;
use Class::MOP;

extends 'WebNano::Controller';

has record_controller_class => ( is => 'ro', isa => 'Str', required => 1, default => 'WebNano::Controller::CRUD::Record' );
has form_class => ( is => 'ro', isa => 'Str', required => 1 );
has rs_name => ( is => 'ro', isa => 'Str', required => 1 );

has record_actions => ( 
    is => 'ro', 
    isa => 'HashRef', 
    default => sub { { view => 1, 'delete' => 1, edit => 1 } }
);

has class_actions => ( 
    is => 'ro', 
    isa => 'HashRef', 
    default => sub { { list => 1, create => 1 } }
);

around 'local_dispatch' => sub {
    my( $orig, $self, $path_part, $method, @args ) = @_;
    $method ||= 'view';
    warn "$path_part, $method, @args";
    if( $path_part && $path_part =~ /^\d+$/ && $self->record_actions->{ $method } ){
        my $id = $path_part;
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
    if( defined $path_part && $self->class_actions->{$path_part} ){
        return $self->$path_part( $method, @args );
    }
    return $self->$orig( $path_part, $method, @args );
};


sub list {
    my( $self ) = @_;
    my $rs = $self->application->schema->resultset( $self->rs_name );
    return $self->render( template => 'list.tt', items => [ $rs->search ] );
}

sub create {
    my ( $self ) = @_;
    my $req = $self->request;

    my $form_class = $self->form_class;
    Class::MOP::load_class( $form_class );
    my $form = $form_class->new( 
        params => $req->parameters->as_hashref, 
        schema => $self->application->schema,
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

    return $self->render( template => 'record.tt', record => $record );
}

sub delete {
    my ( $self, $record ) = @_;
    if( $self->request->method eq 'GET' ){
        return $self->render( template => 'delete.tt', record => $record );
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
    my $form_class = $self->form_class;
    Class::MOP::load_class( $form_class );
    my $form = $form_class->new( 
        item   => $record,
        params => $req->parameters->as_hashref, 
    );
    if( $req->method eq 'POST' && $form->process() ){
        my $res = $req->new_response();
        $res->redirect( $self->self_url . $record->id . '/view' );
        return $res;
    }
    $form->field( 'submit' )->value( 'Update' );
    return $self->render( template => 'edit.tt', form => $form->render );
}

1;

__END__

=head1 NAME

WebNano::Controller::CRUD - A base controller implementing CRUD operations

=head1 SYNOPSIS

use base 'WebNano::Controller::CRUD';


