use inc::Module::Install;

name     'WebNano';
all_from 'lib/WebNano.pm';
author   q{Zbigniew Łukasiak <zby@cpan.org>};
license  'perl';

requires 'Object::Tiny::RW';
requires 'Plack' => 0.9938;
requires 'Plack::Request';
requires 'Scalar::Util';
requires 'Plack::Test';
requires 'URI::Escape';
requires 'Try::Tiny';
requires 'Template::Tiny';

build_requires 'Test::More';
build_requires 'Config::Any';
build_requires 'Config::General';

auto_install;

WriteAll;

