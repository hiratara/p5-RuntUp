use inc::Module::Install;
name 'RuntUp';
all_from 'lib/RuntUp.pm';
readme_from 'lib/RuntUp.pm';

requires  'Any::Moose';
requires  'File::HomeDir';
requires  'YAML::Syck';
requires  'File::Spec';
requires  'Net::OpenSSH';
recommends 'Mouse';

test_requires 'Test::More';
tests 't/*.t';
author_tests 'xt';

install_script 'bin/runtup';

auto_set_repository;
auto_include;
auto_install;
WriteAll;
