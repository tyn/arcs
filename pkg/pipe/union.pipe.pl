use strict;
use SNG::Pipe;

my $sng = SNG::Pipe->new;

$sng->begin;

$sng->export($sng->header);

my $state = 0;

while (my $line = <>) {
  if ($state == 0) {
    if ($line =~ m{^WTD}) {
      $state = 1;
    } else {
      my $h = $sng->decode($line);
      $sng->put($h);
    }
  } elsif ($state == 1) {
    if ($line =~ m{^$}) {
      $state = 0;
    }
  } else {
    die "Invalid state: $state";
  }
}

$sng->end;
