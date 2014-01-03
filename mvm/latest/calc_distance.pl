#!/usr/local/bin/perl
#!/usr/local/ActivePerl-5.10/bin/perl -s
#!C:\perl\bin\perl.exe
#
# 
# 
# 
#
# Config start # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# The program calculates the distance between two cities,
# provided as command line parameters using Google Matrix Distance API.
# It takes the distance from the response given in JSON format and prints it.
#
use strict;
use warnings;
use LWP::UserAgent;
use HTTP::Request;
use Data::Dumper; #can be used for print Dumper {result => $result};
use JSON qw/from_json/;

sub doHTMLRequest
{
        my ($url) = shift;
        my ($lwp) = LWP::UserAgent->new;
        my ($request) = HTTP::Request->new(GET => "$url");
        my ($response) = $lwp->request($request);

        return ($lwp->request($request));
}

sub doGoogleDistanceMatrixRequest
{
        my ($sourceLocation) = shift;
        my ($destinationLocation) = shift;
        my ($url) = 'http://maps.googleapis.com/maps/api/distancematrix/json?'.
                "origins=$sourceLocation&destinations=$destinationLocation"
                .'&mode=bicycling&language=en-EN&sensor=false&units=imperial';

        #print $url."\n";

        my ($response) = doHTMLRequest($url);

         if ($response->is_success)
        {
                my ($result) = from_json( $response->decoded_content(), { utf8  => 1 } );
                #print Dumper { result => $result };
                my $distanceText = $result->{rows}[0]{elements}[0]{distance}{text};
                my $timeText = $result->{rows}[0]{elements}[0]{duration}{text};
                my $distance = sprintf ( "%.1f", $result->{rows}[0]{elements}[0]{distance}{value} / 1000 / 1.609 );
                #print $distance, "\n";
                my $time = $result->{rows}[0]{elements}[0]{duration}{value};
                my $rate = sprintf ( "%.1f", $distance / ( ( $time / 60 ) / 60 ) );
                my $realrate = sprintf ( "%.1f", $rate * 3.75 );
                my $realtime = sprintf ( "%.1f", $distance / $realrate );
                return "$distanceText in $timeText at an average rate of $rate/mph.\nIn reality it will be closer to $realrate/mph and take approximately $realtime hrs to get there";

        }
        else
        {
                return $response->error_as_HTML;
        }

}

#print "Calculate the distance between cities using Google Matrix Distance. Doing request ...\n";

my ($origin) = shift @ARGV ;
my ($destination) = shift @ARGV;

my ($distance) = doGoogleDistanceMatrixRequest($origin, $destination);

print "\nAnswer: $distance\n";