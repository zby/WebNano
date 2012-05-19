           {
               package MyApp;
               use base 'WebNano';
               1;
           }

           {
               package MyApp::Controller;
               use base 'WebNano::Controller';

               sub index_action {
                   my $self = shift;
                   return 'This is my home';
               }
               1;
           }

           my $app = MyApp->new();
           $app->psgi_callback;
