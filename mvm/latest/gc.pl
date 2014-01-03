##!/usr/local/ActivePerl-5.10/bin/perl -s
#!C:\perl\bin\perl.exe
################################################################################
# Config start # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

use strict;
use warnings;
use Data::Dumper;
$Data::Dumper::Indent = 3;
$Data::Dumper::Useqq = 1;
use Geo::Coder::Googlev3;
use Geo::WeatherNOAA;
use List::Util qw(first);
my $geocoder = Geo::Coder::Googlev3->new();
my ($type,$addy,$weather,$takedump,@locs);
my $a = 1;

################################################################################
# Main start # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

&takeArgs(\@ARGV);
&geoCode;

foreach my $location (@locs){
	my %location = %{$location};
	my @ac = @{$location{address_components}};
	my (@noaa,$coverage,%cov,@printer,$city,$state,$date,$warnings,$forecast);
	$noaa[0] = &getCityState('city',\@ac);
	$noaa[1] = &getCityState('state',\@ac);
	($date, $warnings, $coverage, $forecast) = process_city_zone(lc($noaa[0]),lc($noaa[1]),'','get') unless not $weather;
	%cov = %{$coverage} unless not $weather;
	if ($weather) {
		foreach (@{$warnings}) { print; }
	}
	push(@printer, $location{formatted_address} . "\n",
	"Latitude:  " . $location{geometry}{location}{lat} . "\nLongitude: " . $location{geometry}{location}{lng} . "\n",
	"Location Type: " . $location{geometry}{location_type} . "\n");
	if ($a < 10){
		print "0$a)\n";
	} else {
		print $a . ")\n";
	}
	print @printer[0..($type-1)];
	#print "\@noaa ->\n" . Dumper(@noaa) . "---Done---\n";
	print "\n===WEATHER FORECAST===\nCoverage area is $forecast\n\n" unless (not $forecast) or (not $weather);
	if ($weather) {
		foreach my $key (keys %cov) {
 			print "$key: $cov{$key}\n";
		}
	}
	print "----\n\n";
	$a++;
}

################################################################################
# Subroutines below  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

sub takeArgs {
	my @args = @{(shift)};
	if ($#args == 0){
		chomp($addy = $args[0]);
		$type = 1;
		$weather = 0;
	} elsif ($#args == 2){
		chomp($type = $args[0]);
		chomp($weather = $args[1]);
		chomp($addy = $args[2]);
	} else {
		print "\nThe proper usage is:\n\n\t$0 [0,1,2,3](complexity of output) [0,1](weather on/off) \"[Address]\"\n\n";
		exit;
	}
}

sub geoCode {
	my $result;
	push (my @errors, "Could not parse $addy: $!") unless @locs = $geocoder->geocode( location => $addy );
	if ($#locs +1 == 1) {
		$result = 'result';
	} else {
		$result = 'results';
	}
	print "\n\nQuery returned " . ($#locs +1) . " $result:\n\n===" . uc($result) . "===\n" unless @errors and print @errors and exit;
}

sub getCityState {
	my %citystate;
	chomp(my $type = shift);
	my @bc = @{(shift)};
	for (my $x=0;$x<=$#bc;$x++){
		my $y = $bc[$x];
		my %y = %{$y};
		if ($type eq 'city'){
			if (     $y{types}[0] =~ /(sub)?locality/i) {
				$citystate{$type} = $y{short_name};
				last;
			} elsif ($y{types}[0] =~ /admin\w+?vel_3/i) {
				$citystate{$type} = $y{short_name};
				last;
			} elsif ($y{types}[0] =~ /admin\w+?vel_2/i) {
				$citystate{$type} = $y{short_name};
				last;
			}
		} elsif ($type eq 'state'){
			if (     $y{types}[0] =~ /admin\w+?vel_1/i) {
				$citystate{$type} = $y{short_name};
				last;
			}
		} else {
			print "I don't know what you're asking me for: $type\n";
			return 0;
		}
		#print "Type $x-> " . $y{types}[0] . "\n";
	}
	return($citystate{$type});
}
