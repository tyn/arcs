use strict;
use warnings;
use SNG::Pipe;

my $start_time = time;

my $sng = SNG::Pipe->new;

$sng->begin;
$sng->export;

my $mark = time;
my $lines = 0;
my $bytes = 0;
while (my $line = <>) {
  print "$line";
  {
    use bytes;
    $bytes += length($line);
  }
  $lines++;
  my $now = time;
  my $dtime = $now - $mark;
  my $elapsed = $now - $start_time;
  if ($dtime > 3) {
    printf STDERR
      "\r%8dsec %8dL %8dMB %8dsec %8.2f L/sec %8.2f MB/sec",
      $elapsed, $lines, $bytes/1000000,
      $dtime,
      $lines / $elapsed,
      $bytes / $elapsed/1000000;
    $mark = $now;
  }
}
$sng->end;
