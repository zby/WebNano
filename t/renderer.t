use strict;
use warnings;

use Test::More;
use lib 't/lib';
use WebNano::Renderer::TTiny;
use WebNano::Controller;

{
    package WebNano::Controller::Book;
    use base 'WebNano::Controller';
    sub template_search_path { [ 'Product' ] }
}

my $c = WebNano::Controller->new();
my $renderer = WebNano::Renderer::TTiny->new( root => 't/data/templates' );
my $rendered = $renderer->render( c => $c, template => 'dummy_template', some_var => 'some value' );
ok( $rendered =~ /some_var: some value/, 'vars' );
ok( $rendered =~ /^Some text/, 'Slurping template file' );

$c = WebNano::Controller::Book->new();
like( 
    $renderer->render( c => $c, template => 'third_template', some_var => 'some value' ),
    qr/This is template for Book/ 
);

my $static_renderer = WebNano::Renderer::TTiny->new( INCLUDE_PATH => 't/data/templates' );
like( 
    $static_renderer->render( c => $c, template => 'Book/third_template', some_var => 'some value' ),
    qr/This is template for Book/ 
);


done_testing();
