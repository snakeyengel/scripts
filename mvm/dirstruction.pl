#!C:\perl\bin\perl.exe
# Eric Young - 07.27.2010
# C:\scripts\mvm\dirstruction.pl - script to create dir structure for lasso tool.
##############################
use strict;
use warnings;
use Fcntl;
use File::Path qw(make_path remove_tree);

my $counter = 0;
my $ifln = "c:/everwell/screen_locations.csv"; # input list of all sites except cancelled ones
my $outer = "c:/everwell/folderstructure/mvm"; # Where the folders are created...
make_path($outer, {verbose => 0, mode => 0744, error => \my $err});

print "Creating folder structures now...\n";
open IFILE, $ifln or die "Cannot open $ifln for read :$!";
while (<IFILE>){
	chomp; &Dirstruction($_);
}
close IFILE;
print "Done!\n";

sub Dirstruction{
	$counter++;
	my @tree;
	my $root = shift; #100001, etc.
	my $outerroot = $outer . "/" . $root; # /Users/eyoung/folderstructure/mvm/100001, etc.
	make_path($outerroot, {verbose => 0, mode => 0744, error => \my $err});
	my $docs = $outerroot . "/docs";
	push (@tree, $docs);
	my $pics = $outerroot . "/pics";
	push (@tree, $pics);
	my $sspics = $pics . "/survey";
	push (@tree, $sspics);
	my $servicepics = $pics . "/service";
	push (@tree, $servicepics);
	my $installpics = $pics . "/install";
	push (@tree, $installpics);
	foreach my $tdir (@tree){
		make_path($tdir, {verbose => 0, mode => 0744, error => \my $err});
	}
	if ($counter % 100 == 0){
		#print "$tdir \n";
		print "Working...\n";
	}
}
