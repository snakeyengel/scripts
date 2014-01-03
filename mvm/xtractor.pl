#!C:\perl\bin\perl.exe
# Eric Young - May 2010; Revised in July 2010
# C:\scripts\xtractor.pl - script to find site survey files in directories.
#############################
use strict; use warnings; use File::Find; use File::Next; use File::Path qw(make_path remove_tree); use File::Copy;
use File::Basename; use File::Spec; use File::DirList; require "./subs.pl";
my $writedir = "c:/everwell/"; my $writefileprefix; my $writefilesuffix = ".csv";
my $writefilecontents;
my $outer = "c:/everwell/folderstructure/mvm"; # Where the folders are created...
my $counter = 0;
# Declarations/Var init #####
my ($which,$dir,$bpdb,$type,$biter,%ids,%record);
my ($x,$y,$p,$d,$q);
$x = 0; $y = 0; $p = 0; $d = 0; $q = 0; my $debug = 0;
my $long = (length($0) + 4);
$long = "-" x$long;
my $errr = "\n$long\n| $0 |\n$long\nA script for extracting site survey forms, contracts or pictures from a directory tree.\nThe proper usage is:\n\n  $0 [1,2] [s,c,p]\n\n  where\n  1 = FTP dir and 2 = QuickBase dir\n  and\n  s = Site Surveys, c = Contracts and p = Pictures\n\n";
# Handles Command Line Args #
if (($#ARGV + 1) > 1){
	$which = shift;
	$type = shift;
} else {
	print $errr;
	exit;
}
# Decision Tree
if ($which == 1){
	$dir = "c:/everwell/public_ftp";
	$writefileprefix = "ftp";
}	elsif ($which == 2){
	$dir = "C:/Documents and Settings/Eric/Desktop/bc72rcujb";
	$writefileprefix = "qb";
}	else {
print $errr;
exit;
}
if ($type eq 's') {
	$writefilecontents = "_ss";
} elsif ($type eq 'c') {
	$writefilecontents = "_contracts";
} elsif ($type eq 'p') {
	$writefilecontents = "_pics";
} else {
	print $errr;
	exit;
}
$bpdb = $writedir . $writefileprefix . $writefilecontents . $writefilesuffix;

# Main Body #################
# Phase 1 ###################

# Find all the files that match the ARGV
# Package the object...
my $iter = File::Next::dirs({descend_filter => sub{0}, sort_files => 1}, $dir );
# Run the object's contents through the Catcher sub and place in new object...

while (defined(my $file = $iter->()) ){
	$biter = File::Next::files({file_filter => \&ssCatcher}, $file);
}
# Throw valid results from object onto ids array...
while (my @filer = $biter->()) {
	$y++;
	#0 = Dir, 1 = File, 2 = Fullpath.
	if ($filer[0] ne "") {
		$ids{$filer[2] . "," . $filer[0]} = $filer[1]; # assign stuff to the ids hash here...
	}
}

open (BPDB, ">$bpdb") or die "Couldn't open $bpdb: $!";
while ((my $key, my $value) = each %ids) {
	&Outer($key,$value);
}

# Outer fills up record hash. Sort the hash's keys and then print to the output file...
foreach my $key (sort keys %record) {
	(my $idnow, my $trash) = split(',', $key); 
	my $newval = $record{$key} . "," . $outer . "/" . $idnow . "/";
	print BPDB "$key,$newval\n";
}
close BPDB;

# Phase 1 END ###############
# Phase 2 ###################

my $fixedfile = &Fixer($bpdb); # Clean up any line ending problems proactively.

open (OFILE, $fixedfile) or die "Couldn't open $fixedfile: $!";
while (<OFILE>){
	chomp;
	(my $idnum, my $fullpath, my $filename, my $newpath) = split(',');
	&Dirstruction($idnum);
	my $nname = &FileNames($type,$filename,$newpath);
	my $oldfile = $fullpath . "\\" . $filename;
	if (!(-s $nname)) {
	  copy($oldfile,$nname) or die "Copy failed: $!";
		print "copying $oldfile to $nname\n";
	}
	#print "\$idnum = $idnum, \$filename = $nname\n";
}
close OFILE;
# END #######################

# SUBS ######################
sub ssCatcher{ /^.*(ss |ss-|ss\d{1,6}|site|survey).*\.(pdf|tif|tiff)$/i; }
sub contractCatcher{ /^.*(agreement|contract|[^survey]|[^ss|ss |ss-]).*\.(pdf|tif|tiff|jpg)$/i; }

sub Outer{
	(my $fullname, my $dirpath) = split(',',shift);
	my $bollocks = shift;
	my ($id,$first,$third);
	$bollocks =~ /^(.*)(ss |site|survey)(.+?)\.(pdf|tif|tiff|jpg)$/i;
	if ($1) {$first = $1;}
	if ($3) {$third = $3;}
	if ($1) {
		if ($first =~ /.*?(\d{5,6}).+?/) {
			if ($debug > 0) {print "1st\n";}
			$p++;
			$id = $1;
		}
	}	elsif ($3) {
			if ($debug > 0) {print "3rd\n";}
			$d++;
			$id = "$3";
		#}
	}	else {
		if ($debug > 0) {print "Ugh\n";}
		$q++;
		$id = "";
		return 0;
	}
	if ($id and $id ne "") {
		$x++;
		$record{$id . "," . $dirpath} = $bollocks;
	}
}

sub Fixer{
	my $name = shift;
	open FIX, "$name" or die "Cannot open $name: $!";
	my $ofile = $name . ".fixed";
	open FIXED, ">$ofile" or die "Cannot write to $ofile: $!";
	while (<FIX>) {
		my $hmmm = $_;
		$hmmm =~ s/\r\n|\n|\r/\n/g;
		print FIXED "$hmmm";
	}
	close FIX;
	close FIXED;
	return $ofile;
}

sub FileNames{
	my $type = shift;
	my $raw = shift;
	my $newdir = shift;
	my $docs = "docs/";
	my($filename, $directories, $suffix) = fileparse($raw, qr/\.[^.]*+/);
	my $ss = "ss_";
	my $contract = "contract_";
	$raw =~ /.*?(\d{5,6}+)(.+?|.?)/;
	my $id = $1;
	$suffix = lc($suffix);
	if ($type eq 's'){
		my $newname = $newdir . $docs . $ss . $id . $suffix;
		return $newname;
	} elsif ($type eq 'c'){
		my $newname = $newdir . $docs . $contract . $id . $suffix;
		return $newname;
	}
}

sub pirstruction{
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
