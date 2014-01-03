#!/usr/local/bin/perl
#!/usr/local/ActivePerl-5.10/bin/perl -s
#!C:\perl\bin\perl.exe
#
# twiliotest.pl
# 
# 
#
# Config start # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
use strict;
use warnings;
use WWW::Twilio::API;

my $twilio = WWW::Twilio::API->new( AccountSid   => 'ACb682d44659264111ac36de87841e3443',
                                 AuthToken    => '72b668eeace92bdb3ae55cb2b3a2c4c8',
                                 API_VERSION  => '2010-04-01' );

## A hollow voice says 'plugh'
my $response = $twilio->POST( 'Calls',
                              To    => '+13212504342',
                              From  => '+14155992671',
                              Url   => 'http://twimlets.com/message?'
                                     . 'Message%5B0%5D=plugh' );

print STDERR $response->{content};