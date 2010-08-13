use strict;
use warnings;

package WebNano::FindController;
use Try::Tiny;
use Object::Tiny::RW;

sub find_nested {
    my( $self, $sub_path, $search_path ) = @_;
    $sub_path =~ s{::}{/};
    my $controller_class;
    my @path = @$search_path;
    for my $base ( @path ){
        $base =~ s{::}{/}g;
        my $controller_file = "$base/Controller$sub_path.pm";
        try{
            require $controller_file;
            $controller_class = $controller_file;
            $controller_class =~ s/.pm$//;
            $controller_class =~ s{/}{::}g;
        }
        catch {
            if( $_ !~ /Can't locate $controller_file in \@INC/ ){
                die $_;
            }
        };
    }
    return if !$controller_class;
    return if !$controller_class->isa( 'WebNano::Controller' );
    return $controller_class;
}

1;

