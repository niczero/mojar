# ============
package Mojar::Util;
# ============
use Mojo::Base 'Exporter';

our @EXPORT_OK = (qw(
  detitlecase titlecase transcribe hash_or_hashref
));

use Scalar::Util ();

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
        @$ref = join $joiners[$depth], map $_->[0], @$ref;
      }
    }
    # else string => do nothing
  }

  return $parts->[0] // '';
}

sub hash_or_hashref {
  return undef unless @_;
  return $_[0] if @_ == 1 && ref $_[0] eq 'HASH';  # hashref
  return { @_ } if @_ % 2 == 0;  # hash
  return $_[0] if @_ == 1 && Scalar::Util::reftype $_[0] eq 'HASH';  # obj
  die sprintf 'Hash not identified (%s)', join ',', @_;
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

=head1 RATIONALE

Mojo::Util is packed with useful functions, but I kept hitting occasions when I
needed to transcribe characters in the result or apply my own de/titlecase.
With the functions here I get to use Mojo::Util more widely but I also find them
useful independently.

=head1 SEE ALSO

L<Mojo::Util>, L<String::Util>.

=cut
