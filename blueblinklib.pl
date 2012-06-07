#
# Blinken Bluetooth Library
#
# Programmed by Bastian Ballmann
# http://www.datenterrorist.de
#
# License: GPL2
# Last update: 28.12.05 @ 22C3

# Configuration
my $cfgfile = "blueblink.conf";
my $cfg = XMLin($cfgfile) or die "Cannot read config file $cfgfile!\n$!\n";

# Print a log message
# Parameter: appname, message
sub logme
{
   return 0 unless defined $_[1];

   # Write Logfile
   open(LOG,">>$cfg->{'logfile'}") or die "Cannot write to $cfg->{'logfile'}!\n$!\n";
   print LOG localtime(time) . " [$_[0]] $_[1]\n";
   print localtime(time) . " [$_[0]] $_[1]\n";
   close(LOG);
   return 1;
}

# Play the movie
# Parameter: movie file
sub play_movie
{
   return 0 unless defined $_[0];
   my $cmd = $cfg->{'exec'}->{'bsend'} . " " . $_[0] . " -h " . $cfg->{'server'} . ":" . $cfg->{'port'};
   logme("","Exec $cmd");
   system($cmd);
   return 1;
}

# Send a text message to a blinkenserver
# Parameter: String
sub send_msg
{
   return 0 unless defined $_[0];

   my $cmd = $cfg->{'exec'}->{'blprint'} . " 100 '" . $_[0] . "' | " . $cfg->{'exec'}->{'bsend'} . " -h " . $cfg->{'server'} . ":" . $cfg->{'port'} . " - ";
   logme("","Exec $cmd");
   system($cmd);

   return 1;
}

1;
