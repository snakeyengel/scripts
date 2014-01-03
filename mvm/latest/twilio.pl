#!/usr/local/bin/perl
#!/usr/local/ActivePerl-5.10/bin/perl -s
#!C:\perl\bin\perl.exe
#
# twilio.pl
# 
# 
#
# Config start # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
use strict;
use warnings;
use WWW::Twilio::API;
use Config::Simple;

my $cfg       = new Config::Simple ( 'twilio.ini' );
my $sid       = $cfg->param ( 'sid' );
my $token     = $cfg->param ( 'token' );
my $sbox_num  = $cfg->param ( 'sbox_num' );
my $ver       = $cfg->param ( 'API_VERSION' );
my $email     = 'eyoung@everwell.com';
my $msg       = 'Please+tell+us+what+you+think+of+Tabasco+sauce';

my $twilio = WWW::Twilio::API->new( AccountSid   => $sid,
                                 AuthToken    => $token,
                                 API_VERSION  => $ver, );

my $response = $twilio->POST( 'SMS/Messages',
                              To    => '+13217040061',
                              From  => $sbox_num,
                              Body  => 'I really love to taste fruity pebbles '
                                     . 'and Tabasco sauce, hombre!', );


#my $response  = $twilio->POST( 'Calls',
#                               To    => '+13212504342',
#                               From  => $sbox_num,
#                               Url   => "http://twimlets.com/voicemail?"
#                                      . "Email=$email&Message=$msg", );

print STDERR $response->{content};