#!C:\Perl\bin\perl.exe
use warnings;
use strict;
use Acme::Scurvy::Whoreson::BilgeRat;
my %ins;
my $insultgenerator = Acme::Scurvy::Whoreson::BilgeRat->new(
	language => 'lala'
);
for (my $x=0;$x<100;$x++){
	$ins{$insultgenerator} = $x;
}
my @srtd = sort{{$a}<=>{$b}} keys %ins;
for (my $y=0;$y<$#srtd+1;$y++){
	print $y+1 . " = $srtd[$y]\n";
}