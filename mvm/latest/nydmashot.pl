#!C:\perl\bin\perl.exe
# Eric Young - 12.14.2010
# C:\scripts\mvm\nydmashot.pl - copies all the photographs for sites that match into a new dir for viewing
##############################
use strict;
use warnings;
use Text::ParseWords;
use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);
use File::Next;

my ($ifile,$ofile);
my $spath = "c:/everwell/public_ftp/";
my $dpath = "c:/everwell/nycatch/";

File::Copy::Recursive::pathmk($dpath) or die $!;

$ifile = shift @ARGV;
#$ifile = chomp $ifile;

my $iter = File::Next::dirs( $spath );

open INF, "$ifile" or die "Can't open $ifile: $!";
while ( defined ( my $dir = $iter->() ) )
{
	#print "$dir\n";
	while (<INF>)
	{
		my ($id,$name) = parse_line(",", 0, $_);
		print "$spath$id\n";
		#my $test = $spath.$id;
		if ($dir =~ /\$spath(\$id.*?)/)
		{
			print "$1 is now $dpath$1\n";
			#dircopy($1,$dpath.$1);
			next;
		}
		else
		{
			next;
		}
	}
}
close	INF;
sub parse_csv {
	return quotewords(",",0, $_[0]);
}
