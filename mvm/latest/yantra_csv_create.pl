#!C:\perl\bin\perl.exe
# Eric Young - 12.14.2010
# C:\scripts\mvm\latest\yantra_csv_create.pl - parses a csv file of new sites to
#   create and creates them for each entry along with error checking and 
#   graceful handling of non-creates or duplicates
##############################
use strict;
use warnings;
use Text::ParseWords;
use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);
use File::Next;

my $ifile = "C:/Users/Admin/Downloads/sites.csv";
