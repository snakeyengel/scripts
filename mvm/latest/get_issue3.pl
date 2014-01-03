#!/usr/local/bin/perl

# CTS Service Desk single issue script:
# It collects and then parses the output from SD very nicely.

# Config start # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#BEGIN {
#  my $b__dir = ( -d '/home/ab5082/perl' ? '/home/ab5082/perl' : ( getpwuid($>) )[7].'/perl' );
#    unshift @INC, $b__dir.'/lib', map { $b__dir . $_ } @INC;
#}

# Module calls
use strict;
use warnings;
use XML::Simple;
use LWP::Simple;
use Config::Simple;
use Data::Dumper;

# Variable declarations
my $cfg          = new Config::Simple ( '/home/ab5082/cts.ini' );
#my $userName     = $cfg->param( 'userName' );
#my $password     = $cfg->param( 'password' );
my $userName     = 'Everwell.Eric.Young';
my $password     = 'Letmein1!';
my ( $buffer, %form, $nameIssue, $ticketIssue );

if ( $ENV{'REQUEST_METHOD'} =~ /^GET$/i ) {
  $buffer = $ENV{'QUERY_STRING'};

  my @pairs = split( /&/, $buffer );

  foreach my $pair ( @pairs ) {
    my ( $n, $v );
    ( $n, $v ) = split( /=/, $pair );
    $v =~ tr/+/ /;
    $v =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
    $v =~ s/<!--(.|\n)*-->//g;
    $form{$n} = $v;
  }

} else {
 
  read( STDIN, $buffer, $ENV{'CONTENT_LENGTH'} );
  my @pairs = split( /&/, $buffer );
  
  foreach my $pair ( @pairs ) {
    my ( $n, $v );
    ( $n, $v ) = split( /=/, $pair );
    $v =~ tr/+/ /;
    $v =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
    $v =~ s/<!--(.|\n)*-->//g;
    $form{$n} = $v;
  }
}

if ( $form{ticket} ) {
  $ticketIssue = $form{ticket};
} else {
  $ticketIssue = "U43709";
}
my $urlIssue       = 'http://sd.core-techs.com/everwell/everwell.asmx/GetIssue';
   $urlIssue      .= '?userName='. $userName . '&password=' . $password . '&ticket=' . $ticketIssue;
my $stuffIssue     = get $urlIssue or die "Couldn't get $urlIssue: $!\n";
my $xmlIssue       = new XML::Simple;
my $dataIssue      = $xmlIssue->XMLin( $stuffIssue );
my $returnedIssue  = $xmlIssue->XMLin( $dataIssue->{content} );
my %ticketIssue    = %{$returnedIssue->{UDSObject}};
my $ctr            = 0;
my ( $class, $rclass, $arclass, $flag, %item, );
my @namesIssue = ( 
              "ISSUE",
              "Event Date",
              "Summary",
              "Site Status",
              "Check In",
              "Check Out",
              "Site Notes",
              "Description",
              "Location",
              "City",
              "State",
              "Location TZ",
              "Category",
              "Comp. w/except.",
              "Release Num",
              "Location Type",
              "Status",
              "Open Date",
            );
#             "Ext. Ref Num",
#             "Client Status",
#             "Except. Code",
#             "Except. Detail",
#             "Project",
#             "Project Name",

# Start of Program
my %hnamesIssue;
my @tnamesIssue = @namesIssue;
foreach ( @tnamesIssue ) {
  my $anameIssue = $_;
  s/ /_/g;
  $hnamesIssue{$anameIssue} = $_;
}

foreach my $nme ( @namesIssue ) {
  foreach my $aray ( @{$ticketIssue{Attributes}{Attribute}} ) {
    if ( ( ${$aray}{AttrName} eq $nme ) and ( ref( ${$aray}{AttrValue} ) ne 'HASH' ) ) {
        $item{$nme} = ${$aray}{AttrValue};
    }
  }
}

my $cin = $item{'Check In'} ? $item{'Check In'} : 0;
my $cout = $item{'Check Out'} ? $item{'Check Out'} : 0;
my $top = <<BOB;
Content-type:text/html\r\n\r\n
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
  <meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>CTS#: $ticketIssue</title>
  <script type="text/javascript" src="../private/get_issue2.js"></script>
	<link rel="stylesheet" type="text/css" href="../private/get_issue_style.css" />
</head>
<body onload=\"doTheMath('$cin','$cout')\">
BOB

#print Dumper ( $item );
print $top;
print "<div id=\"closer\" onClick=\"window.close();state=0;tn=null;\"></div>\n";
print "<div id=\"length\"></div>\n";
print "<div id=\"main\">\n";
print   "\t<table id=\"ticket\">\n",
          "\t\t<tr>\n",
            "\t\t\t<th>Name</th>\n",
            "\t\t\t<th>Value</th>\n",
          "\t\t</tr>\n";

foreach my $name ( @namesIssue ) {
  my ( $key, $value, $iname );
  while ( ($key, $value ) = each %item ) {
    if ( $key eq $name ) {
      $iname = $hnamesIssue{$name};
      print &doIt( $key, $value, $iname );
    }
  }
}

print   "\t</table>\n";
print "</div>\n";
print "</body>\n</html>\n";

sub doIt {
  my ( $key, $value, $iname ) = @_;
  my $output;
  if ( $key =~ /(ISSUE|Site Status|Summary|Event Date)/ ) {
    $output = &classy( "bold-n-sassy", $key, $value, $iname );
  } elsif ( $key eq "Description" ) {
    $output = &classy( "hide-n-seek", $key, $value, $iname );
  } elsif ( $key eq "Check Out" ) {
    $output = &classy( "info", $key, $value, $iname );
  } else {
    $output = &classy( "plain-jane", $key, $value, $iname );
  }
  return $output;
}

sub classy {
  my $op;
  my ( $type, $key, $value, $iname ) = @_;
  if ( $type eq "bold-n-sassy" ) {
    $class   = "bld";
    $rclass  = "show";
    $arclass = "showalt";
  } elsif ( $type eq "hide-n-seek" ) {
    $class   = "nrml";
    $rclass  = "hide";
    $arclass = "hidealt";
    $flag    = 1;
  } elsif ( $type eq "plain-jane" ) {
    $class   = "nrml";
    $rclass  = "show";
    $arclass = "showalt";
  } elsif ( $type eq "info" ) {
    $class   = "info";
    $rclass  = "show";
    $arclass = "infoalt";
  }
  
  if ( $ctr % 2 == 0 ) {

    if ( $flag ) {

      $op  = "\t\t<tr class=\"$rclass\">\n";
        $op .= "\t\t\t<td colspan=\"2\" onClick=\"showHide()\" class=\"$class\" id=\"$iname\">";
        $op .= "<span class=\"showhide\">$key</span>";
        $op .= "</td>\n";
      $op .= "\t\t</tr>\n";

      $op .= "\t\t<tr class=\"$rclass\" id=\"showhide\">\n";
        $op .= "\t\t\t<td colspan=\"2\" class=\"special\" id=\"".$iname."2\">";
        $op .= $value;
        $op .= "</td>\n";
      $op .= "\t\t</tr>\n";

      $flag = 0;
      $ctr++;

    } else {

      $op  = "\t\t<tr class=\"$rclass\">\n";
        $op .= "\t\t\t<td class=\"$class\" id=\"$iname\">";
        $op .= $key;
        $op .= "</td>\n";

        $op .= "\t\t\t<td class=\"$class\" id=\"".$iname."2\">";
        $op .= $value;
        $op .= "</td>\n";
      $op .= "\t\t</tr>\n";

      $ctr++;

    }

  } else {

    if ( $flag ) {

      $op  = "\t\t<tr class=\"alt\">\n";
        $op .= "\t\t\t<td colspan=\"2\" onClick=\"showHide()\" class=\"$class\" id=\"$iname\">";
        $op .= "<span class=\"showhide\">Description</span>";
        $op .= "</td>\n";
      $op .= "\t\t</tr>\n";
      
      $op .= "\t\t<tr class=\"$arclass\" id=\"showhide\">\n";
        $op .= "\t\t\t<td colspan=\"2\" class=\"special\" id=\"".$iname."2\">";
        $op .= $value;
        $op .= "</td>\n";
      $op .= "\t\t</tr>\n";

      $ctr++;
      $flag = 0;

    } else {

      $op  = "\t\t<tr class=\"$arclass\">\n";
        $op .= "\t\t\t<td class=\"$class\" id=\"$iname\">";
        $op .= $key;
        $op .= "</td>\n";

        $op .= "\t\t\t<td class=\"$class\" id=\"".$iname."2\">";
        $op .= $value;
        $op .= "</td>\n";
      $op .= "\t\t</tr>\n";

      $ctr++;

    }

  }
  return $op;
}

1;
