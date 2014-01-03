#!/usr/local/bin/perl
#!/usr/local/ActivePerl-5.10/bin/perl -s
#!C:\perl\bin\perl.exe

################################################################################
# Config start # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
use strict;
use warnings;
use DateTime;
use DateTime::TimeZone;
use Date::Parse;

my %stamps = ( 
  1317528000000, '10-02-2011 12:00 AM',
  1326905374852, '01-18-2012 11:38 AM',
);

my $tz = DateTime::TimeZone->new ( name => 'America/New_York' );
my $dt = DateTime->now ( );
print time ( ) . "\n";
print $dt . "\n";
my $offset = $tz->offset_for_datetime ( $dt );
print "My current offset is $offset\n";
print my $at = time ( ) + $offset . "\n";
print DateTime->from_epoch( epoch => $at ) . "\n";
&timeWarp ( \%stamps );

sub timeWarp {
  my %ts = %{ shift ( ) };
  foreach my $stmp ( keys %ts ) {
    my $stamp = int ( $stmp / 1000 );
    my $dt = DateTime->from_epoch( epoch => $stamp );
    my $offset = $tz->offset_for_datetime ( $dt );
    $stamp += $offset;
    $dt = DateTime->from_epoch( epoch => $stamp );
    my $et = str2time($dt) + $offset;
    print "Stamp $stamp should resolve to $dt and be equal to $ts{$stmp}\n";
    print "I hope $et can phone home...\n";
  }
}