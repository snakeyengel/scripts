#!c:/perl/perl.exe
# AncientGreekFemale AncientGreekMale ArabicFemale ArabicLast ArabicMale BasqueFemale BasqueMale CelticFemale CelticMale EnglishFemale EnglishLast EnglishMale Female HindiFemale HindiMale JapaneseFemale JapaneseMale LatvianFemale LatvianMale Male ModernGreekFemale ModernGreekLast ModernGreekMale SpanishFemale SpanishLast SpanishMale ThaiFemale ThaiMale VikingFemale VikingMale
use strict;
use warnings;
my $namefile = "./names.txt";
my @types = qw(AncientGreekMale ArabicMale BasqueMale CelticMale EnglishMale HindiMale JapaneseMale LatvianMale Male ModernGreekMale SpanishLast SpanishMale ThaiMale VikingMale);
my (@names, $n, $usable, $group);
my $modname = "Data::RandomPerson::Names::";

for(my $x=0;$x<=$#types;$x++){
	&randy;
	eval "use $group;";
	$n = $group->new();
	for(my $i=0;$i<20;$i++){
		$usable = $n->get();
		$usable =~ s/([^a-zA-Z])//g;
		push(@names,$usable);
	}
}
open(NAMES, ">$namefile") or die "Couldn't write to file $namefile: $!";
foreach (@names){
	if($_ eq $names[$#names]){
		print NAMES "$_";
		#print "$_";
	} else{
		print NAMES "$_\n";
		#print "$_\n";
	}
}
close NAMES;

sub randy
{
	my $kind = int((rand($#types))+1);
	$group = $modname.$types[$kind];
	return $group;
}
