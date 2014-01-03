#!c:/perl/bin/perl.exe
use strict;
use warnings;
no warnings 'uninitialized';
#RGB value:= Red + (Green*256) + (Blue*256*256)
use Term::ReadLine;
my $term = new Term::ReadLine 'ColorFinder for 3PL';
my (@clrs, $msnum, @hxres, @prompts, $pp, $outer);
my $prompt = "This is to find the Windows value for a standard HTML color value.";
my $prompt1 = "Enter the decimal value of Red (0-255) and press 'Enter':";
my $prompt2 = "Enter the decimal value of Green (0-255) and press 'Enter':";
my $prompt3 = "Enter the decimal value of Green (0-255) and press 'Enter':";
my $prompt4 = "Enter the decimal value of Green (0-255) and press 'Enter':";
my $prompt5 = "Enter the decimal value of Blue (0-255) and press 'Enter':";
my $OUT = $term->OUT || \*STDOUT;
@prompts = ($prompt1, $prompt2, $prompt3, $prompt4, $prompt5);
print "$prompt\n";
ML: foreach $pp (@prompts){
SL:	while ( defined ($_ = $term->readline($pp)) ) {
		#chomp;
TL:		if(/^.*?(\d{1,}).*?$/ && ($1 >= 0 && $1 <= 255 )){
			$outer = $1;
			push @clrs, $1;
			$outer = sprintf(<%#x>, $outer);
			push @hxres, $outer;
			undef $outer;
			next ML;
		} else {
			redo ML;
		}
	}
}
print $OUT "You've entered: @clrs\n";
$msnum = $clrs[0] + ($clrs[1] * 256) + ($clrs[2] * 256 *256);

print "The Microsoft color value is:$msnum\nThe Hexidecimal value is:@hxres\n";
#	$term->addhistory($_) if /\S/;

sub hx{
	$outer = sprintf(<%#x>, $_);
	return $outer;
}
