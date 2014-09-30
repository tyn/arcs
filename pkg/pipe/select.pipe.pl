use strict;
use SNG::Pipe;

my $sng = SNG::Pipe->new;

my @as = @ARGV;
@ARGV=();

$sng->begin;

$sng->export(@as);

while (my $line = <>) {
  my $h = $sng->decode($line);
  $sng->put($h);
}

$sng->end;
