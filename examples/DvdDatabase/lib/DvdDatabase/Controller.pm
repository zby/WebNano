use strict;
use warnings;

package DvdDatabase::Controller;

use base 'WebNano::Controller';

sub index_action {
    my $self = shift;
    my $res = $self->request->new_response();
    $res->redirect( '/Dvd/' );
    return $res;
}

sub session_check_action {
    my $self = shift;
    my $session = $self->env->{'psgix.session'};
    return "Hello, you've been here for ". ( 1 + $session->{counter}++ ). "th time!";
}

sub user_action {
    my $self = shift;
    return "Current user is " . $self->env->{user}->username if $self->env->{user};
    return "No user logged in";
}


1;

