#!/usr/local/bin/perl
#!/usr/local/ActivePerl-5.10/bin/perl -s
#!C:\perl\bin\perl.exe
#
# 
# 
# 
#
# Config start # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
use strict;
use warnings;
use Acme::Playwright;

my $string = <<END_this;
I am writing some text that should be very very secret
and then that text will show up in a play that will be very
silly and funny, yeah???
END_this

my $play = Acme::Playwright::Make( $string );
print $play . "\n";
my $plaintext = Acme::Playwright::UnMake( $play );
print $plaintext . "\n";