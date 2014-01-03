#!C:\perl\bin\perl.exe
# Eric Young - August 2010;
# C:\scripts\mvmapper.pl - script to find site survey files in directories.
#############################
use strict;use warnings;
use File::Copy;use File::Path qw(make_path remove_tree);use Time::HiRes qw(usleep);
my $counter = 0;
my $savedir = "c:/everwell/folderstructure/mvm";
my $ifile = "c:/everwell/mvm_map_full.csv";
my $utildir = "c:/everwell/newrepository/";

open IFILE, $ifile or die "Can't open $ifile!: $!\n";
my @johnny = <IFILE>;
close IFILE;
foreach my $line (@johnny) {
	chomp($line);
	my($id,$odir,$ndir,$ocfname,$ocdfname,$ncfname,$ossfname,$ossdfname,$nssfname) = split(',',$line);
	#usleep(500000);
	#100001,c:/everwell/bc72rcujb/,c:/everwell/folderstructure/mvm/100001/docs/,Atlanta Heart Associates1.1_32.PDF,Atlanta Heart Associates1.PDF,contract_100001,Site Survey_MED100001_AHA_Riverdale.1_33.pdf,Site Survey_MED100001_AHA_Riverdale.pdf,ss_100001
	&Dirstruction($id);
	$ncfname = $ncfname . &fixSuffix($ocfname);
	print "$ncfname\n";
	&fileCopy($odir . $ocfname, $ndir . $ncfname);
	&fileCopy($odir . $ocfname, $utildir . $ncfname);
	$nssfname = $nssfname . &fixSuffix($ossfname);
	print "$nssfname\n";
	&fileCopy($odir . $ossfname, $ndir . $nssfname);
	&fileCopy($odir . $ossfname, $utildir . $nssfname);
}

sub fileCopy{
	my $old = shift;
	my $new = shift;
	copy($old,$new);
}

sub fixSuffix{
	my $name = shift;
	$name =~ /^(.+?)(\..+)(\.[^\.]+)$/;
	my $suffix = $3;
	$suffix = lc($suffix);
	return $suffix;
}

sub Dirstruction{
	$counter++;
	my @tree;
	my $finaldir = shift; #100001, etc.
	my $fullpath = $savedir . "/" . $finaldir; # /Users/eyoung/folderstructure/mvm/100001, etc.
	make_path($fullpath, {verbose => 0, mode => 0744, error => \my $err});
	my $docs = $fullpath . "/docs";
	push (@tree, $docs);
	my $pics = $fullpath . "/pics";
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
