#!C:\perl\bin\perl.exe
# Eric Young - May 2010
# C:\scripts\ftpfilter.pl - script to find site survey files in a directory.
################################################################################
use strict;
use warnings;
use File::Find;
use File::Next;
use File::Copy;
use File::Basename;
use Time::HiRes qw(usleep);
use File::Path qw(make_path remove_tree);

# Declarations/Var init ########################################################
my ($biter,%ids,%record);
my $x = 0;my $y = 0;my $p = 0;my $d = 0;my $q = 0;
my $dir = "c:/everwell/public_ftp";
my $ndir = "c:/everwell/ftpcatch";
my $ofile = "c:/scripts/mvm/latest/ftp.csv";
my $biterfile = "c:/scripts/mvm/latest/biter.txt";
#my $dir = "f:/storage/mvm/public_ftp";
#my $ndir = "f:/storage/mvm/writefolder/ftpcatch";
make_path($ndir, {verbose => 0, mode => 0744, error => \my $err});
#my $ofile = "f:/storage/mvm/mvm/ftp.csv";
#my $biterfile = "f:/storage/mvm/mvm/biter.txt";
open (BITER, ">$biterfile") or die "Can't open $biterfile: $!";

# Main Body ####################################################################
my $iter = File::Next::dirs({descend_filter => sub{0}, sort_files => 1}, $dir );
while (defined(my $file = $iter->()) ){
	$biter = File::Next::files({file_filter => \&Catcher}, $file);
}
while (my @filer = $biter->()) {
#	0 = Dir, 1 = File, 2 = Fullpath.
	my $odir = $filer[0];
	my $ofname = $filer[1];
	my $ofpath = $filer[2];
	$odir =~ /(\d{6,})/i;
	my $id = $1;
	my $suffix = &fixSuffix($ofname);
	my $nfname = "ss_" . $id . "-00" . $suffix;
	my $nfpath = $ndir . "/" . $nfname;
	if (-s $nfpath) {
		$nfpath = &fileDuper($nfpath);
	}
	&fileCopy($ofpath, $nfpath);
	print BITER "$id,$ofpath,$nfpath\n";
	$y++;
}
close BITER;
print $y . " files processed.\n";

# Subs #########################################################################
sub Catcher {	/^.*?(ss |site|survey|\d{1,6}ss|\d{1,6}-ss).*?\.(pdf|tif|tiff)$/i; }

sub fileCopy{
	my $old = shift;
	my $new = shift;
	copy($old,$new);
}

sub fileDuper{
	print "fileDuper\n";
	my $fpath = shift;
	my($filename, $directories, $suffix) = fileparse($fpath, qr/\.[^.]*+/);
	substr $filename, 10, 2, fileCounter($filename,$directories); #returns what's to be appended to filename before the suffix
	print "filename = $filename\n";
	$fpath = $directories . $filename . $suffix;
	print "$fpath\n";
	return $fpath;
}

sub fileCounter{
	print "fileCounter\n";
	my $id = shift;
	my $dir = shift;
	my $count;
	my %list;
	$id =~ /(\d{6,})/;
	my $object = File::Next::files({file_filter => sub{/$1/}}, $dir);
	while (defined( my $file = $object->() ) ) {
		$list{$file} = $id;
		print "The $file = $id\n";
	}
	$count = &fileNames(\%list);
	print "count is $count\n";
	return $count;
}

sub fixSuffix{
	print "fixSuffix\n";
	my $name = shift;
	$name =~ /(\.[^\.]+)$/;
	my $suffix = $1;
	$suffix = lc($suffix);
	return $suffix;
}

sub fileNames{
	print "fileNames\n";
	my $names = shift;
	my ($name,@blist);
	foreach my $key (sort(keys %$names)) {
		my($filename, $directories, $suffix) = fileparse($key, qr/\.[^.]*+/);
		push(@blist,$filename);	
	}
	usleep(250000);
	foreach my $val (@blist){ #Should only be one value for each ID at this point...
		$name = $val;
	}
	print"Name is: $name\n";
	my $first = substr($name,0,10);
	print "first is $first\n";
	my $dupe = substr($name,10,2);
	print "dupe is $dupe\n";
	$name =~ /^(.+?\d{6,})-(\d{2,})(\.[^\.]+)$/;
	$dupe = $dupe+1;
	print "dupe is now $dupe\n";
	if ($dupe<10 && length($dupe)<2){
		$dupe = "0" . $dupe;
		print "dupe is now $dupe\n";
	}
	return $dupe;
}


