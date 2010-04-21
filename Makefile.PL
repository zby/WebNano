use inc::Module::Install;

name     'WebNano';
all_from 'lib/WebNano.pm';
author   q{Zbigniew Łukasiak <zby@cpan.org>};
license  'perl';

requires 'Moose';
requires 'Any::Moose';
requires 'Plack::Request';
requires 'Scalar::Util';
requires 'Class::MOP';
requires 'Plack::Test';
requires 'MooseX::MethodAttributes';
requires 'URI::Escape';
requires 'Try::Tiny';

build_requires 'Test::More';
build_requires 'DBIx::Class';
build_requires 'Config::Any';
build_requires 'Config::General';
build_requires 'HTML::FormHandler';
build_requires 'HTML::FormHandler::Model::DBIC';

auto_install;

WriteAll;

