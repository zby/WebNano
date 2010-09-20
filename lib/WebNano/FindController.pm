use strict;
use warnings;

package WebNano::FindController;
use Try::Tiny;
use Object::Tiny::RW;

sub find_nested {
    my( $self, $sub_path, $search_path ) = @_;
    return if $sub_path =~ /\./;
    $sub_path =~ s{/}{::}g;
    my @path = @$search_path;
    for my $base ( @path ){
        my $controller_class = $base . '::Controller' . $sub_path;
        eval "require $controller_class";
        if( $@ ){
            my $file = $controller_class;
            $file =~ s{::}{/}g;
            $file .= '.pm';
            if( $@ !~ /Can't locate \Q$file\E in \@INC/ ){
                die $@;
            }
        };
        return $controller_class if $controller_class->isa( 'WebNano::Controller' );
    }
    return;
}

1;

__END__

=head2 find_nested

