#!C:\perl\bin\perl.exe
################################################################################
# Config start # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

use strict;
use warnings;
use Data::Dumper;

# General var and val declarations
my ( $message, 
     $email, $subject, $from, $body, $encoding,
     $lhb, $mednum, $group, $to_address, $from_address,
     $mail_host, 
     %record_data, );

my %months = qw( Jan 01
                 Feb 02 
                 Mar 03 
                 Apr 04 
                 May 05 
                 Jun 06 
                 Jul 07 
                 Aug 08 
                 Sep 09 
                 Oct 10 
                 Nov 11 
                 Dec 12 );
                 
my @record_fields = ( 'Related Location', 'Summary',
                      'Down in Manager?', 'Last Heartbeat' );

chomp ( $message = $ARGV[0] ) unless ( scalar @ARGV == 0 ) and die 
    "\nCan't take an action without an argument... $!\nProper usage is:\n\n\t$0 [argument]\n\n";

%record_data = ( 'action',  $message,
                 'payload', 'This is a payload.');

&takeAction ( \%record_data );

# SUBS Go below ######################################################
sub takeAction {
	my %a = %{(shift)};

	my %actions = (
		"email_log"  => '&sendEmail( $a{payload} )',
		"rotate_log" => '&rotateLog',
	);

  if ( exists $actions{ $a {action} } ) {
    eval ( $actions{$a{action}} );
  } else {
    die "\n$a{action} is not a recognized argument.\n";
  }
}

sub sendEmail {
	my $b = shift;
	print $b . "\n";
}

sub rotateLog {
	print "Release the logs!\n";
}