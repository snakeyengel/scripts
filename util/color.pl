#!c:/perl/bin/perl.exe
use strict;
use warnings;
no warnings 'uninitialized';
#RGB value:= Red + (Green*256) + (Blue*256*256)
use Term::ReadLine;
my $term = new Term::ReadLine 'ColorFinder for 3PL';
my $prompt = "Enter the RGB value in Standard Hex Format (RRGGBB):";
my $OUT = $term->OUT || \*STDOUT;
while ( defined ($_ = $term->readline($prompt)) ) {
	my $res = $_;
	$res =~ /^(\w{2})(\w{2})(\w{2})$/;
	(my $r, my $g, my $b) = ($1, $2, $3);
	my $rr = hex($r); $rr = sprintf("%d", $rr);
	my $gg = hex($g); $gg = sprintf("%d", $gg);
	my $bb = hex($b); $bb = sprintf("%d", $bb);
	my $msnum = $rr + ($gg * 256) + ($bb * 256 *256);
	#my $hxres = sprintf(<%#x>, $res);
	print $OUT "$msnum\n";
	$term->addhistory($_) if /\S/;
}
