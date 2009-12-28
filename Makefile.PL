use inc::Module::Install;

name     'WebNano';
all_from 'lib/WebNano.pm';
author   q{Zbigniew Łukasiak <zby@cpan.org>};
license  'perl';

requires 'Moose';
requires 'Plack::Request';
requires 'Scalar::Util';
requires 'Class::MOP';

build_requires 'Test::More';

auto_install;

WriteAll;

