#!C:\Perl\bin\perl.exe
# lzshipper.pl by Eric Young, April 2009
# a simple client using IO:Socket
#----------------
use warnings;
use strict;
use Net::Telnet;
use IO::Socket;

my ($hostname, $line, $passwd, $wims, $username);

$hostname = "ss-netops1.asi.local";
$username = "RF22";
$passwd = "159";

use Net::Telnet ();
$wims = new Net::Telnet (Telnetmode => 1);
$wims->open(Host => $hostname,
					 Port => 6666);

## Read connection message.
$wims->print("\n");
$line = $wims->getline;
#die $line unless $line =~ /^\+OK/;

## Send user name.
$wims->print("$username");
$line = $wims->getline;
#die $line unless $line =~ /^\+OK/;

## Send password.
sleep(1);
$wims->print("$passwd");
$line = $wims->getline;
#die $line unless $line =~ /^\+OK/;

## Request status of messages.
sleep(1);
$wims->print("1");
$line = $wims->getline;
#die $line unless $line =~ /^\+OK/;

$wims->print("POS920");
$line = $wims->getline;
#die $line unless $line =~ /^\+OK/;
print $line;
$line = $wims->getline;
#die $line unless $line =~ /^\+OK/;
print $line;
sleep(2);

exit;
