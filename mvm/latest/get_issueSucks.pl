#!/usr/local/bin/perl
#!/usr/local/ActivePerl-5.10/bin/perl -s
#!C:\perl\bin\perl.exe

# CTS Service Desk Test script:
# It collects and then parses the output from SD very nicely.

# Config start # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#BEGIN {
#  my $b__dir = ( -d '/home/ab5082/perl' ? '/home/ab5082/perl' : ( getpwuid($>) )[7].'/perl' );
#    unshift @INC, $b__dir.'/lib', map { $b__dir . $_ } @INC;
#}

# Module calls
use strict;
use warnings;
use XML::Simple;
use Data::Dumper;
use LWP::Simple;
use Config::Simple;

# Variable declarations
#my $cfg          = new Config::Simple ( '/home/ab5082/cts.ini' );
my $cfg          = new Config::Simple ( 'cts.ini' );
my $userName     = $cfg->param( 'userName' );
my $password     = $cfg->param( 'password' );
my $url          = 'http://sd.core-techs.com/everwell/everwell.asmx/GetIssue';
   $url         .= '?userName='. $userName . '&password='. $password . '&ticket=U42106';
my $stuff        = get $url or die "Couldn't get $url: $!\n";
my $xml          = new XML::Simple;
my $data         = $xml->XMLin( $stuff );
my $returned     = $xml->XMLin( $data->{content} );

#print Dumper( $returned );
my %{$ticket}       = $returned->{UDSObject};
print ref($ticket);
# Start of Program
# Go through all the hashes and print except for the Description
foreach my $aray ( keys %{ticket{Attributes}{Attribute}} ) {

  if ( ref( ${$aray}{AttrValue} ) ne 'HASH' ) {
    print ${$aray}{AttrName}, " -> ", ${$aray}{AttrValue}, "\n" unless ${$aray}{AttrName} eq 'Description';
  } else {
    print ${$aray}{AttrName}, " -> ", "EMPTY\n" ;
  }

}

print "===================\n\n";