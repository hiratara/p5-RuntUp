use inc::Module::Install;
name 'RuntUp';
all_from 'lib/RuntUp.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
