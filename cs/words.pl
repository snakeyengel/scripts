#!C:\Perl64\bin\perl.exe
use strict;
use warnings;
my $werds = new Silly::Werder;
use Silly::Werder;
my ($group, $usable, $n, $nn, $nlt, %names, $kind);
my $namefile = "./words.txt";
my $sylfile = "./syllables.txt";
my $outfile = "./names.txt";
my @types = qw(AncientGreekMale ArabicMale BasqueMale CelticMale EnglishMale HindiMale JapaneseMale LatvianMale Male ModernGreekMale SpanishLast SpanishMale ThaiMale VikingMale);
my $modname = "Data::RandomPerson::Names::";

for(my $x=0;$x<$#types;$x++){
	&randy;
	eval "use $group;";
	$n = $group->new();
	for(my $i=0;$i<10;$i++){
		$usable = $n->get();
		$usable =~ s/([^a-zA-Z])//g;
		$names{$usable} = $i;
	}
}
my @snames = sort (keys %names);
foreach (@snames){
    $nlt .= "$_ ";
    #print "$_\n";
}
$werds->build_grammar($nlt, 1, 1);
$werds->dump_grammar($namefile);
$werds->dump_syllables($sylfile);
$werds->load_grammar_file($namefile);
$werds->load_syllable_file($sylfile);
# Set the min and max # of syllables per werd
$werds->set_syllables_num(2, 4);
# End the sentences in a newline
$werds->end_with_newline(0);
# Generate a long random sentence calling as a class method
$werds->set_werds_num(120,120);
my @np = split(/ /,$werds->line);
open(OUTFILE, ">$outfile") or die "Couldn't write to file $outfile: $!";
foreach (@np){
    &uppity($_);
    if($_ ne $np[$#np]){
			print OUTFILE "$_\n";
			#print "$_\n";
		} else {
			print OUTFILE "$_";
			#print "$_";
		}
}
close OUTFILE;
close $namefile;
close $sylfile;
# All of the methods can be used as either class methods
# or object methods.
sub randy
{
	$kind = int(rand($#types));
	$group = $modname.$types[$kind];
	return $group;
}
sub uppity
{
    if(!/^\W$/){
		$_ = ucfirst $_;
		s/^(\w+?)[.|?|!]$/$1/;
		return $_;
		} else {
			return;
		}
}