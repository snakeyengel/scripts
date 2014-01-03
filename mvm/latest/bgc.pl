#!/usr/local/bin/perl
#!/usr/local/ActivePerl-5.10/bin/perl -s
#!C:\perl\bin\perl.exe
#
# Batch Geocode, or bgc.pl
# Fetches a report from QB of all locations due for updating their Lat/Lon's
# then gets them, timestamps the CLU field and then goes back to sleep
#
# Config start # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
use strict;
use warnings;
use HTTP::QuickBase;
use Config::Simple;
use DateTime;
use DateTime::TimeZone;
use Date::Parse;
our ( %omt, %omf, %smt, %smf );
require ( 'ops_ini.inc' ) or die "WTF! $!\n";
require ( 'sup_ini.inc' ) or die "WTF! $!\n";
my @fldvals;
my $debug = 0;
my $action = 'test'; # 'active' or 'test'
my $a = 1; #counter for test

# Quickbase paraphenalia
my $cfg       = new Config::Simple ( 'qb.ini' );
my $qdb       = HTTP::QuickBase->new();
my $username  = $cfg->param ( 'username' );
my $password  = $cfg->param ( 'password' );
my $app_token = $cfg->param ( 'app_token' );
my $olid      = $omt{Locations};
$qdb->authenticate( $username, $password );
$qdb->setAppToken( $app_token );

push ( my @fields, 
       'ID Number',
       'Address 1',
       'City',
       'State',
       'Zip',
       'Latitude',
       'Longitude',
       'DNUC',
       'GeoLocType',
       'CLU',
       'DueDate',
     );

foreach ( @fields ) {
  push ( @fldvals, $omf{$olid}{$_} );
  print "$_\n" if $debug;
}

my $get_these_fields = join ( '.', @fldvals );
print "$get_these_fields\n" if $debug;

# Query construction goes here
# ?a=q&qt=tab&dvqid=376&query=({'286'.XCT.'dead'})&clist=36.6.18.20.21.22.83.266.267.285.284.287.288.286&slist=36.286&opts=so-AD.gb-XX.nos.
my $criteria   = '376';
#my $criteria   = '{\'' . $omf{$olid}{AQuickStatus} . '\'.XCT.\'dead\'}';
#$criteria     .= 'AND{\'' . $omf{$olid}{DNUC} . '\'.XEX.\'0\'}';
#$criteria     .= 'AND{\'' . $omf{$olid}{CLU} . '\'.EX.\'\'}';
#$criteria     .= 'OR{\'' . $omf{$olid}{DueDate} . '\'.OBF.\'Today\'}';
print "$criteria\n" if $action eq 'test';
my $sortfields = $omf{$olid}{$fields[0]};
my $options    = "sortorder-A";

# Do the deed here
if ( my @res = $qdb->doQuery (
    $olid, 
    $criteria,
    #$get_these_fields,
    #$sortfields,
    #$options, 
    ) ) {
  print "Returned " . scalar @res . " records\n" if $action eq 'test'; 
  my ( %record, $wrapper );

  foreach my $rec ( @res ) {
    print ( sprintf ( "%3d) ", $a ) ) if $action eq 'test';

    foreach ( @fields ) {
      $record{$_} = $rec->{$_};

      if ( $record{$_} =~ /,/g ) {
        $wrapper = '"';
      } else {
        $wrapper = '';
      }
      print "$wrapper$record{$_}$wrapper," unless $_ eq $fields[$#fields] and print "$wrapper$record{$_}$wrapper\n";
    }
    $a++;
  }
} else {
  print "$qdb->error()\n";
  print "$qdb->errortext()\n";
}