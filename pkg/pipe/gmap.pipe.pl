use strict;
use SNG::Pipe;

$SIG{INT} = sub { die "Caught SIGINT.\n"; };

my $state = {
  verbose => 0,
  identifier => '{}',
  stopOnErrors => 0
};

while (@ARGV > 0 && $ARGV[0] =~ m{^(-(.)(.*))$}) {
  my ($fopt, $opt, $val) = ($1, $2, $3);
  shift;
  if    ($opt eq 'I') { $state->{identifier} = $val || (shift); }
  elsif ($opt eq 's') { $state->{stopOnErrors} = 1; }
  elsif ($opt eq 'v') { $state->{verbose} = 1; }
  else                { die "Unrecognized option: $fopt\n"; }
}
@ARGV == 0 && die "Insufficient arguments.";

my $key = shift;
my %lines;

my $sng = SNG::Pipe->new;

$sng->begin;
while (<STDIN>) {
  my $line = $_;
  my $h = $sng->decode($line);
  my $g = $h->{$key};
  if (!defined($lines{$g})) {
    $lines{$g} = [];
    if ($state->{verbose}) {
      print STDERR " +$g\n";
    }
  }
  push @{$lines{$g}}, $line;
}
$sng->end;

foreach my $g (sort keys %lines) {
  my $ls = $lines{$g};
  my $n = scalar(@$ls);
  if (@ARGV > 0) {
    my @as = @ARGV;
    local $SIG{PIPE} = 'IGNORE';
    my $pat = $state->{identifier};
    map { ~ s{\Q$pat}{$g}eg; $_ } @as;
    print STDERR " (${n}x $g) exec @as\n";
    # Requires Perl 5.6.1+
    open my $outp, "|-", @as
      or die "failed to run @as: $!";
    print $outp $sng->{raw_magic};
    print $outp $sng->{raw_header};
    print $outp @$ls;
    close($outp);
    if ($state->{stopOnErrors}) {
      my $exit = $? >> 8;
      my $sig = $exit & 0x7f;
      if ($sig) {
        die "Child process terminated with signal $sig.";
      }
    }
  } else {
    print STDERR " (${n}x $g) show\n";
    print $sng->{raw_magic};
    print $sng->{raw_header};
    print @$ls;
  }
}
#print STDERR "OK\n";
