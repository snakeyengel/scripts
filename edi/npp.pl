#!c:/perl/perl.exe -w
use warnings;
use strict;
##if (!@ARGV){
##	print "\n\nUsage is:\nnpp.pl \"NAME OF EDI FILE\"\n\n"; exit;
##}
my $infile = "AG403.txt";
#chomp($infile = shift @ARGV); # "AG403.txt";
my $outfile = $infile;
$outfile =~ s/^(\w+?)\.{1}\w+?$/$1/;
$outfile .= "_subout.txt";
my @dest;
my $div = "----------------------------------\n";
my $sum = 0; # 0=Full Report, 1=Summary Report, 2=LPN's and Customer, 3=Short Summary Report (Totals by Customer)
my $cntr  = 1;
my $cntr2 = 2;
my $cntr3 = 3;

# sample of header
#...................................................................................................1.........1.........1.........
#.........1.........2.........3.........4.........5.........6.........7.........8.........9.........0.........1.........2.........
#123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
#|   |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |
#0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
#11T00001EMBARC10100314060942001N2KRUGER - CORNER BROOK              CUSTOMER MANIFEST DATA                                      
#11M000021U040590        031406108356    108356    18ALIDA GORT                    GRTH         11056                 N2N20916   
# 2A00003SCRIPPS TREASURE COAST P                695 NW ENTERPRISE DRIVE                                                         
# 2B00004                                        PORT ST. LUCIE FLORIDA UNITED STATES     34986                                  
# 2C00005Mid-Florida Freezer Whse            CAPE CANAVERAL                                               GRTH U040590           
# 3A00006SCRIPPS TREASURE COAST P                695 NW ENTERPRISE DRIVE                                                         
# 3B00007                                        PORT ST. LUCIE FLORIDA UNITED STATES     34986                                  
# 3C00008PALM BEACH NEWSPAPERS                                                                                                   
# 4M00009MRFP201WHIT     457          ST LUCIE-03    U040590     SNW488              457       0488 F0000635001270000000000015000
# 4D00010OFFSET NEWSPRINT                                  WHITE                                                                 
# 5M00011N20P20B161G       2010148860048100000481N20P20B162G       5010151960048200000482N20P20B261G       2010152580048100000481
# 5M00092N20P26A042E       1010160340100400001004N20P26A042J       1010160340100800001008                   000000000000000000000
# 6M000930000001550000001550015589000000001558900248450200000000RST LUCIE-03                     SNW488                          
#19M0009400000002030093001951990000000000195199                                                                                  
# 9T00095EMBARC10100314060942001N2KRUGER - CORNER BROOK              CUSTOMER MANIFEST DATA00095                                 
open(OFILE, ">$outfile") or die "Couldn't open file $outfile for writing: $!";
open(EDI, "$infile") or die "Couldn't open file $infile: $!";
while (<EDI>)
{
	if(/^11T/){ # First Line of EMBARC EDI per customer
		my $cntrl = substr $_, 0, 1; # Control number
		my $trname = substr $_, 8, 6; # Transmission Name
		my $rlse = substr $_, 14, 2; # Release - dec is implied. 1.0 for 128byte or 1.1 for 80byte
		my $mm = substr $_, 18, 2; # Transmission month
		my $dd = substr $_, 20, 2; # Transmission day
		my $yy = substr $_, 22, 2; # Transmission year
		my $ttch = substr $_, 24, 2; # Transmission hour
		my $ttcm = substr $_, 26, 2; # Transmission minute
		my $rtn = substr $_, 28, 3; # Receiver's Transmission number
		my $cmpcd = substr $_, 31, 2; # Company Code
		my $cmpnam = substr $_, 33, 35; # Company Name
		my $trdesc = substr $_, 68, 22; # Transmission Description
		if($sum!=3){
		print OFILE "Control #:\t\t$cntrl\nTransmission Name:\t\t$trname\nRelease (1.0 for 128 or 1.1 for 80):\t$rlse\nDate and time of creating:\t\t$mm/$dd/$yy \@ $ttch:$ttcm\n";
		print OFILE "Receiver's Transmission #:\t\t$rtn\nCompany Code:\t\t$cmpcd\nCompany Name:\t\t$cmpnam\nTransmission Description:\t\t$trdesc\n$div";
		}
	}
	if(/^11M/){ # 2nd line of EDI per customer
		my $trc = substr $_, 8, 1; # Transaction Code
		if ($trc eq 1) {$trc .= " New";}
		elsif ($trc eq 2) {$trc .= " Replace";}
		else {$trc .= " Cancel";}
		my $mannum = substr $_, 9, 15; # Manifest Number
		my $mmm = substr $_, 24, 2; # Manifest Creation or Release month
		my $mdd = substr $_, 26, 2; # Manifest Creation or Release day
		my $myy = substr $_, 28, 2; # Manifest Creation or Release year
		my $sldtcc = substr $_, 30, 10; # Sold-To Customer Code
		my $shtcc = substr $_, 40, 10; # Ship-To Customer Code
		my $tti = substr $_, 50, 1; # Transmit-To Indicator (1=Sold To, 2=Ship To, 3=1 and 2, 4=End User (publisher), 5=1 and 4, 6=2 and 4, 7=1, 2 and 4)
		my $trmde = substr $_, 51, 1; # Transportation Mode
		my $fvnum = substr $_, 52, 10; # First Vehicle Number
		my $secvn = substr $_, 62, 10; # Second VehNum or First Container Num
		my $scnum = substr $_, 72, 10; # Second Container Num
		my $scac = substr $_, 82, 4; # Standard Carrier Alpha Code
		print OFILE "Transaction #: $trc\nManifest #: $mannum\nManifest Release Date: $mmm/$mdd/$myy\nSold-To Customer Code: $sldtcc\nShip-To Customer Code: $shtcc\n";
		print OFILE "Transmit-To Indicator: $tti\nTransportation Mode: $trmde\nFirst Vehicle #: $fvnum\nSecond Vehicle #\nor First Container #: $secvn\nSecond Cont.#: $scnum\nStandard Carrier Alpha Code: $scac\n$div";
	}

	if(/^\W{1}2/){ # Second Section of EDI with Customer information
		if(/^\W{1}2A/){
			my $stl1 = substr $_, 8, 40; # Ship-To Line 1
			my $stl2 = substr $_, 48, 40; # Ship-To Line 2
			my $stl3 = substr $_, 88, 40; # Ship-To Line 3
			if(&check($stl1)){print OFILE "Ship To: $stl1\n";}
			if(&check($stl2)){print OFILE "Ship To: $stl2\n";}
			if(&check($stl3)){print OFILE "Ship To: $stl3\n";}
		}
		if(/^\W{1}2B/){
			my $stl4 = substr $_, 8, 40; # Ship-To Line 4
			my $stl5 = substr $_, 48, 40; # Ship-To Line 5
			my $stl6 = substr $_, 88, 40; # Ship-To Line 6
			if(&check($stl4)){print OFILE "Ship To: $stl4\n";}
			if(&check($stl5)){print OFILE "Ship To: $stl5\n";}
			if(&check($stl6)){print OFILE "Ship To: $stl6\n";}
		}
		if(/^\W{1}2C/){
			my $rdesc = substr $_, 8, 97; # Route Description
			my $rcode = substr $_, 105, 5; # Route Code
			my $finvnum = substr $_, 110, 10; # Freight Invoice Number
			if(&check($rdesc)){print OFILE "Route Description: $rdesc\n";}
			if(&check($rcode)){print OFILE "Route Code: $rcode\n";}
			if(&check($finvnum)){print OFILE "Freight Invoice #: $finvnum\n";}
			print OFILE "$div";
		}
	}
	if(/^\W{1}3/){
		if(/^\W{1}3A/){
			my $stl1 = substr $_, 8, 40; # Sold-To Line 1
			my $stl2 = substr $_, 48, 40; # Sold-To Line 2
			my $stl3 = substr $_, 88, 40; # Sold-To Line 3
			if(&check($stl1)){print OFILE "Sold To: $stl1\n";}
			if(&check($stl2)){print OFILE "Sold To: $stl2\n";}
			if(&check($stl3)){print OFILE "Sold To: $stl3\n";}
		}
		if(/^\W{1}3B/){
			my $stl4 = substr $_, 8, 40; # Sold-To Line 4
			my $stl5 = substr $_, 48, 40; # Sold-To Line 5
			my $stl6 = substr $_, 88, 40; # Sold-To Line 6
			if(&check($stl4)){print OFILE "Sold To: $stl4\n";}
			if(&check($stl5)){print OFILE "Sold To: $stl5\n";}
			if(&check($stl6)){print OFILE "Sold To: $stl6\n";}
		}
		if(/^\W{1}3C/){
			my $rdesc = substr $_, 8, 120; # Special Marks or Handling Instructions
			print OFILE "Route Description: $rdesc\n";
		}
		print OFILE "$div";
	}
	if(/^\W{1}4/){
		if(/^\W{1}4M/){
			my $mefl = substr $_, 8, 1; # Metric/English Flag 'E' or 'M'
			my $bcu = substr $_, 9, 1; # Bar Coded Unit 'R':Roll, 'S':Skid, 'K':Case, 'C':Carton, 'P':Pallet, 'B':Bale
			my $rcstc = substr $_, 10, 2; # Roll Core/kid Type Code Roll Core Ex: 'FN'-Fiber/Notched,'FP'-Fiber/NotNotched,'MT'-MetalTipped,'MI'-MetalInsert,'IN'-Iron
																		# Skid type Examples: 'LG'-Leg,'RN'-Runner,'PL'-Plastic
			my $pic = substr $_, 12, 1; # Package Identification Code
			my $nipbcu = substr $_, 13, 2; # Number of Items per Bar Coded Unit (e.g., Rolls per Package)
			my $cc = substr $_, 15, 4; # Color Code
			my $coass = substr $_, 19, 5; # Caliper of a Single Sheet
			my $sonum = substr $_, 24, 13; #Shipping order num
			my $cponum = substr $_, 37, 15; # Customer Purchase Order Number
			my $bolnum = substr $_, 52, 12; # BOL
			my $stc = substr $_, 64, 20; # Stock Code Grade Codes, ex., SNW488 hehe
			my $minum = substr $_, 84, 10; # Mill Invoice Number
			my $bawe = substr $_, 94, 4; # Basis Weight ###V# or metric (g/m2)
			my $basc = substr $_, 98, 2; # Basis Size Code
			my $ww = substr $_, 100, 7; # Width IIInndd or metric (millimeters)
			my $losodor = substr $_, 107, 6; # Length of Sheets or Diameter of Rolls IInndd or metric (millimeters)
			my $olmor = substr $_, 113, 6; # Ordered Lineal Measure of Rolls ffffff or metric (meters)
			my $cid = substr $_, 119, 4; # Core Inside Diameter IIvII or metric (millimeters: no decimals)
			my $icw = substr $_, 123, 5; # Individual Core Weight ###V## or metric (grams)
			if(&check($mefl)){print OFILE "Metric/English Flag: $mefl\n"}
			if(&check($bcu)){print OFILE "Bar Coded Unit: $bcu\n";}
			if(&check($rcstc)){print OFILE "Roll Core/Skid Type Code Roll Core: $rcstc\n";}
			if(&check($pic)){print OFILE "Package Identification Code: $pic\n";}
			if(&check($nipbcu)){print OFILE "# of Items per BCU: $nipbcu\n";}
			if(&check($cc)){print OFILE "Color Code: $cc\n";}
			if(&check($coass)){print OFILE "Caliper of a single unit: $coass\n";}
			if(&check($sonum)){print OFILE "Shipping order #: $sonum\n";}
			if(&check($cponum)){print OFILE "Customer Purchase Order #: $cponum\n";}
			if(&check($bolnum)){print OFILE "BOL #: $bolnum\n";}
			if(&check($stc)){print OFILE "Stock Code Grade Codes: $stc\n";}
			if(&check($minum)){print OFILE "Mill Invoice #: $minum\n";}
			if(&check($bawe)){print OFILE "Basis Weight: $bawe\n";}
			if(&check($basc)){print OFILE "Basis Size Code: $basc\n";}
			if(&check($ww)){print OFILE "Width: $ww\n";}
			if(&check($losodor)){print OFILE "Length of Sheets or Diameter or Rolls: $losodor\n";}
			if(&check($olmor)){print OFILE "Ordered Lineal Measure of Rolls: $olmor\n";}
			if(&check($cid)){print OFILE "Core Inside Diameter: $cid\n";}
			if(&check($icw)){print OFILE "Individual Core Weight: $icw\n";}
			print OFILE "$div";
		}
		if(/^\W{1}4D/){
			my $gn = substr $_, 8, 50; # Grade Name
			my $cd = substr $_, 58, 10; # Color Description
			my $siiom = substr $_, 68, 60; # Special Item Information or Marks
			if(&check($gn)){print OFILE "Grade Name: $gn\n";}
			if(&check($cd)){print OFILE "Color Description: $cd\n";}
			if(&check($siiom)){print OFILE "Special Item Information or Marks: $siiom\n";}
			print OFILE "$div";
print OFILE <<LPNHEADER;
--------------------
| LPN Information  |
--------------------------------------------------------------------------------
    |                | Pkg  | # of   | # of   | Lineal  |       |       |      |
    |                | Id   | Rolls  | Splices| Meas/or | Grss  | Tare  | Invce|
Cnt.|     LPN #			 | Cd   | Pr Pkg | Per    | # Shts  | Wght  | Wght  | Wght |
--------------------------------------------------------------------------------
LPNHEADER
		}
	}
	if(/^\W{1}5/){
		if(/^\W{1}5M/){
			my $bcui = substr $_, 8, 18; # LPN#
			my $pic = substr $_, 26, 1; # Package Identification Code
			my $numrpp = substr $_, 27, 2; # # of Rools per Package
			my $numspp = substr $_, 29, 1; # Number of Splices per Package
			my $alm = substr $_, 30, 5; # Acutal Lineal Measure or Number of Sheets per Unit fffff or metric (meters)
			my $gw = substr $_, 35, 5; # Gross Weight #### or metric (kilograms)
			my $tw = substr $_, 40, 3; # Tare Weight ### or metric (kilograms)
			my $iw = substr $_, 43, 5; # Invoice Weight ##### or metric (kilograms)
			my $bcui2 = substr $_, 48, 18; # LPN#
			if($bcui2 =~ /^\W+$/){ $bcui2 = ''}
			my $pic2 = substr $_, 66, 1; # Package Identification Code
			my $numrpp2 = substr $_, 67, 2; # # of Rools per Package
			my $numspp2 = substr $_, 69, 1; # Number of Splices per Package
			my $alm2 = substr $_, 70, 5; # Acutal Lineal Measure or Number of Sheets per Unit fffff or metric (meters)
			my $gw2 = substr $_, 75, 5; # Gross Weight #### or metric (kilograms)
			my $tw2 = substr $_, 80, 3; # Tare Weight ### or metric (kilograms)
			my $iw2 = substr $_, 83, 5; # Invoice Weight ##### or metric (kilograms)
			my $bcui3 = substr $_, 88, 18; # LPN#
			if($bcui3 =~ /^\W+$/){ next;}
			my $pic3 = substr $_, 106, 1; # Package Identification Code
			my $numrpp3 = substr $_, 107, 2; # # of Rools per Package
			my $numspp3 = substr $_, 109, 1; # Number of Splices per Package
			my $alm3 = substr $_, 110, 5; # Acutal Lineal Measure or Number of Sheets per Unit fffff or metric (meters)
			my $gw3 = substr $_, 115, 5; # Gross Weight #### or metric (kilograms)
			my $tw3 = substr $_, 120, 3; # Tare Weight ### or metric (kilograms)
			my $iw3 = substr $_, 123, 5; # Invoice Weight ##### or metric (kilograms)
			format OFILE =
@>>> @<<<<<<<<<<<<<<<<< @     @<         @      @<<<<     @<<<<    @<<    @<<<<
$cntr, $bcui, $pic, $numrpp, $numspp, $alm, $gw, $tw, $iw
@>>> @<<<<<<<<<<<<<<<<< @     @<         @      @<<<<     @<<<<    @<<    @<<<<
$cntr2, $bcui2, $pic2, $numrpp2, $numspp2, $alm2, $gw2, $tw2, $iw2
@>>> @<<<<<<<<<<<<<<<<< @     @<         @      @<<<<     @<<<<    @<<    @<<<<
$cntr3, $bcui3, $pic3, $numrpp3, $numspp3, $alm3, $gw3, $tw3, $iw3
.
			write OFILE;
			$cntr += 3;
			$cntr2 += 3;
			$cntr3 += 3;
		}
		if (/^\W{1}5S/){
			my $mopm = substr $_, 8, 2; # Month of Paper Manufacture
			my $dopm = substr $_, 10, 2; # Day of Paper Manufacture
			my $yopm = substr $_, 12, 2; # Year "" "" ""
			my $mn = substr $_, 14, 2; # Machine Number
			my $rn = substr $_, 16, 5; # Reel Number
			my $sn = substr $_, 21, 4; # Set Number
			my $pos = substr $_, 25, 2; # Position
			my $nopam = substr $_, 27, 2; # Number of positions across machine
			my $shft = substr $_, 29, 1; # Shift
			my $susoc = substr $_, 30, 1; # Side Up/Side Out Code
			my %suc = ('F'=>'Felt', 'P'=>'Print', 'L'=>'Plain', 'C'=>'Coated', 'W'=>'Wire', 'E'=>'Embossed', 'R'=>'Profile', 'U'=>'Uncoated');
			foreach (keys %suc){
				/^\$susoc$/;
				$susoc = $susoc." ".$suc{$_};
			}
			my $mopm2 = substr $_, 8, 2; # Month of Paper Manufacture
			my $dopm2 = substr $_, 10, 2; # Day of Paper Manufacture
			my $yopm2 = substr $_, 12, 2; # Year "" "" ""
			my $mn2 = substr $_, 14, 2; # Machine Number
			my $rn2 = substr $_, 16, 5; # Reel Number
			my $sn2 = substr $_, 21, 4; # Set Number
			my $pos2 = substr $_, 25, 2; # Position
			my $nopam2 = substr $_, 27, 2; # Number of positions across machine
			my $shft2 = substr $_, 29, 1; # Shift
			my $susoc2 = substr $_, 30, 1; # Side Up/Side Out Code
			my %suc2 = ('F'=>'Felt', 'P'=>'Print', 'L'=>'Plain', 'C'=>'Coated', 'W'=>'Wire', 'E'=>'Embossed', 'R'=>'Profile', 'U'=>'Uncoated');
			foreach (keys %suc2){
				/^\$susoc2$/;
				$susoc2 = $susoc2." ".$suc2{$_};
			}
			my $mopm3 = substr $_, 8, 2; # Month of Paper Manufacture
			my $dopm3 = substr $_, 10, 2; # Day of Paper Manufacture
			my $yopm3 = substr $_, 12, 2; # Year "" "" ""
			my $mn3 = substr $_, 14, 2; # Machine Number
			my $rn3 = substr $_, 16, 5; # Reel Number
			my $sn3 = substr $_, 21, 4; # Set Number
			my $pos3 = substr $_, 25, 2; # Position
			my $nopam3 = substr $_, 27, 2; # Number of positions across machine
			my $shft3 = substr $_, 29, 1; # Shift
			my $susoc3 = substr $_, 30, 1; # Side Up/Side Out Code
			my %suc3 = ('F'=>'Felt', 'P'=>'Print', 'L'=>'Plain', 'C'=>'Coated', 'W'=>'Wire', 'E'=>'Embossed', 'R'=>'Profile', 'U'=>'Uncoated');
			foreach (keys %suc3){
				/^\$susoc3$/;
				$susoc3 = $susoc3." ".$suc3{$_};
			}
		}
	}
	if(/^\W{1}6/){
		if(/^\W{1}6M/){
			$cntr = 1;
			$cntr2 = 2;
			$cntr3 = 3;
			my $tus = substr $_, 8, 9; # Total Units Shipped
			my $trs = substr $_, 17, 9; # Total Rolls Shipped
			my $tgw = substr $_, 26, 8; # Total Gross Weight
			my $ttw = substr $_, 34, 5; # Total Tare Weight
			my $tiw = substr $_, 39, 8; # Total Invoice Weight
			my $tlm = substr $_, 47, 8; # Total Lineal Measure
			my $tsm = substr $_, 55, 8; # Total Square Measure
			my $bcu = substr $_, 63, 1; # Bar Coded Unit
			my $cpon = substr $_, 64, 20; # Consignee Purchase Order Number
			my $carn = substr $_, 84, 12; # Customer Accounts Receivable Number
			my $gc = substr $_, 96, 10; # Grade Code
			my $pui = substr $_, 106, 18; # Pallet Unit Identification
			print OFILE "$div";
			if(&check($tus)){print OFILE "Total Units Shipped: $tus\n";}
			if(&check($trs)){print OFILE "Total Rolls Shipped: $trs\n";}
			if(&check($tgw)){print OFILE "Total Gross Weight: $tgw\n";}
			if(&check($ttw)){print OFILE "Total Tare Weight: $ttw\n";}
			if(&check($tiw)){print OFILE "Total Invoice Weight: $tiw\n";}
			if(&check($tlm)){print OFILE "Total Lineal Measure: $tlm\n";}
			if(&check($tsm)){print OFILE "Total Square Measure: $tsm\n";}
			if(&check($bcu)){print OFILE "Bar Coded Unit: $bcu\n";}
			if(&check($cpon)){print OFILE "Consignee Purchase Order Number: $cpon\n";}
			if(&check($carn)){print OFILE "Customer Accounts Receivable Number: $carn\n";}
			if(&check($gc)){print OFILE "Grade Code: $gc\n";}
			if(&check($pui)){print OFILE "Pallet Unit Identification: $pui\n";}
			print OFILE "$div";
		}
	}
	if(/^19M/){
		my $tnsu = substr $_, 8, 10; # Total Number of Shipping Units
		my $tnrm = substr $_, 18, 4; # Total Number of Records in Manifest
		my $tgws = substr $_, 22, 8; # Total Gross Weight of Shipment
		my $ttws = substr $_, 30, 8; # Total Tare Weight of Shipment
		my $tiws = substr $_, 38, 8; # Total Invoice Weight of Shipment
		if(&check($tnsu)){print OFILE "Total Number of Shipping Units: $tnsu\n";}
		if(&check($tnrm)){print OFILE "Total Number of Records in Manifest: $tnrm\n";}
		if(&check($tgws)){print OFILE "Total Gross Weight of Shipment: $tgws\n";}
		if(&check($ttws)){print OFILE "Total Tare Weight of Shipment: $ttws\n";}
		if(&check($tiws)){print OFILE "Total Invoice Weight of Shipment: $tiws\n";}
		print OFILE "$div";
	}
	if(/^\W{1}9/){
		my $tn = substr $_, 8, 6; # Transmission Name
		my $rel = substr $_, 14, 2; # Release
		my $ver = substr $_, 16, 2; # Version
		my $mtc = substr $_, 18, 2; # Month Transmission Created
		my $dtc = substr $_, 20, 2; # Day Transmission Created
		my $ytc = substr $_, 22, 2; # Year Transmission Created
		my $ttcm = substr $_, 24, 4; # Time Transmission Created at Mill
		my $tnum = substr $_, 28, 3; # Transmission Number
		my $cc = substr $_, 31, 2; # Company Code
		my $cn = substr $_, 33, 35; # Company Name
		my $td = substr $_, 68, 22; # Transmission Description
		my $tldr = substr $_, 90, 5; # Total Logical Data Records
		if(&check($tn)){print OFILE "Transmission Name: $tn\n";}
		if(&check($rel)){print OFILE "Release: $rel\n";}
		if(&check($ver)){print OFILE "Version: $ver\n";}
		if(&check($mtc)){print OFILE "Month Transmission Created: $mtc\n";}
		if(&check($dtc)){print OFILE "Day Transmission Created: $dtc\n";}
		if(&check($ytc)){print OFILE "Year Transmission Created: $ytc\n";}
		if(&check($ttcm)){print OFILE "Time Transmission Created at Mill: $ttcm\n";}
		if(&check($tnum)){print OFILE "Transmission Number: $tnum\n";}
		if(&check($cc)){print OFILE "Company Code: $cc\n";}
		if(&check($cn)){print OFILE "Company Name: $cn\n";}
		if(&check($td)){print OFILE "Transmission Description: $td\n";}
		if(&check($tldr)){print OFILE "Total Logical Data Records: $tldr\n";}
		print OFILE "================================================================================\n\n";
	}
}
close EDI;
close OFILE;

sub check {
	my $test = shift;
	if ($test =~ /^\W+$/){
		print "Found a blanky!\n";
		return 0;
	}else{
		return $test;
	}
}