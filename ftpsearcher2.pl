#!C:\perl\bin\perl.exe
# Eric Young - May 2010
# C:\scripts\ftpsearcher2.pl - script to find site survey files in a directory.
#############################
use strict;
use warnings;
use File::Find;
use File::Next;

# Declarations/Var init #####
my ($which,$dir,$bpdb);
my $biter;
my $x = 0; my $y = 0;
my $p = 0; my $d = 0; my $q = 0;
my @ids;
my %record;
my $long = length($0) + 4;
$long = "*" x$long;
my $errr = "\n$long\n* $0 *\n$long\nA script for finding site survey forms in a directory tree.\nThe proper usage is:\n\n  $0 [1,2]\n  where\n  1 = FTP dir\n  2 = QuickBase dir\n\n";

# Handles Command Line Args #
if (($#ARGV + 1) > 0){
	$which = $ARGV[0];
	if ($which == 1){
		$dir = "c:/everwell/FTP site";
		$bpdb = "C:/Documents and Settings/Eric/Desktop/outerftp.csv";
	}	elsif ($which == 2){
		$dir = "C:/Documents and Settings/Eric/Desktop/bc72rcujb";
		$bpdb = "C:/Documents and Settings/Eric/Desktop/outer.csv";
	}	else {
	print $errr;
	exit;
	}
} else {
	print $errr;
	exit;
}

# Main Body #################
my $iter = File::Next::dirs({descend_filter => sub{0}, sort_files => 1}, $dir );
while (defined(my $file = $iter->()) ){
	$biter = File::Next::files({file_filter => \&Catcher}, $file);
}
while (defined(my $filer = $biter->()))
{
	print "File is $filer\n";
	$y++;
	if ($filer ne "")
	{
		push(@ids,$filer);
	}
}
open (BPDB, ">$bpdb") or die "Couldn't open $bpdb: $!";

foreach my $num (@ids)
{
	if ($num ne ""){
		&Outer($num);
	}
}
foreach my $key (sort keys %record)
{
	print BPDB "$key,$record{$key}\n"	
}
close BPDB;
print $x . " files found.\n";
print $y . " files processed.\n";
print "$#ids is the highest indice in the array.\n";
print "1st matched $p times\n";
print "3rd matched $d times\n";
print "Bollocks matched $q times\n";
############
### SUBS ###
############
sub Catcher{
	/^.+?(ss |site|survey).+?\.(pdf|tif|tiff)$/i;
}

sub Outer{
	my $bollocks = shift;
	my $id;
	$bollocks =~ /^(.+?)(ss |site|survey)(.+?)\.(pdf|tif|tiff|jpg)$/i;
	my $first = $1;
	my $third = $3;
	if ($first =~ /.+?(\d{5,6}).+?/)
	{
		print "1st\n";
		$p++;
		$id = "1st," . $1;
	} elsif ($third =~ /.+?(\d{5,6}).+?/) {
		print "3rd\n";
		$d++;
		$id = "3rd," . $1;
	} else {
		print "Ugh\n";
		$q++;
		$id = "Ugh," . $bollocks;
	}
	$x++;
	$record{$id} = $bollocks;
}