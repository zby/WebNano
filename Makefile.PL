use inc::Module::Install;

name     'WebNano';
all_from 'lib/WebNano.pm';
author   q{Zbigniew Łukasiak <zby@cpan.org>};
license  'perl';

requires 'Moose';
requires 'Plack::Request';
requires 'Scalar::Util';
requires 'Class::MOP';
requires 'Plack::Test';
requires 'Config::Any';
requires 'Bread::Board';
requires 'DBIx::Class';
#requires 'Path::Router';
requires 'Config::General';
requires 'HTML::FormHandler';
requires 'HTML::FormHandler::Model::DBIC';
requires 'MooseX::MethodAttributes';

build_requires 'Test::More';

auto_install;

WriteAll;

