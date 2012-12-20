use Mojo::Base -strict;
use Test::More;

use_ok 'Mojar';
diag "Testing Mojar $Mojar::VERSION, Perl $], $^X";
use_ok 'Mojar::Util';
use_ok 'Mojar::Cache';

done_testing();
