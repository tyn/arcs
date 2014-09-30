use strict;
use warnings;
use SNG::Pipe;

my $state
 = { lines => []
   , lastValues => []
   , separator => "\177"
   , keyColumns => ""
   , minColumns => undef
   , maxColumns => undef
   , prefix => ""
   , eol => "\n"
   };

while (@ARGV > 0 && $ARGV[0] =~ m{^(-(.)(.*))}) {
  my ($fopt, $opt, $val) = ($1, $2, $3);
  shift;
  if    ($opt eq 'k') { $state->{keyColumns} = $val || (shift); }
  elsif ($opt eq 'm') { $state->{minColumns} = $val || (shift); }
  elsif ($opt eq 'M') { $state->{maxColumns} = $val || (shift); }
  elsif ($opt eq 'p') { $state->{prefix} = $val || (shift); }
  elsif ($opt eq 't') { $state->{eol}       = &unescape($val || (shift)); }
  else                { die "Unrecognized option: $fopt\n"; }
}

my $sng = SNG::Pipe->new;

$sng->begin;
$sng->export((map {
  "$state->{prefix}$_"
} qw(is_first is_last group_nr)), $sng->header);

while (my $line = <>) {
  my $h = $sng->decode($line);
  &append_line($state, $line, $h);
}
&flush($state);
$sng->end;

sub unescape
{
  for ((shift)) {
    s{\\t}{\t}g;
    s{\\r}{\r}g;
    s{\\n}{\n}g;
    return $_;
  }
}

sub append_line
{
  my $state = shift;
  my $line = shift;
  my $h = shift;
  my $k = $state->{keyColumns};
  my $v = join("--", map {defined($h->{$_}) ? $h->{$_} : ""} split(/,/, $k));
  my $vs = $state->{lastValues};
  unless (defined($vs->[-1]) && $vs->[-1] eq $v) {
    # New value.
    &flush($state);
    push @$vs, $v;
  }
  push @{$state->{lines}}, $h;
}

sub flush($)
{
  my $state = shift;
  my $as = $state->{lines};
  for (my $i=0; $i<@$as; $i++) {
    no warnings;
    my $h = $as->[$i];
    $h->{"$state->{prefix}is_first"} = ($i == 0) ? 1 : 0;
    $h->{"$state->{prefix}is_last"}  = ($i == @$as-1) ? 1 : 0;
    $h->{"$state->{prefix}group_nr"} = scalar(@{$state->{lastValues}}) - 1;
    if (defined($state->{maxColumns}) || defined($state->{minColumns})) {
      if ($i==0) {
        my %hh = %$h;
        foreach my $k (split /,/, $state->{maxColumns}) {
          $hh{$k} = (sort { $a->{$k} <=> $b->{$k} } @$as)[-1]->{$k};
        }
        foreach my $k (split /,/, $state->{minColumns}) {
          $hh{$k} = (sort { $a->{$k} <=> $b->{$k} } @$as)[0]->{$k};
        }
        $sng->put(\%hh);
        }
    } else {
      $sng->put($h);
    }
  }
  $state->{lines} = [];
}
