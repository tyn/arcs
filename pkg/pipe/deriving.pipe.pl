use strict;
use SNG::Pipe;

my %fields;
my $confs = [];

while (@ARGV > 0 && $ARGV[0] =~ m{^(-(.)(.*))}) {
  my ($fopt, $opt, $val) = ($1, $2, $3);
  shift;
  if    ($opt eq 'a') {
    # Assign
    my $k = shift;
    my $v = shift;
    push @$confs,
      { command => 'assign'
      , key => $k
      , value => $v
      };
    $fields{$k} = 1;
  } elsif ($opt eq 'v') {
    # Assign
    my $k = shift;
    my $v = shift;
    push @$confs,
      { command => 'assign-value'
      , key => $k
      , value => $v
      };
    $fields{$k} = 1;
  } elsif    ($opt eq 'A') {
    # Assign
    my $k = shift;
    my $v = shift;
    my $s = shift;
    push @$confs,
      { command => 'assign-eval'
      , key => $k
      , value => $v
      , script => $s
      };
    $fields{$k} = 1;
  } elsif ($opt eq 'e') {
    # Evaluate
    my $k = shift;
    my $s = shift;
    push @$confs,
      { command => 'eval'
      , key => $k
      , value => $s
      };
    $fields{$k} = 1;
  } else { die "Unrecognized option: $fopt\n"; }
}

my $sng = SNG::Pipe->new;

$sng->begin;

$sng->export($sng->header, keys %fields);

while (my $line = <>) {
  my $h = $sng->decode($line);
  for my $d (@$confs) {
    my $cmd = $d->{command};
    if ($cmd eq 'assign' or $cmd eq 'assign-eval') {
      $h->{$d->{key}} = $h->{$d->{value}};
    } elsif ($cmd eq 'assign-value') {
      $h->{$d->{key}} = eval $d->{value};
    }
    if ($cmd eq 'eval' or $cmd eq 'assign-eval') {
      for ($h->{$d->{key}}) {
        eval $d->{script};
      }
    }
  }
  $sng->put($h);
}

$sng->end;
