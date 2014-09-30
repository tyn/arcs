use strict;
use warnings;
use SNG::Pipe;

my $state
 = { key => undef
   , negate => 0
   };

while (@ARGV > 0 && $ARGV[0] =~ m{^(-(.)(.*))}) {
  my ($fopt, $opt, $val) = ($1, $2, $3);
  shift;
  if    ($opt eq 'k') { $state->{key} = $val || (shift); }
  elsif ($opt eq 'n') { $state->{negate} = 1; }
  else                { die "Unrecognized option: $fopt\n"; }
}

die "Insufficient arguments"
  unless @ARGV > 0;

my $file = shift;

my $sng = SNG::Pipe->new;

$sng->begin;
$sng->export;

while (my $line = <>) {
  my $h = $sng->decode($line);
  my $f = $h->{$state->{key}};
  my $wantPrint;
  if (-e $file) {
    $wantPrint = (stat($f))[9] > (stat($file))[9];
  } else {
    $wantPrint = 1;
  }
  $wantPrint ^= 1 if $state->{negate};
  print "$line" if $wantPrint;
}
$sng->end;

