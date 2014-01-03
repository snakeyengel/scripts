#!/usr/local/bin/perl

# CTS Service Desk single issue script:
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
use LWP::Simple;
use Config::Simple;
use Data::Dumper;

# Variable declarations
my $userName     = "Everwell.Eric.Young"; #$cfg->param( 'userName' );
my $password     = "Letmein1!"; #$cfg->param( 'password' );
my $ticketIssue  = "U41617";

my $urlDocs       = 'http://sd.core-techs.com/everwell/everwell.asmx/GetAttmntInfo';
   $urlDocs      .= '?userName='. $userName . '&password=' . $password . '&ticket=' . $ticketIssue;
my $stuffDocs     = get $urlDocs or die "Couldn't get $urlDocs: $!\n";

my $xmlDocs       = new XML::Simple;
my $dataDocs      = $xmlDocs->XMLin( $stuffDocs );
my $returnedDocs  = $xmlDocs->XMLin( $dataDocs->{content} );
my $ticketDocs    = $returnedDocs->{UDSObject};
my @entryDocs     = @{$ticketDocs};
#my %docs;
for ( my $x = 1; $x <= $#entryDocs; $x++ ) {
  foreach my $item ( $entryDocs[$x]{Attributes}{Attribute} ) {
    foreach my $doc ( @{$item} ) {
      my @atts = %{$doc};
      my $name = $atts[1];
      my $value = $atts[3];
      print $name, " = ", $value, "\n";
    }
    print "\n----------------\n\n";
  }
}
#print Dumper ( %docs );

#my @namesDocs = (  "IS URL",          "Created", "File Type", "File Size",
#                   "Orig. File Name", "Name",    "Status",    "Deleted", );
#my %hnamesDocs;
#my @tnamesDocs = @namesDocs;
#foreach ( @tnamesDocs ) {
#  my $anameDocs = $_;
#  s/ /_/g;
#  $hnamesDocs{$anameDocs} = $_;
#}

1;