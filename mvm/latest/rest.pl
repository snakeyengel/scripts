#!/usr/local/bin/perl

use strict;
use warnings;
use LWP;

my $browser = LWP::UserAgent->new;
my $url = 'http://unidb.org/private/math/math.html';

# Issue request, with an HTTP header
my $response = $browser->get($url,
	'User-Agent' => 'Mozilla/4.0 (campatible; MSIE 7.0)',
);
die 'Error getting $url' unless $response->is_success;
my $top = <<BOB;
Content-type:text/html\r\n\r\n
<!--************ Header for whole page *************-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
  <meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>Hey!</title>
</head>
<body>
<!--************************************************-->
BOB
print $top;
print 'Content type is ', $response->content_type . "\n";
print 'Content is:';
print $response->content . "\n";
print "</body></html>";