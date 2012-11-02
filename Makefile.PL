use 5.010_001;
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Mojar',
  VERSION_FROM => 'lib/Mojar.pm',
  ABSTRACT     => 'Extensions to Mojolicious',
  AUTHOR       => 'Nic Sandfield <niczero@cpan.org>',
  LICENSE      => 'artistic_2',
  META_MERGE   => {
    requires  => {perl => '5.010001', Mojolicious => '3.33'},
    resources => {
      homepage    => 'http://mojar.alwaysdata.com/',
      license     => 'http://www.opensource.org/licenses/artistic-license-2.0',
      repository  => 'http://github.com/niczero/mojar',
      bugtracker  => 'http://github.com/niczero/mojar/issues'
    },
    no_index => {directory => ['mod', 'test']}
  },
  EXE_FILES => [],
  test => {TESTS => 'test/*.t'}
);
