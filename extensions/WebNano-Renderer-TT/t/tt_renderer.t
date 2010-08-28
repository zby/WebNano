use Test::More;
use lib 't/lib';

use lib 'extensions/lib';
use WebNano::Renderer::TT;
{
    package TestController;
    use base 'WebNano::Controller';
    use Object::Tiny::RW 'template_search_path';
}

my $renderer = WebNano::Renderer::TT->new( root => [ 't/data/tt2' ] );

my $out = $renderer->render( template => 'some_template.tt' );
is( $out, "tt2/some_template.tt\n" );

$renderer = WebNano::Renderer::TT->new( root => [ 't/data/tt1', 't/data/tt2' ] );
$out = $renderer->render( template => 'some_template.tt' );
is( $out, "tt1/some_template.tt\n" );
$out = $renderer->render( template => 'second_root.tt' );
is( $out, "tt2/second_root.tt\n" );

my $c = TestController->new( self_path => 'subdir1', template_search_path => [ 'subdir2' ] );
$out = $renderer->render( c => $c, template => 'template.tt' );
is( $out, "tt1/subdir1/template.tt\n" );
my $c = TestController->new( self_path => 'subdir2' );
$out = $renderer->render( c => $c, template => 'template.tt' );
is( $out, "tt1/subdir2/template.tt\n" );
my $c = TestController->new( self_path => 'subdir1', template_search_path => [ 'subdir2' ] );
$out = $renderer->render( c => $c, template => 'template1.tt' );
is( $out, "tt1/subdir2/template1.tt\n" );

$out = $renderer->render( c => $c, template => 'second_root.tt' );
is( $out, "tt2/subdir1/second_root.tt\n" );
my $c = TestController->new( self_path => 'subdir2' );
$out = $renderer->render( c => $c, template => 'second_root.tt' );
is( $out, "tt2/subdir2/second_root.tt\n" );
my $c = TestController->new( self_path => 'subdir1', template_search_path => [ 'subdir2' ] );
$out = $renderer->render( c => $c, template => 'second_root1.tt' );
is( $out, "tt2/subdir2/second_root1.tt\n" );

$renderer = WebNano::Renderer::TT->new( root => [ 't/data/tt1', 't/data/tt2' ], INCLUDE_PATH => 't/data/tt_globals' );
$out = $renderer->render( template => 'include_global.tt' );
is( $out, "t/data/tt_globals/some_global.tt\n\n" );



done_testing();

