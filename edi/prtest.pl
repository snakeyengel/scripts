#!D:\perl\perl\bin\perl
# Eric Young - February 2009
use Fcntl; #The Module
$db = 0; #Debug 0=No, 1=Yes
$includes_fp = "D:/3PL_Reports/includes/"; # Includes Dir for HTML formatting
$in_fp = "D:/3PL_Reports/incoming/"; # Where the XML files are written to
$out_fp = "D:/3PL_Reports/output/"; # Where the final output is written to

opendir(DIR, $in_fp) || die "can't opendir $in_fp: $!"; # Open the incoming files folder or die
@files = grep { /^[^.|..]/ } readdir(DIR); # Read in contents of dir. Store in @files array
closedir DIR;
if ($db) {print "@files\n";}

chdir $out_fp; # Where we're going to write the files to

foreach (@files) # Grep first part of filename and assign to testname array
{
	/(^.+)?_(.+)?\.txt$/;	
	push (@testname, $1); # First part of filename
	push (@sorter, $2); # Second part of filename
} # Close foreach (@files)
if ($db)
{
	print "The filename prefixes are:\n@testname\n"; #Test what we've grep'd.
	print "\nThe filename suffixes are:\n@sorter\n"; #Test what we've grep'd.
# Reduce to single unique keys and use them as output file names to group tags by receipt #.
} # Close if ($db)
foreach (@testname)
{
	if ($db)
	{
		print "Current value is $_\nAnd \$seen{\$_} is $seen{$_}\n";
	}
	push (@htmlname, "$_") unless $seen{$_}++; # Grab
	if ($db)
	{
		print "\$seen{\$_} = $seen{$_}\n";
	}
} # Close foreach (@testname)

print "\n\n\nThe following receipts are available for processing:\n";
foreach (@htmlname) {print "\n\n$_\n\n";}
print "Would you like to proceed?\n\n";
print "1. Yes\n2. No\n";
if (<STDIN> == 1)
{
	print "\n\nWould you like to delete the processed reports?\n\n";
	print "1. Yes\n2. No\n";
	if (<STDIN> == 1) 
	{
		$delete = 1;
	}
	else
	{
		$delete = 0;
	}

	# The main operation of the script is here.
	# Iterate over all the .txt files in the input dir.
	# Match them to their "parent" output file based on receipt #.
	# Read in xml stylesheet info, output dir info and whatever else.
	# Grep temporarily and replace the attribute "id" value with same, but quoted.
	foreach $hname (@htmlname)
	{
		if (!(open HTML, "$out_fp$hname.xml")) # If file doesn't exist, create it.
		{
		  $create = 1;
		  sysopen (HTML, "$out_fp$hname.xml", O_RDWR|O_EXCL|O_CREAT, 0755) or die "Couldn't open $out_fp$hname.xml: $!";
		  if ($db) {print "Creating $out_fp$hname.xml\n";}
		}
		else # otherwise open it and append new records into it.
		{
			$create = 0;
			open (HTML, ">>$out_fp$hname.xml") or die "Couldn't open $out_fp$hname.xml: $!";
			if ($db) {print "Appending to $out_fp$hname.xml\n";}
		}
	
		# Create xml header tags for each output file.	
		if ($create == 1)
		{
printf HTML <<xmlheader;
<?xml version="1.0" encoding="ISO-8859-1"?>
<?xml-stylesheet type="text/xsl" href="simple.xsl"?>
<output>
xmlheader
		}	
		foreach $data (@files) 
		{
			$dname = $data;
			$dname =~ /(^.+)?_.+/;
			if ($db){print "$data, $dname, $hname\n";}
			$dname = $1;
			if ($db){print "$dname = $hname?\n";}			
			if ($dname eq $hname)
			{
				print "Processing $data...\n";
				$fn = "$in_fp$data";
				open report, $fn or die "Could not open $fn for write :$!";
				while (<report>)
				{
					#if ($_ =~ /^(<report id=)([a-zA-Z0-9]+)(>)$/) # shouldn't need, but remember 4 l8r.
					#{
					#	$_ = "$1\"$2\"$3";
					#	printf HTML "$_\n";
					#}
					#else
					#{
						printf HTML "$_";
					#}
				}
				close report;
				if ($delete)
				{
					if (unlink $fn)
					{
					print "Deleting $fn...\n\n" or die "Couldn't delete $fn: $!";
					}
				}
			}
			# printf HTML "</output>\n"; # Change to STDIN CL params for keeping open or not. To Do...
		}
		print "\nWould you like to close the final report?\n";
		print "\n1. Yes\n2. No\n";
		if (<STDIN> == 1) {printf HTML "</output>\n";}
		close HTML;
		print "We're done here!";
	}
}