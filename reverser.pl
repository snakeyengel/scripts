#!D:\perl\perl\bin\perl
# Eric Young - February 2009
#<?xml version="1.0" encoding="ISO-8859-1"?>
#<?xml-stylesheet type="text/xsl" href="simple.xsl"?>
#<output>
#<report id="POS920">
#<lpn>5012S1-GFM08990164</lpn>
#<date></date>
#<countdown>407</countdown>
#<voyage>POS920</voyage>
#<location>42S7</location>
#<item_id>5012S1</item_id>
#<ship_bol>SGNVPTBCVLP92015</ship_bol>
#<status>CANTALOUPES - SIZE 12</status>
#<entry_no>63094</entry_no>
#<count_qty>64</count_qty>
#<count_unit>CASE</count_unit>
#</report>
use strict;
use warnings;
my ($hdr, $sfx, @each, @rprt, $ifln);
if (($#ARGV + 1) > 0){
	$ifln = $ARGV[0];	
} else {
	print "\$#ARGV = $#ARGV\nThe proper usage is:\n\n\t$0 [FileToBeProcessed]\n\n";
	exit;
}
my $in_fp = "D:/3PL_Reports/safety/"; # Where the XML files are written to
my $out_fp = "D:/3PL_Reports/safety/recover/"; # Where the final output is written to
my $file = "$in_fp"."$ifln";
open XMLF, $file || die "can't open $file: $!"; # Open the incoming files folder or die
while (<XMLF>){
	push (@each,$_);
}
close XMLF;

foreach my $ln (@each){
	if($ln =~ /^<\?/ || $ln =~ /^<output/){ next;}
	if($ln =~ /^<report/){
		$ln =~ /id="(.+?)">$/;
		$hdr = $1;
		push (@rprt, $ln);
	} elsif($ln =~ /^<entry_no>/){
		$ln =~ /<entry_no>(.+?)<\/entry_no>/;
		$sfx = $1;
		push (@rprt, $ln);
	} elsif ($ln =~ /^<\/report/){
		push (@rprt, $ln);
		my $ofile = "$out_fp$hdr"."_"."$sfx".".txt";
		print "$ofile\n";
		open OFILE, ">$ofile" || die "can't open $ofile for writing: $!";
		foreach my $line (@rprt){
			print "$line";
			print OFILE "$line";
		}
	close OFILE;
	undef @rprt;
	}else {
		push (@rprt, $ln);
	}
}