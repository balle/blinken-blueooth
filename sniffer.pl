#!/usr/bin/perl
#
# Bluetooth Sniffer that reacts on L2PING and 
# HCI Inquiry Scan packets and sends movies 
# to a blinkenarea server
#
# Programmed by Bastian Ballmann
# http://www.datenterrorist.de
#
# License: GPL2
# Last update: 23.11.05

###[ Loading modules ]###

use XML::Simple;
use strict;
require "blueblinklib.pl";


###[ Configuration ]###

# Configfile
my $cfgfile = "blueblink.conf";

# Bluetooth device
my $device = "hci0";
$device = $ARGV[0] if defined $ARGV[0];

# Event timeout (in seconds)
my $timeout = 30; # 900;

# Application name
my $appname = "sniffer";


###[ MAIN PART ]###

logme($appname, "Whazz up?");

# Parse Configfile
logme($appname, "Parsing configfile $cfgfile");
my $cfg = XMLin($cfgfile) or die "Cannot read config file $cfgfile!\n$!\n";

# Start sniffing
logme($appname, "Start sniffing on device $device");
sniff();
logme($appname, "*blink* *blink* bye");


###[ Subroutines ]###

# Endless but timeouted sniffing loop
sub sniff
{
   # Start sniffin
   open(HCI,"$cfg->{'exec'}->{'hcidump'} -i $device|") or die "hcidump: $!\n";

   # Endless working loop
   while(<HCI>)
   {
	# L2PING
	if($_ =~ /L2CAP\(s\)\: Echo req/ig)
        {
        	logme($appname, "L2PING");
		play_movie($cfg->{'defaultmovie'});
                play_movie($cfg->{'event'}->{'l2ping'});
                last;
        }
        
        # Inquiry scan
        elsif($_ =~ /HCI Command\: Inquiry \(0x01\|0x0001\)/ig)
        {
        	logme($appname, "INQUIRY SCAN");
		play_movie($cfg->{'defaultmovie'});
                play_movie($cfg->{'event'}->{'iscan'});
                last;
        }
   }

   close(HCI);
   logme($appname, "Paused");
   sleep $timeout;
   logme($appname, "Resume");
   sniff();
}
