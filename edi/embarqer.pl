#!c:/perl/perl.exe -w
use strict;
my $dir = "./";
my $infile = "AG403.txt";
my $outfile = "AG403_out.txt";
my @dest;

# sample of header
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
open(OFILE, ">$dir"."$outfile") or die "Couldn't open file $outfile for writing: $!";
open(EDI, "$dir"."$infile") or die "Couldn't open file $infile: $!";
while (<EDI>)
{
	if(/^11T/) # First Line of EMBARC EDI per customer
	{
		/^11T\d{5}([A-Z]+?)(\d{4})(\d{6})(\d{7})N2?(\w+\b)\W+(.+?)\W{2,}(.+)$/;
		# $1=EMBARC, $2=EDI#, $3=ClientID#, $4= UNKNOWN, $5=ClientName, $6=ClientLocation, $7=DocType
		print OFILE "$1 EDI#: $2\nClient ID#: $3\tUnknown #: $4\n$5, Located: $6\n$7\n----------------------------------\n";
	}
	if(/^11M/) # 2nd line of EDI per customer
	{
		/^11M\d{6}(\w+?)\W{2,}(\d{6})(\d{6})\W{2,}(\d{6})\W{2,}(\d{2})(.+?)\W{2,}(.+?)\W{2,}(.+?)\W{2,}N2N2(.+)$/;
		# $1=Cust.Man.#, $2=ClientID#, $3=$Cust.#, $4=Cust.#, $5=UnknownShipPrfx, $6=ShipName, $7=ShippingLine, $8=Voyage#, $9=Unknown#
		print OFILE "Customer Manifest#: $1\nClient Id#: $2\nCustomer#: $3 == $4\nUnkown Ship Prefix#: $5\nVessel: $6, of the $7 line, Voyage#: $8\nUnkown Suffix#: $9\n----------------------------------\n";
	}

	if(/^\W+?2/) # Second Section of EDI with Customer information
	{
		if(/^\W+?2A/)
		{
			/^\W+?2A+\d{5}(.+?)\W{2,}(.+)$/;
			push(@dest, ($1, $2));
		}
		if(/^\W+?2B/)
		{
			/^\W+?2B+\d{5}\W*?(.+?)\W{2,}(.+)$/;
			push(@dest, ($1, $2));
		}
		foreach my $daddy (@dest)
		{
			print OFILE "$daddy\n";
		}
		undef @dest;
		if(/^\W+?2C/)
		{
			/^\W+?2C+\d{5}(.+?)\W{2,}(.+?)\W{2,}(.+)$/;
			print OFILE "$1\n$2\n$3\n";
		}
	}
				
	if(/^[\W]+?3[A-Z]+[\d]{5}/)
	{
		/^[\W]+?3[A-Z]+[\d]{5}(.+)$/;
		print OFILE "$1\n";
	}

	if(/^[\W]+?4[A-Z]+[\d]{5}/)
	{
		/^[\W]+?4[A-Z]+[\d]{5}(.+)$/;
		print OFILE "$1\n";
	}

	if(/^\W+?5M\d{5}/)
	{
#		/^\W+?5M+\d{5}(N.+?)\W{2,}(\d+?)(N.+?)\W{2,}(\d+?)(N.+?)\W{2,}(\d+)$/;
		/^\W{1}5M\d{5}(N.+?)\W{2,}(\d+)(N.+?)\W{2,}(\d+)(N.+?)\W{2,}(\d+)$/;
		# $1=LPN#, $2=Attrib, $3=Nxt. LPN#, $4=Attrib, $5=Nxt. LPN#, #6=Attrib
		print OFILE "$1 $2\n$3 $4\n$5 $6\n";
	}

	if(/^\W+?9[A-Z]+\d{5}/)
	{
		print OFILE "================================================================================\n\n";
	}
}
close EDI;
close OFILE;	