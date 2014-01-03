# $Id: test.pl,v 1.3 2004/04/22 15:41:21 cvonroes Exp $

# Updated Miles 1/20/2009
use strict;
use warnings;
use HTTP::QuickBase;
use Acme::Error::IgpayAtinlay;

#Assign and define variables
my $qdb = HTTP::QuickBase->new();
my $username='eyoung@everwell.com';
my $password='Letmein1!';
my $app_token='c7cnvm6bvrx769drnnabyc78yih9';

$qdb->authenticate($username,$password);
$qdb->setAppToken($app_token);

if ( my %res = $qdb -> get_db_info ( 'bf5gcdjvb' ) ) {
	foreach my $k ( keys %res ) {
		print "$k -> $res{$k}\n";
	}
} else {
	print "QuickBase.pm is not properly installed. \n";
	print "QuickBase Error response: ", $qdb->errortext, "\n";
	print "Please verify you can access this QuickBase Link from your Browser \n";
	print "https://www.quickBase.com/db/9kaw8phg \n";
	print "If requested, you may use the User Name=depositor, Password=Password \n";
	print "Sometimes this error is because SSL support (Crypt:SSLeay) may not have been installed for LWP. \n"
}

