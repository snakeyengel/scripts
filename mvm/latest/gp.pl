#!/usr/local/ActivePerl-5.10/bin/perl -s
#!C:\perl\bin\perl.exe

################################################################################
# Config start # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

use strict;
use warnings;
use Time::HiRes qw( usleep );
use Data::Dumper;
use Text::CSV_XS;
$Data::Dumper::Indent = 3;
$Data::Dumper::Useqq = 1;
use Geo::Coder::Googlev3;
my $geocoder = Geo::Coder::Googlev3->new();
my $csv = Text::CSV_XS->new ({ binary => 1, eol => $/ });
my ($if,
    $of,
    $addy,
    @locs,
    $mednum,$address1,$city,$state,$zip,$latitude,$longitude,$geoloctype,$dnuc,
    $numres);
my $a = 1;
my $sleeptime = 1000000; #.5 seconds between each google call (hopefully)

# Config end # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
################################################################################

################################################################################
# Main start # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

&takeArgs(\@ARGV);
open my $ifile, "<", "$if" or die "Cannot open $if: $!";
open my $ofile, ">", "$of" or die "Cannot write to $of: $!";
$csv->bind_columns (\$mednum, \$address1, \$city, \$state, \$zip, \$latitude, \$longitude, \$geoloctype, \$dnuc);
while ($csv->getline ($ifile)) {
	if ($. > 1) {
		if ($dnuc eq 'yes') {
			next;
		} else {
			my $cntr = sprintf("%03d", $. - 1);
			$addy = $address1 . ", " . $city . ", " . $state . " " . $zip;
			($latitude, $longitude, $geoloctype, $numres) = @{&geoCode($addy)};
			print "Record #$cntr -> $addy\n     Coords -> $latitude, $longitude, $geoloctype, $numres\n";
			my $aref = [$mednum,$address1,$city,$state,$zip,$latitude,$longitude,$geoloctype,$dnuc];
			my $status = $csv->print ($ofile, $aref);
			usleep($sleeptime);
		}
	} else {
		my $aref = [$mednum,$address1,$city,$state,$zip,$latitude,$longitude,$geoloctype,$dnuc];
		my $status = $csv->print ($ofile, $aref);
	}
}
$csv->eof or $csv->error_diag;
close $ifile or die "Couldn't close $if: $!";

# Main end # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
################################################################################

################################################################################
# Subroutines below  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

sub geoCode {
	my @result;
	push (my @errors, "Could not parse $addy: $!") unless @locs = $geocoder->geocode( location => $addy );
	foreach my $location (@locs){
		my %location = %{$location};
		my @ac = @{$location{address_components}};
		push(@result,$location{geometry}{location}{lat},$location{geometry}{location}{lng},$location{geometry}{location_type},$#locs);
	}
	my $result = \@result;
	return $result;
}

sub takeArgs {
	my @args = @{(shift)};
	if ($#args < 1){
		print "\nThe proper usage is:\n\n\t$0 \"input file\" \"output file\"\n\n";
		exit;
	} else {
		chomp($if = $args[0]);
		chomp($of = $args[1]);
	}
}
