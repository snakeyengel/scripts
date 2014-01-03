#!C:\Perl\bin\perl.exe
# delfreq.pl
# program to calculate the frequency shift in a waveguide cavity due
# to a change in ambient temperature of filter.
# Lock R. Young, 9.23.1996
# Coded for Perl by Eric E. Young 6.27.2009
use warnings;
use strict;
no warnings 'uninitialized';
# 10
# .9
# 1
# 17E-6
# 
#

use Term::ReadLine;
my $term = new Term::ReadLine 'delfreq';

my $prompt = "Program to calculate the frequency shift in a waveguide/ncavity due to a change in the ambient temperature of the filter";
print "$prompt\n";

my $prompt1 = "Center Frequency in GHz: ";
my $prompt2 = "Guide width in inches: ";
my $prompt3 = "n for a TE10n Cavity: ";
my $prompt4 = "Alpha for Material, ie Copper is 17E-6 per Degree C: ";
my $OUT = $term->OUT || \*STDOUT;
#while ( defined ($_ = $term->readline($prompt)) ) {
my (@prompts, $pp, @args, $F, $A, $N, $AL, $WL, $C, , $CA, $WLA, $DA, $DFC, $DFF);
@prompts = ($prompt1, $prompt2, $prompt3, $prompt4);

ML: foreach $pp (@prompts){

SL:	while ( defined ($_ = $term->readline($pp)) ) {
		chomp;
		push @args, $_;
		next ML;
	}
}
&calculate(@args);


sub calculate{
	for (my $x=0;$x<$#args+1;$x++){
		if($x==0) {$F = $args[$x];}
		if($x==1){$A = $args[$x];}
		if($x==2){$N = $args[$x];}
		if($x==3){$AL = $args[$x];}
	}
	if($AL eq 0 or $AL eq ""){$AL = 17E-6;}
	print $AL;
	$WL = 11.8 / $F;
	$C = $N/sqrt(4/($WL*$WL)-1/($A*$A));
	$CA = $C / $A;
	$WLA = 2/sqrt(1+$N*$N/($CA*$CA));
	$DA = $AL * $A;
	$DFC = $F*$F/11.8*$WLA*$DA*1000;
	$DFF = $DFC*5/9;
	print "Cavity variation is $DFC MHz per degree celsius\n";
	print "Cavity variation is $DFF MHz per degree farenheit\n";
}
