use Test::More;
use lib 't/lib';

use lib 'extensions/lib';
use WebNano::Renderer::TT;

my $renderer = WebNano::Renderer::TT->new( root => [ 't/data/tt2' ] );

my $out;
$renderer->render( template => 'some_template.tt', output => \$out );
is( $out, "tt2/some_template.tt\n" );

$renderer = WebNano::Renderer::TT->new( root => [ 't/data/tt1', 't/data/tt2' ] );
$out = '';
$renderer->render( template => 'some_template.tt', output => \$out );
is( $out, "tt1/some_template.tt\n" );
$out = '';
$renderer->render( template => 'second_root.tt', output => \$out );
is( $out, "tt2/second_root.tt\n" );

$out = '';
$renderer->render( template => 'template.tt', search_path => [ 'subdir1', 'subdir2' ], output => \$out );
is( $out, "tt1/subdir1/template.tt\n" );
$out = '';
$renderer->render( template => 'template.tt', search_path => [ 'subdir2' ], output => \$out );
is( $out, "tt1/subdir2/template.tt\n" );
$out = '';
$renderer->render( template => 'template1.tt', search_path => [ 'subdir1', 'subdir2' ], output => \$out );
is( $out, "tt1/subdir2/template1.tt\n" );

$out = '';
$renderer->render( template => 'second_root.tt', search_path => [ 'subdir1', 'subdir2' ], output => \$out );
is( $out, "tt2/subdir1/second_root.tt\n" );
$out = '';
$renderer->render( template => 'second_root.tt', search_path => [ 'subdir2' ], output => \$out );
is( $out, "tt2/subdir2/second_root.tt\n" );
$out = '';
$renderer->render( template => 'second_root1.tt', search_path => [ 'subdir1', 'subdir2' ], output => \$out );
is( $out, "tt2/subdir2/second_root1.tt\n" );

$renderer = WebNano::Renderer::TT->new( root => [ 't/data/tt1', 't/data/tt2' ], INCLUDE_PATH => 't/data/tt_globals' );
$out = '';
$renderer->render( template => 'include_global.tt', output => \$out );
is( $out, "t/data/tt_globals/some_global.tt\n\n" );



done_testing();

