#!C:\perl\bin\perl
# Eric Young - February 2009
use Fcntl; #The Module
use warnings;
###########################################
# Structure of the BotProfile.db file:
#
# The Default Profile (dynamic)
# The Weapons Preferences Profiles (static)
# Template *name*
#		attribute = value
#	End
#	//-------------------------------
#	Skill Templates (dynamic)
#	Template Elite
#		attribute = value
#	End
#	//-------------------------------
#	Individual Bot Profiles grouped by skill level (dynamic)
#	Skill[+Profile] skillprefix_botname
#		attribute = value
#	End
###########################################
# Declared Variables and Arrays
system("\"C:\\scripts\\randompeeps.pl");
$bpdb = "C:/Program Files/Half Life 2/root/cstrike/BotProfile.db"; # What we read from to get names
$namefile = "C:/Program Files/Half Life 2/root/cstrike/names.txt"; # What we're writing to for names
$header1 = "C:/Program Files/Half Life 2/root/cstrike/header1.txt";
$header2 = "C:/Program Files/Half Life 2/root/cstrike/header2.txt";

# Template Hashes and Arrays

%prefix = ('Elite', 'EL_', 'Expert', 'EX_', 'VeryHard', 'VH_', 'Hard', 'HD_', 'Tough', 'TG_', 'Normal', 'NL_', 'Fair', 'FR_', 'Easy', 'EA_');
%quotas = ('Elite', '11', 'Expert', '10',  'VeryHard', '4',  'Hard', '14',  'Tough', '20', 'Normal', '22',  'Fair', '23',  'Easy', '36');
@order = qw(Elite Expert VeryHard Hard Tough Normal Fair Easy);
@profiles = qw(Rifle RifleT Punch PunchT Sniper Power Shotgun Spray); #The diff kinds of weapons that are "specified" in the profiles
%default = ('Skill', '40',	'Agression', '50', 'ReactionTime', '1.6', 'AttackDelay', '0.85',	'Teamwork', '60',	'WeaponPreference', 'none',	'Cost', '0', 'Difficulty', 'NORMAL', 'VoicePitch', '100', 'Skin', '0');
@Elite = qw(Template,Elite Skill,100 Aggression,100	ReactionTime,0.3 Cost,4	Difficulty,EXPERT	VoicePitch,40);
@Elite_Attr = qw(Skin VoicePitch);
@Expert = qw(Template,Expert Skill,80 Aggression,80 ReactionTime,0.4 Cost,4 Difficulty,EXPERT VoicePitch,50);
@Expert_Attr = qw(VoicePitch);
@VeryHard = qw(Template,VeryHard Skill,65	Aggression,65 ReactionTime,0.5 Cost,2 Difficulty,HARD VoicePitch,60);
@VeryHard_Attr = qw(Skin VoicePitch);
@Hard = qw(Template,Hard Skill,60	Aggression,60 ReactionTime,0.75 Cost,4 Difficulty,HARD VoicePitch,70);
@Hard_Attr = qw(Skin VoicePitch);
@Tough = qw(Template,Tough Skill,50 Aggression,50 ReactionTime,1 AttackDelay,0.75 Cost,1 VoicePitch,80 Difficulty,NORMAL+HARD);
@Tough_Attr = qw(Skin VoicePitch);
@Normal = qw(Template,Normal Skill,20 Aggression,20 ReactionTime,1.5 AttackDelay,1 Cost,1 VoicePitch,120 Difficulty,NORMAL);
@Normal_Attr = qw(Skin VoicePitch);
@Fair = qw(Template,Fair Skill,20 Aggression,20 ReactionTime,1.75 AttackDelay,1.5 Cost,1 VoicePitch,130 Difficulty,EASY+NORMAL);
@Fair_Attr = qw(VoicePitch);
@Easy = qw(Template,Easy Skill,0 Aggression,20 ReactionTime,1.75 AttackDelay,1.75 Cost,1 VoicePitch,140 Difficulty,EASY);
@Easy_Attr = qw(VoicePitch);
$comment = "//----------------------------------------\n";
%pitches;
my $total = 0;
foreach(values %quotas)
{
	$total = $total + $_;
}
	
# File Handles for writing stuff
open H1, $header1 or die "Cannot open $header1 for read :$!";
open H2, $header2 or die "Cannot open $header2 for read :$!";
@h1=<H1>; @h2=<H2>;
close(H1); close(H2);
if (!(open bpdb, "$bpdb")) {sysopen (bpdb, "$bpdb", O_RDWR|O_EXCL|O_CREAT, 0755) or die "Couldn't open $bpdb: $!";}
else {open (bpdb, ">$bpdb") or die "Couldn't open $bpdb: $!";}
open namefile, $namefile or die "Cannot open $namefile for read :$!";
while (<namefile>)
{
		push(@names, $_);
}
close namefile;
$tot_names = $#names; # how many names brought in.
$tot_prfxs = $#prefix; # how many prefixes there are.
$tot_profs = $#profiles; # how many types of profiles there are.
$outnum = $total;
@refill = @names;

print bpdb @h1;
print bpdb "\nDefault\n";
while (($k, $v)=each %default)
{
	print bpdb "\t$k = $v\n";
}
print bpdb "End\n\n$comment\n";
print bpdb @h2;
print bpdb "\n\n$comment//Skill Templates\n\n";
&templategen;
print bpdb "$comment//Individual Bot Profiles\n\n";
&botgen;
close bpdb;
$cnt = 0;
#foreach(@goodnames)
#{
#	$ln = $cnt + 1;
#	if($cnt==0){ print "$_";}
#	else {print "$_";}
#	$cnt++;
#}
#system("\"C:\\Program Files\\Half Life 2\\root\\hl2.exe\" -steamlocal -game cstrike");
#######################################################################
# Functions
#######################################################################
sub templategen
{
	foreach $tt (@order)
	{
		foreach(@{$tt})
		{
			($k,$v)=split /,/;
			print "\$k:$k, \$v:$v\n";
			if($k eq "Template")
			{
				print bpdb "$k $v\n";
			}
			else
			{
				if($k eq "VoicePitch")
				{
					$pitches{$tt} = $v;
				}
				print bpdb "\t$k = $v\n";
			}
		}
		print bpdb "End\n\n";
	}
}

sub botgen
{
	foreach (@order) # Set the templates and skills in proper order based on numeric key.
	{
		$pfx = $prefix{$_}; # Grabbing the type prefixes and assigning them to $pfx.
		$countdown = $quotas{$_}; # Reusing the $lookup value to see how many of what kind of bot to create
		print(bpdb "$comment//$_\n$comment");
		while($countdown > 0)
		{
			if($#names == 0){@names = @refill;$tot_names = $#names;}
			$xx = int(rand($tot_names)); #Random number between 0 and number of names
			$yy = int(rand($tot_profs +3));
			$holder = splice(@names, $xx, 1); # Grab random name and assign it to $holder var
			$holder = $pfx.$holder;
			if($_ eq "Easy" || $_ eq "Fair")
			{
				$holder = $_." ".$holder;
			}
			else
			{
				if($yy <= $tot_profs)
				{
					$holder = $_."+".$profiles[$yy]." ".$holder;
				}
				else
				{
					$holder = $_." ".$holder;
				}
			}
			$skin = int(rand(4)) + 1;
			$voice = int(rand(11)) + $pitches{$_} - 5;
			print(bpdb "$holder");
			foreach $attribs (@{$_."_Attr"})
			{
				if($attribs eq "Skin")
				{
					print(bpdb "\t$attribs = $skin\n");
				}
				else
				{
					print(bpdb "\t$attribs = $voice\n");
				}
			}
			print(bpdb "End\n\n");
			push(@goodnames, $holder); # otherwise, just push the name into the list of usable names.
			$tot_names--;
			$countdown--;
		}
	}
}
