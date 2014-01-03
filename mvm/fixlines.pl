#!C:\perl\bin\perl.exe
# Eric Young - December 2009
use strict;
use warnings;

my ($ifile,$ofile);

$ifile = $ARGV[0]; # What file to read in...
$ofile = $ARGV[1]; # What file to output to...
print"\nThe file to process is $ifile\nThe file to write to is $ofile\n";

my $name = $ifile;
open FIX, "$name" or die "Cannot open $name: $!";
open FIXED, ">$ofile" or die "Cannot write to $ofile: $!";
while (<FIX>) {
	my $hmmm = $_;
	print "$hmmm\n";
	$hmmm =~ s/\r\n|\n|\r/\n/g;
	print FIXED "$hmmm";
	print "hmmm = $hmmm\n";
	print "loop done\n";
}
close FIX;
close FIXED;
