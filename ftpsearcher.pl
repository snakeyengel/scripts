#!C:\perl\bin\perl.exe
# Eric Young - May 2010
# C:\scripts\ftpsearcher.pl - script to see if there's a survey file in the
# FTP records from Convergent
#############################
use strict;
use warnings;
use File::Find;
use File::Next;

#############################
my $dir = "c:/everwell/FTP site";
my $indir;
my $b = 0;
my @dirlist;

#############################
find(\&dir_lister, $dir); # find the directories and then store in an array

foreach my $val (@dirlist){
	$indir = $dir . "/" . $val;
	find(\&pdf_checker, $indir);
}

print $b . " directories found.\n";

############
### SUBS ###
############
sub dir_lister # sub to get dirs and shove in array
{
  my $file = $_;
	if (-d $file){
		push(@dirlist,$file)
	}
} # END dir_lister

sub pdf_checker # sub to test for presence of .pdf files
{
				my @dir_contents;
				push(@dir_contents,$_);
				my $test = $_;
				if($test =~ /^.+?(ss | Survey).+?\.pdf$/){
								my $match = $test . "\n";
#								my $match = $test . "\n";
								#print $match;
								$b++;
								return;
				} else {
								
								return;
				}
} # END pdf_checker