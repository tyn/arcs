package SNG::Pipe;

use strict;
use warnings;
use Exporter;
use Env qw(SNG_SEP SNG_SUBCMD);

our @ISA = qw(Exporter);
our @EXPORT_OK = qw();
our @EXPORT = qw();

sub new {
  my $cls = shift;
  my $me = bless
    { separator => $SNG_SEP || qq{\t}
    , eol => qq{\n}
    }, $cls;
  my $sep = $me->{separator};
  $me->{sepregex} = qr{\Q$sep};
  $me;
}

sub sepregex {
  (shift)->{sepregex};
}

sub split {
  my $me = shift;
  my $s = shift;
  return undef unless defined($s);
  split($me->sepregex, $s);
}

sub wtd_header {
  my $me = shift;
  my $k = shift;
  my $v = shift;
  if (defined($v)) {
    $me->{wtd_header}->{$k} = $v;
  } else {
    $me->{wtd_header}->{$k};
  }
}

sub separator {
  (shift)->{separator};
}
sub eol {
  (shift)->{eol};
}

sub encode_line {
  my $me = shift;
  $me->encode_vector(@_). $me->eol;
}

sub encode_vector {
  no warnings;
  my $me = shift;
  join($me->separator, @_);
}

sub begin {
  my $me = shift;
  chomp(my $magic = $me->{raw_magic} = <STDIN>);
  die "error: invalid magic: $magic while executing $SNG_SUBCMD" unless $magic =~ m{^WTD};

  $me->{raw_header} = '';
  $me->{wtd_header} = {};

  my $h;
  while (my $line = <STDIN>) {
    $me->{raw_header} .= $line;
    chomp(my $l = $line);
    last if ($l eq '');
    if ($line =~ m{^(.*?): (.*)$}) {
      $me->{wtd_header}->{$1} = $2;
    }
  }

  my %hh = %{$me->{wtd_header}};
  $me->{wtd_header_in} = \%hh;

  $me->{header} = {};
  my $i=0;
  $me->{header}->{$_} = $i++ foreach ($me->header);
}

sub default {
  my $h = shift;
  my $k = shift;
  if (defined($h->{$k})) {
    $h->{$k};
  } else {
    '';
  }
}

sub decode {
  my $me = shift;
  (my $l = shift) =~ s{[\r\n]*$}{};
  my @as = $me->split($l);
  my %hh = map {
    if (defined($me->{header}->{$_})) {
      $_ => $as[$me->{header}->{$_}]
    } else {
      $_ => undef;
    }
  } $me->header;
  return \%hh;
}

sub header {
  my $me = shift;
  $me->split($me->wtd_header(q{Columns}));
}

sub export {
  my $me = shift;
  print $me->{raw_magic};
  die "error: invalid state: export() is called before begin().\n"
    unless defined ($me->{header});
  my @hs = (@_ > 0) ? @_ : $me->header;
  $me->{actual_header} = \@hs;
  $me->wtd_header('Column-Separator',
    unpack("H*", $me->separator));
  $me->wtd_header('Columns', $me->encode_vector(@hs));
  while (my ($k, $v) = each %{$me->{wtd_header}}) {
    print qq{$k: $v}, $me->eol;
  }
  print qq{}, $me->eol;
}

sub put {
  my $me = shift;
  my $h = shift;
  die "error: invalid state: put() is called before export().\n"
    unless defined ($me->{actual_header});

  $me->shipout(map {
    $h->{$_}
  } @{$me->{actual_header}});
}

sub shipout {
  print ((shift)->encode_line(@_));
}

sub end {
}

1;
