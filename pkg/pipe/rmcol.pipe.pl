use strict;
use SNG::Pipe;

my $name = shift or die "error: insufficient arguments.\n";

my $sng = SNG::Pipe->new;

$sng->begin;

my @hs;

map { push(@hs, $_) unless $_ eq $name } $sng->header;

$sng->export(@hs);

while (my $line = <>) {
  my $h = $sng->decode($line);
  delete $h->{$name} if defined $h->{$name};
  $sng->put($h);
}

$sng->end;
