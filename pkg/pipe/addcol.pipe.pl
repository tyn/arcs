use strict;
use SNG::Pipe;

my $name = shift or die "error: insufficient arguments.\n";
my $value = shift or die "error: insufficient arguments.\n";

my $sng = SNG::Pipe->new;

$sng->begin;

$sng->export($sng->header , $name);

while (my $line = <>) {
  my $h = $sng->decode($line);
  $h->{$name} = $value;
  $sng->put($h);
}

$sng->end;
