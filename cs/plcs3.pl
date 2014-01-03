#!C:\Perl\bin\perl.exe
use warnings;
use strict 'subs';
system("\"C:\\scripts\\randompeeps.pl");
$bpdb = "C:/Program Files/Half Life 2/root/cstrike/BotProfile.db"; # What we read from to get names
$namefile = "C:/Program Files/Half Life 2/root/cstrike/names.txt"; # What we're writing to for names
$header1 = "C:/Program Files/Half Life 2/root/cstrike/header1.txt";
$header2 = "C:/Program Files/Half Life 2/root/cstrike/header2.txt";
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
$total = 0;
foreach(values %quotas)
{
	$total = $total + $_;
}
if (!(open BPDB, "$bpdb")) {sysopen (BPDB, "$bpdb", "O_RDWR"|"O_EXCL"|"O_CREAT", 0755) or die "Couldn't open $bpdb: $!";}
else {open (BPDB, ">$bpdb") or die "Couldn't open $bpdb: $!";}
print BPDB "\n\n$comment//Skill Templates\n\n";
&templategen;
close BPDB;

sub templategen
{
	foreach $tt (@order)
	{
		foreach(@{$tt})
		{
			($k, $v)=split /,/;
			print "\$k:$k, \$v:$v\n";
			if($k eq "Template")
			{
				print BPDB "$k $v\n";
			}
			else
			{
				if($k eq "VoicePitch")
				{
					$pitches{$tt} = $v;
				}
				print BPDB "\t$k = $v\n";
			}
		}
		print BPDB "End\n\n";
	}
}