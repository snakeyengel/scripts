#!c:/perl/bin/perl.exe
use strict;
use warnings;
no warnings 'uninitialized';
my $fileout = "c:/scripts/formatted.txt";
my ($name, $date, $text1, $text2);
$name = "Eric Young";
$date = "April 17, 2009";
$text1 = "This is some text that I feel like writing here to test out the formatting of text for use in forms and such things as that.";
$text2 = "as;lkja sd;lk a;sdlkjf ;ql;la ;slksdjf; l;aosidf;l kj;;alsdf' a;sdlfasldjf lja;lskdj;lfkaj ;lasjd ;lfkajos;;l ds;la;ls ;lask d;l ;l ;lakj s;dlfkj ;lak js;fl ;alskd f;l a;ls ;lasdkj f;lakjs d;lkja ;slkjf a;lskdjf;laksjdf ;kah sdfiuqoweiur qlkdjh lakjsdf oiquye ;kajsdf ;lkadsf;qiwpofa ;ldfkjqpoifj a;sldkfja;";
open FILEOUT, ">$fileout" or die "Couldn't open $fileout for writing: $!";

format FILEOUT_TOP =
                          Report from Nowhere
Name          Date           Text1                Text2
--------------------------------------------------------------------------------
.
format FILEOUT =
@<<<<<<<<<<<< @<<<<<<<<<<<<< ^<<<<<<<<<<<<<<<<<<~ ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<~
$name,        $date,         $text1,              $text2
                             ^<<<<<<<<<<<<<<<<<<~ ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<~
														 $text1,              $text2
                             ^<<<<<<<<<<<<<<<<<<~ ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<~
														 $text1,              $text2
                             ^<<<<<<<<<<<<<<<<<<~ ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<~
														 $text1,              $text2
                             ^<<<<<<<<<<<<<<<<<<~ ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<~
														 $text1,              $text2
                             ^<<<<<<<<<<<<<<<<<<~ ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<~
														 $text1,              $text2
                             ^<<<<<<<<<<<<<<<<<<~ ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<~
														 $text1,              $text2
                             ^<<<<<<<<<<<<<<<<<<~ ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<~
														 $text1,              $text2
                             ^<<<<<<<<<<<<<<<<<<~ ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<~
														 $text1,              $text2
                             ^<<<<<<<<<<<<<<<<<<~ ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<~
														 $text1,              $text2
                             ^<<<<<<<<<<<<<<<<<<~ ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<~
														 $text1,              $text2
.
write FILEOUT;
close FILEOUT;