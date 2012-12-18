use Mojo::Base -strict;
use Test::More;
use Mojar::Cache;

my $cache = Mojar::Cache->new;

subtest q{API:Basic:get} => sub {
  $cache->set(foo => 'bar');
  is $cache->get('foo'), 'bar', 'right result';
  $cache->set(bar => 'baz');
  is $cache->get('foo'), 'bar', 'still right result for first';
  is $cache->get('bar'), 'baz', 'and right result for second';
  $cache->set(baz => 'yada');
  is $cache->get('bar'), 'baz',  'still right result for second';
  is $cache->get('baz'), 'yada', 'and right result for third';
  $cache->set(yada => 23);
  is $cache->get('baz'), 'yada', 'still right result for third';
  is $cache->get('yada'), 23,    'and right result for fourth';
};

$cache = Mojar::Cache->new;

subtest q{API:Basic:set} => sub {
  $cache->set(foo => 'bar');
  is $cache->get('foo'), 'bar',  'right result';
  $cache->set(bar => 'baz');
  is $cache->get('foo'), 'bar',  'still right result for first';
  is $cache->get('bar'), 'baz',  'and right result for second';
  $cache->set(baz => 'yada');
  is $cache->get('foo'), 'bar',  'still right result for first';
  is $cache->get('bar'), 'baz',  'still right result for second';
  is $cache->get('baz'), 'yada', 'and right result for third';
  $cache->set(yada => 23);
  is $cache->get('bar'), 'baz',  'still right result for second';
  is $cache->get('baz'), 'yada', 'still right result for third';
  is $cache->get('yada'), 23,    'and right result for fourth';
};

subtest q{API:Basic:remove} => sub {
  $cache->remove('bar');
  is $cache->get('bar'), undef,  'has been removed (from start)';
  $cache->remove('yada');
  is $cache->get('yada'), undef, 'has been removed (from end)';
  is $cache->get('baz'), 'yada', 'still right result';
};

#$cache = Mojar::Cache->new;

#subtest q{API:Basic:compute} => sub {
#  $cache->set(foo => 'Foo')->set(bar => 'Bar');
#  $cache->compute(foo => sub { 'M' . 'oo' });
#};

done_testing();
