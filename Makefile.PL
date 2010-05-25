use inc::Module::Install;

name     'WebNano';
all_from 'lib/WebNano.pm';
author   q{Zbigniew Łukasiak <zby@cpan.org>};
license  'perl';

requires 'Class::XSAccessor';
requires 'Plack' => 0.9938;
requires 'Plack::Request';
requires 'Scalar::Util';
requires 'Plack::Test';
requires 'URI::Escape';
requires 'Try::Tiny';
requires 'Template::Tiny';

build_requires 'Moose';
build_requires 'Any::Moose';
build_requires 'MooseX::NonMoose';
build_requires 'MooseX::MethodAttributes';
build_requires 'Class::MOP';
build_requires 'Test::More';
build_requires 'DBIx::Class';
build_requires 'Config::Any';
build_requires 'Config::General';
build_requires 'HTML::FormHandler';
build_requires 'HTML::FormHandler::Model::DBIC';

auto_install;

WriteAll;

