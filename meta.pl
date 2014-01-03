#!C:\Perl\bin\perl.exe
use warnings;
use strict;
use Acme::MetaSyntactic::any;
my @names = metaany( 50 );
foreach (@names){
print"$_\n";
}