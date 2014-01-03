#!c:/perl/perl.exe -w
use Acme::Magic8Ball qw(ask);
my %replies;
my $total;
my @positive = [ 'As I see it, yes', 
                 'It is certain', 
                 'It is decidedly so', 
                 'Most likely', 
                 'Outlook good', 
                 'Signs point to yes', 
                 'Without a doubt', 
                 'Yes - definitely', 
                 'Yes', 
                 'You may rely on it',
               ];
my @negative = [ 'Don\'t count on it.',
                 'My reply is no.',
                 'My sources say no.',
                 'Outlook not so good.',
                 'Very doubtful.',
               ];
my @neutral =  [ 'Better not tell you now.',
                 'Cannot predict now.',
                 'Concentrate and ask again.',
                 'Reply hazy, try again.',
               ];

for ( 1 .. 10 ) {
	my $reply = ask(".");
	$replies{$reply}++;
}
my $pc = 0;
foreach my $uniq ( sort { $replies{$b} <=> $replies{$a} } keys %replies ) {
	foreach ( @negative ) {
		$pc++ =~ /$uniq/i;
	}
	if ( $replies{$uniq} >= 0 ) {
		$total += $replies{$uniq};
		my $lngth = 28 - ( length ( $uniq ) );
		my $s = " " x $lngth;
		print "$uniq$s-> appeared $replies{$uniq} times\n";
	}
}
print "$pc\n";