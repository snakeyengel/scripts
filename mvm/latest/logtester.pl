#!/usr/local/bin/perl
#!/usr/local/ActivePerl-5.10/bin/perl -s
#!C:\perl\bin\perl.exe

################################################################################
# Config start # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

use Logfile::Rotate;
my $log = new Logfile::Rotate( File   => 'alerts_log_safety', 
                               Count  => 7,
                               Gzip  => 'lib',
                               Flock  => 'yes',
                               Persist => 'yes',
                             );

# process log file 

$log->rotate();

#or

#my $log = new Logfile::Rotate( File  => '/var/adm/syslog', 
#                               Gzip   => '/usr/local/bin/gzip');

# process log file 

#$log->rotate();
undef $log;