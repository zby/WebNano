use SubClassApp;
my $app = SubClassApp->new( DEBUG => 1 );
$app->psgi_callback;


