#!/usr/bin/perl
#
# OBEX server waiting for vcard, parsing
# the name, transform it to MCUF and send
# the message to a blinkenarea server
#
# Programmed by Bastian Ballmann
# http://www.datenterrorist.de
#
# License: GPL2
# Last update: 28.12.05 @ 22C3

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

# Application name
my $appname = "obexserver";


###[ MAIN PART ]###

logme($appname, "What's your message?");

# Parse Configfile
logme($appname, "Parsing configfile $cfgfile");
my $cfg = XMLin($cfgfile) or die "Cannot read config file $cfgfile!\n$!\n";

# Start SDP daemon
logme($appname, "Starting SDP daemon");
system("$cfg->{'exec'}->{'sdpd'}");

# Register OBEX Push protocol
logme($appname, "Register OBEX Push protocol on channel $cfg->{'obex'}->{'pushchannel'}";
system("$cfg->{'exec'}->{'sdptool'} add --channel=$cfg->{'obex'}->{'pushchannel'} OPUSH");

# Start obex server

logme($appname, "Start OBEX server");
open(OBEX, "$cfg->{'exec'}->{'obexserver'} |");

# Wait for files
while(<OBEX>)
{
	# Got new file?
	if($_ =~ //)
        {
           my $file = "";
           logme($appname, "Got new file $file");

           # Read file
           open(IN, "<$file") or logme("Cannot read file $file! $!");
           @file = <IN>;
           close(IN);

           # Check if it is a vcard
           if($file[2] =~ /BEGIN\:VCARD/)
           {
                  # Get the message
                  my $msg = "";

                  foreach my $line (@file)
                  {
                      if($line =~ /^F?N\:(.+)$/)
                      {
                         $msg = $1;
                      }
                  }

                  # Send the message to the blinkenarea server
                  send_msg($msg);
           }

           # Delete file
           logme("Delete file $file");
           unlink($file);
        }
}

close(OBEX);
logme($appname, "Killin stuff");
system("killall $cfg->{'exec'}->{'obexserver'}");
system("killall $cfg->{'exec'}->{'sdpd'}");
logme($appname, "*blink* *blink* bye");
