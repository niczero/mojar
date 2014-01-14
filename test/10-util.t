use Mojo::Base -strict;
use Test::More;

use File::Temp 'tempdir';
use File::Spec::Functions 'catfile';
use Mojar::Util qw(dumper hash_or_hashref spurt snakecase unsnakecase
    transcribe);
use Mojo::Util 'slurp';

subtest q{snakecase} => sub {
  is +(snakecase 'FooBar'), 'foo_bar', 'FooBar';
  is +(snakecase 'fooBar'), 'foo_bar', 'fooBar';
  is +(snakecase 'BBC'), 'b_b_c', 'BBC';
  is +(snakecase 'TEAM_GB'), 't_e_a_m_g_b', 'TEAM_GB';
};

subtest q{unsnakecase} => sub {
  is +(unsnakecase 'FooBar'), 'Foobar', 'FooBar';
  is +(unsnakecase 'foobar'), 'Foobar', 'foobar';
  is +(unsnakecase 'foo_bar'), 'FooBar', 'foo_bar';
  is +(unsnakecase '__foo_bar__'), '__FooBar__', 'foo_bar';
  is +(unsnakecase 'foo.bar', '.'), 'FooBar', 'foo.bar';
  is +(unsnakecase '-foo_bar'), '-fooBar', '-foo_bar';
  is +(unsnakecase 'foo-bar', '-'), 'FooBar', q{foo-bar & '-'};
  is +(unsnakecase '--foo-bar', '-'), '--FooBar', q{--foo-bar & '-'};
  is +(unsnakecase 'foo', undef, 1), 'foo', 'foo & camelcase';
  is +(unsnakecase 'foo_bar_baz', undef, 1), 'fooBarBaz',
      'foo_bar_baz & camelcase';
  is +(unsnakecase 't_e_a_m__g_b'), 'TEAM_GB', 'TEAM_GB';
};

subtest q{Round trip} => sub {
  d_t('foo_bar');
  d_t('bbc');
  d_t('en-gb');
  t_d('BBC');
  t_d('Bbc');
#  t_d('TEAM_USA');  # Does not round trip
};

subtest q{transcribe} => sub {
  is +(transcribe 'abc', '_' => '-', '::' => '/'), 'abc', q{nothing to do};
  is +(transcribe '', '_' => '-'), '', q{empty string};
  ok !(defined transcribe undef, '_' => '-'), q{undef};

  is +(transcribe 'admin_profile-perm_edit', '_' => '-', '-' => '_'),
    'admin-profile_perm-edit', q{swap separators};

  is +(transcribe 'a__b__c', '_' => '-'), 'a--b--c', q{doubled separator};
  is +(transcribe 'a__$__c', '$' => '£', '_' => '-'), 'a--£--c',
      q{doubled sep incl sep};
  is +(transcribe 'a__$__c', '_' => '-', '$' => '£'), 'a--£--c',
      q{doubled sep incl sep with diff order};
  is +(transcribe 'a.c..', '.' => '*'), 'a*c**', q{sep at end};
  is +(transcribe 'a::b_c_d::e::f::g_h', '_' => '-', '::' => '/'), 'a/b-c-d/e/f/g-h', q{'_' => '-'};

  is +(transcribe '__abc_def__', '_' => '-', sub { unsnakecase $_[0] }),
      '--Abc-Def--', q{with translator (unsnakecase)};
  is +(transcribe '__AbcDef__', '_' => '-', sub { snakecase $_[0], '-' }),
      '--abc-def--', q{with translator (snakecase)};
  is +(transcribe 'Pool::DbConnector::Mysql',
        '::' => '_',
        sub { snakecase $_[0], '-' }),
      'pool_db-connector_mysql', q{class -> file};
  is +(transcribe 'Model::DbConnector::Mysql',
        '::' => '/',
        sub { snakecase $_[0] }),
      'model/db_connector/mysql', q{class -> path};
  # And having fun, but not realistic...
  is +(transcribe 'admin/user/profile_perm?safe=1',
        '/' => '::', '?' => '::_', '=1' => '',
        sub { unsnakecase $_[0] }),
      'Admin::User::ProfilePerm::_Safe', q{url_path -> class};
};

subtest q{spurt} => sub {
  my $dir = tempdir CLEANUP => 1;
  my $path = catfile $dir, 'test.txt';
  ok !! spurt $path, "Some\ntext\n";
  is slurp($path), "Some\ntext\n", 'same text back';
  ok !! spurt $path, "More\n", "lines\n";
  is slurp($path), "More\nlines\n", 'same text back';
};

subtest q{dumper} => sub {
  is dumper(undef), "undef", 'undef';
  is dumper('Abc'), "'Abc'", 'string';
  is dumper(1.23), "'1.23'", 'numeric';
  is dumper({A => 1}), "{\n  A => 1\n}", 'simple hashref';
  my $abc = [qw(A B C)];
  is dumper($abc), "[\n  'A',\n  'B',\n  'C'\n]", 'simple arrayref';
  my $abc_r = \$abc;
  is dumper($abc_r), "\\[\n    'A',\n    'B',\n    'C'\n  ]", 'arrayrefref';
  is dumper(\$abc_r), "\\\\[\n      'A',\n      'B',\n      'C'\n    ]",
      'arrayrefrefref';
  is dumper('Abc', $abc), "'Abc'\n[\n  'A',\n  'B',\n  'C'\n]", 'list';
};

subtest q{hash_or_hashref} => sub {
  is dumper(hash_or_hashref()), "{}", 'no args';
  is dumper(hash_or_hashref {A => 1}), "{\n  A => 1\n}", 'hashref';
  is dumper(hash_or_hashref B => 2), "{\n  B => 2\n}", 'hash';
  my $o = bless {} => 'UNIVERSAL';
  ok $o->isa('UNIVERSAL'), 'test object constructed ok';
  is_deeply hash_or_hashref($o), $o, 'object';
};

done_testing();

sub t_d {
  my $string = shift;
  is +(unsnakecase snakecase $string), $string, 't d '. $string;
}

sub d_t {
  my $string = shift;
  is +(snakecase unsnakecase $string), $string, 'd t '. $string;
}
