use lib 't/lib';

use MyApp;
my $app = MyApp->new();
$app->psgi_callback;


