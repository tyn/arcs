use strict;
use SNG::Pipe;

my $key = shift or die "error: insufficient arguments.\n";
my $pat = shift or die "error: insufficient arguments.\n";

my $sng = SNG::Pipe->new;

$sng->begin;

$sng->export;

while (my $line = <>) {
  my $h = $sng->decode($line);
  print "$line" if $h->{$key} =~ qr{$pat};
}

$sng->end;
