use strict;
use warnings;

package WebNano::FindController;

use Exporter 'import';
our @EXPORT_OK = qw(find_nested); 

use Class::Load 'try_load_class';

sub find_nested {
    my( $sub_path, $search_path ) = @_;
    return if $sub_path =~ /\./;
    $sub_path =~ s{/}{::}g;
    my @path = @$search_path;
    for my $base ( @path ){
        my $controller_class = $base . '::Controller' . $sub_path;
        if( ! try_load_class( $controller_class ) ){
            my $file = $controller_class;
            $file =~ s{::}{/}g;
            $file .= '.pm';
            if( $Class::Load::ERROR !~ /Can't locate \Q$file\E in \@INC/ ){
                die $Class::Load::ERROR;
            }
        };
        return $controller_class if $controller_class->isa( 'WebNano::Controller' );
    }
    return;
}

1;

__END__

# ABSTRACT: Tool for finding controller classes

=head2 find_nested

