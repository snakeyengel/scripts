#
# #   !C:\perl\bin\perl.exe
#use strict;
#use warnings;
#use File::Basename;
#use File::Spec;
#use File::DirList;
#use File::Next;

#my $idir = "C:/scripts";
#my @dircontents = &FileRetriever($idir);
#foreach (@dircontents){
#    print &FileSpecCatcher($_) . "\n";
#}
my $outer = "c:/everwell/folderstructure/mvm"; # Where the folders are created...

sub FilePathCatcher{
    my $path = shift;
    my($filename, $directory) = fileparse($path);
    &DirSaver($directory);
    return $filename;    
}
sub FileSpecCatcher{
    my $path = shift;
    my($volume, $directory, $filename) = File::Spec->splitpath($path);
    return $filename;
}
sub DirSaver{
    my $dir = shift;
    print $dir . "\n";
}
sub DirMaker{
    my $goodpath = File::Spec->catpath( @_ );
    print "\$goodpath = " . $goodpath . "\n";
}
sub DirSlurper{
    shift;
    my @files = File::DirList::list($_, 'dn', 1, 1, 0);
    return @files;
}
sub FileRetriever{
    my $files = File::Next::files( shift );
    my @dirlist;
    while (defined (my $file = $files->() ) ) {
        push(@dirlist, $file);
    }
    return @dirlist;
}
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
1;