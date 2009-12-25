use inc::Module::Install;
name 'RuntUp';
all_from 'lib/RuntUp.pm';
readme_from 'lib/RuntUp.pm';

requires  'Any::Moose';
requires  'File::HomeDir';
requires  'YAML::Syck';
requires  'File::Spec';
recommends 'Mouse';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
