# ============
package Mojar::Util;
# ============
use Mojo::Base 'Exporter';

our @EXPORT_OK = (qw(
  detitlecase dumper hash_or_hashref spurt titlecase transcribe
));

use Scalar::Util ();  # reftype

# ------------
# Public functions
# ------------

sub detitlecase {
  my ($string, $syllable_sep, $do_camelcase) = @_;
  $syllable_sep //= '_';
  return undef unless defined $string;
  
  my @words;
  # Absorb any leading lowercase chars
  push @words, $1 if $string =~ s/^([^A-Z]+)//;
  # Absorb each titlecase substring
  push @words, lcfirst $1 while $string =~ s/\A([A-Z][^A-Z]*)//;
  return join $syllable_sep, @words;
}

sub titlecase {
  my ($string, $separator, $do_camelcase) = @_;
  $separator //= '_';
  return undef unless defined $string;
  
  my @words;
  # Absorb any leading separators
  push @words, $1 if $string =~ s/\A(\Q$separator\E+)//;
  # Absorb any leading component if doing camelcase
  if ($do_camelcase and $string =~ s/\A([^\Q$separator\E]+)\Q$separator\E?//) {
    push @words, $1;
    push @words, $1 if $string =~ s/\A(\Q$separator\E+)//;
  }
  # Absorb each substring as titlecase
  while ($string =~ s/\A([^\Q$separator\E]+)\Q$separator\E?//) {
    push @words, ucfirst lc $1;
    push @words, $1 if $string =~ s/\A(\Q$separator\E+)//;
  }
  # Fix any trailing separators
  $words[-1] .= $separator if @words && $words[-1] =~ /\A\Q$separator\E/;
  return join '', @words;
}

sub transcribe {
  my $string = shift;
  my $translator = pop if ref $_[-1] eq 'CODE';
  return undef unless defined $string;

  my $parts = [ $string ];  # arrayref tree with strings at leaves
  my @joiners = ();  # joining string for each level
  my @level_parts = ( $parts );  # array of arrayrefs, each containing a string
  my @next_level_parts = ();  # array of arrayrefs, each containing a string
  my ($old, $new);
  while (($old, $new) = (shift, shift) and defined $new) {
    push @joiners, $new;
    foreach my $p (@level_parts) {
      # $p is arrayref containing a string
      my @components = split /\Q$old/, $p->[0], -1;
      # Modify $parts tree
      @$p = map [ $_ // '' ], @components;
      # $p is arrayref containing arrayrefs, each containing a string
      # Set up next level
      push @next_level_parts, @$p;
    }
    @level_parts = @next_level_parts;
    @next_level_parts = ();
  }
  while ($translator and my $p = shift @level_parts) {
    $p->[0] = $translator->($p->[0]);
  }

  my @traverse = ( [0, $parts] );
  while (my $next = pop @traverse) {
    my ($depth, $ref) = @$next[0,1];
    if (ref $$ref[0]) {
      if (my @deeper = grep ref($_->[0]), @$ref) {
        # Found some children not ready to be joined
        push @traverse, [$depth, $ref], map [$depth + 1, $_], @deeper;
      }
      else {
        # Children all strings => join them
        @$ref = join $joiners[$depth], map +($_->[0] //= ''), @$ref;
      }
    }
    # else string => do nothing
  }

  return $parts->[0] // '';
}

sub spurt {
  my ($path, @content) = @_;
  die qq{Can't open file "$path": $!} unless open my $file, '>', $path;
  my $string = join '', @content;
  die qq{Can't write to file "$path": $!} unless $file->syswrite($string);
  return $string;
}

sub hash_or_hashref {
  return { @_ } if @_ % 2 == 0;  # hash
  return $_[0] if ref $_[0] eq 'HASH' || Scalar::Util::reftype $_[0] eq 'HASH';
  require Carp;
  Carp::croak(sprintf 'Hash not identified (%s)', join ',', @_);
}

sub dumper {
  my ($arg, $level) = (@_ > 1) ? ([ @_ ], 1) : (shift, undef);
  require Data::Dumper;
  my $dump = Data::Dumper::Dumper($arg);
  $dump =~ s/^\$VAR1 = //;
  $dump =~ s/;\n\z//;
  $dump =~ s/^\s{8}//mg;
  $dump =~ s/\$VAR1/TOP/g;
  if ($level) {
    $dump =~ s/^\[\s//;
    $dump =~ s/\n\s*\]$//;
    $dump =~ s/^\s{2}//mg;
  }
  return $dump;
}

1
__END__

=head1 NAME

Mojar::Util - General utility functions

=head1 SYNOPSIS

  use Mojar::Util 'transcribe';

  my $replaced = transcribe $original, '_' => '-', '-' => '_';

=head1 DESCRIPTION

Miscellaneous utility functions.

=head1 FUNCTIONS

=head2 C<detitlecase>

  my $snakecase = detitlecase $titlecase;
  my $snakecase = detitlecase $titlecase => $separator;

Convert title-case string to hyphenated lowercase.

  # "foo-bar"
  detitlecase 'FooBar' => '-';

  # "foo-bar::baz"
  detitlecase 'FooBar::Baz' => '-';

  # "i_foo_bar"
  detitlecase 'iFooBar';

=head2 C<titlecase>

  my $titlecase = titlecase $snakecase;
  my $titlecase = titlecase $snakecase => $separator;
  my $titlecase = titlecase $snakecase => $separator, $do_camelcase;

Convert snake-case string to hyphenated lowercase, with optional additional translations.

  # "FooBar"
  titlecase 'foo_bar';

  # "FooBar"
  titlecase 'foo-bar' => '-';

  # "fooBar"
  titlecase 'foo_bar' => undef, 1;

  # "FooBar_Baz"
  titlecase 'foo-bar_baz' => '-';

  # 'iFooBar';
  titlecase i_foo_bar => undef, 1;

=head2 C<transcribe>

  my $template_base = transcribe $url_path, '/' => '_';

  my $controller_class =
      transcribe $url_path, '/' => '::', sub { titlecase $_[0] => '-' };

  my $with_separators_swapped = transcribe $string, '_' => '-', '-' => '_';

=head2 C<spurt>

  my $written_string = spurt $path, @content;

  spurt '/tmp/test.txt', "Some\ntext\n";
  spurt '/tmp/test.txt', "More\n", "text\n";  # overwrites previous content

Similar to L<Mojo::Util>::spurt but with opposite argument order and accepting
list of content.  If passed a list, it joins the parts together before writing.

  ->syswrite(join '', @content)

=head2 C<dumper>

  say dumper $object;
  print dumper($object), "\n";
  $log->debug(dumper $hashref, $arrayref, $string, $numeric);

Based on Data::Dumper it is simply a tidied (post-processed) version.  It is
argument-greedy and if passed more than one argument will wrap them in an
arrayref and then later strip away that dummy layer.  In the resulting string,
"TOP" refers to the top-most (single, possibly invisible) entity.

=head2 C<hash_or_hashref>

  my $hashref = hash_or_hashref({ A => 1, B => 2 });
  my $hashref = hash_or_hashref($object);
  my $hashref = hash_or_hashref(A => 1, B => 2);
  my $hashref = hash_or_hashref();

Takes care of those cases where you want to handle hashes or hashrefs.  Always
gives a hashref if it can, otherwise dies.

=head1 RATIONALE

Mojo::Util is packed with useful functions, but I kept hitting occasions when I
needed to transcribe characters in the result or apply my own de/titlecase.
With the functions here I get to use Mojo::Util more widely but I also find
these useful independently.

=head1 SEE ALSO

L<Mojo::Util>, L<String::Util>, L<Data::Dump>.

=cut
