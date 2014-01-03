#!D:\perl\perl\bin\perl
# Eric Young - February 2009
use strict;
use warnings;
my $includes_fp = "D:/3PL_Reports/includes/"; # Includes Dir for HTML formatting
my $in_fp = "D:/3PL_Reports/incoming/"; # Where the XML files are written to
my $out_fp = "D:/3PL_Reports/output/"; # Where the final output is written to
my ($create, %cdown, @srtdfiles, %unique, %bridge);

opendir(DIR, $in_fp) || die "can't opendir $in_fp: $!"; # Open the incoming files folder or die
my @files = grep { /^[^.|..]/ } readdir(DIR); # Read in contents of dir. Store in @files array
closedir DIR;

foreach my $ffiles(@files) { # Grep first part of filename and assign to testname array
	$ffiles =~ /^(.+?)(_.+)$/;
	$unique{$1} = $2; # key is common prefix, val is last value in of common prefix
	$bridge{$ffiles} = $1; # key is file name, val is common prefix.
}

foreach my $ke ( keys %unique ){
	open (HTML, ">$out_fp$ke.xml") or die "Couldn't open $out_fp$ke.xml: $!";
	print HTML <<xmlheader;
<?xml version="1.0" encoding="ISO-8859-1"?>
<?xml-stylesheet type="text/xsl" href="simple.xsl"?>
<output>
xmlheader
	foreach my $bval( keys %bridge) {
		if($bridge{$bval} eq $ke){
			my $fn = "$in_fp"."$bval";
			open REPORT, $fn or die "Could not open $fn for read :$!";
			while (<REPORT>) {
				if (/^<countdown>([\-]*?\w+?)<\/countdown>$/) { # Get the countdown order and then sort by it.
				$cdown{$1} = $fn;
				} 
			} 
			close REPORT;
		} 
	} 
	for my $kys ( sort {$b<=>$a} keys %cdown) {
		push (@srtdfiles, $cdown{$kys}); # sorted array of filenames with path
	} 
	foreach my $newdata (@srtdfiles) {
		open REPO, $newdata or die "Couldn't open $newdata for read: $!";
		while (<REPO>) {
			print HTML "$_";
		} 
		close REPO;
	} 
	undef @srtdfiles;
	undef %cdown;
	print HTML "</output>";
	close HTML;
} 
print "We're done here!\n";