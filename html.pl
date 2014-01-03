#!C:\Perl\bin\perl.exe
use warnings;
use strict;

my $infile = "sample.html";
my $outfile = "capture.txt";
my $string;
open INFILE, "$infile" or die "Can't open $infile for reading: $!";
open OUTFILE, ">$outfile" or die "Can't open $outfile for writing: $!";
while(<INFILE>){
	$string .= $_;
}
close INFILE;
while ($string =~ /name=cust_ref\d{1,}[^>]*?>.*?(<table[^>]*?>.+?<\/table>)/gsi) {
	print OUTFILE "$1";
}
close OUTFILE;
