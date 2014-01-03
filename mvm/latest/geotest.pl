#!C:\perl\bin\perl.exe
################################################################################
# Config start # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

use strict;
use warnings;
use Data::Dumper;
use Geo::Coder::Google;
my ( $type, $addy );

if ( ( $#ARGV + 1 ) == 1 ) {
	chomp ( $addy = $ARGV[0] );
	$type = 1;
} elsif ( ( $#ARGV + 1 ) == 2 ) {
	chomp ( $type = $ARGV[0] );
	chomp ( $addy = $ARGV[1] );
} else {
	print "$#ARGV\n\nThe proper usage is:\n\n\t$0 [1,2,3](complexity of output) \"[Address]\"\n\n";
	exit;
}
#print $#ARGV . "\n";
print "\nResults:\n\n";
my $geocoder = Geo::Coder::Google->new( apiver => 3 );
die "Could not parse $addy: $!" unless my $place = $geocoder->geocode( location => $addy );
die "Could not parse $addy: $!" unless my @locs = $geocoder->geocode( location => $addy );
$Data::Dumper::Indent = 2;
$Data::Dumper::Useqq = 1;
#print "Object printing now:\n" . Dumper ( $place ) . "\n\n==========================\n\n";
#print "Array is printing now:\n" . Dumper ( @locs );

foreach my $location ( @locs ) {
	my %location = %{ $location };
	my @printer;
	if ( $type < 1 || $type > 3 ) { $type = 1 };
	if ( $type == 1 ) {
		push ( @printer, $location{ formatted_address } . "\n" );
	} elsif ( $type == 2 ) {
		push ( @printer, $location{ formatted_address } . "\n","Latitude:  " . $location{ geometry } { location } { lat } . "\nLongitude: " . $location{ geometry } { location } { lng } . "\n\n");
	} elsif ( $type == 3 ) {
		push ( @printer, $location{ formatted_address } . "\n",
			"Latitude:  " . $location{ geometry } { location } { lat } . "\nLongitude: " . $location{ geometry } { location } { lng } . "\n",
			"Location Type: " . $location{ geometry } { location_type } . "\n\n");
	}
	print @printer;
}