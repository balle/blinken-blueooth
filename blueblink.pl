#!/usr/bin/perl
#
# Scan for bluetooth devices, get device type
# call a blinkenarea movie depending on the type
# or device name
#
# Programmed by Bastian Ballmann
# http://www.datenterrorist.de
#
# License GPL2
# Last update: 28.12.2005 @ 22C3

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

# Timeout in Sekunden zum resetten des %seen Hashes
my $timeout = 1380;

# Application name
my $appname = "scanner";


###[ MAIN PART ]###

logme($appname, "Let's see who's there");

# Remember seen devices
my %seen;

# Nur ein bloeder Counter
my $count = 0;

# Parse Configfile
logme($appname, "Parsing configfile $cfgfile");
my $cfg = XMLin($cfgfile) or die "Cannot read config file $cfgfile!\n$!\n";
logme($appname, "Start scanning on device $device");


# Endless working loop
while(1)
{
    # Scan for new devices
    open(HCI,"$cfg->{'exec'}->{'hcitool'} -i $device scan|") or die "$!\n";
    
    while(<HCI>)
    {
    	my ($addr,$host);
	my @tmp = split(/\s/,$_); 

	for(@tmp)
	{
	    next if $_ =~ /Scanning/;
	    if($_ =~ /\w\w\:\w\w\:\w\w\:\w\w\:\w\w\:\w\w/)
	    {
		$addr = $_;
	    }
	    elsif($_ =~ /\w+$/)
	    {
		$host = $_;
	    }
	}
	
	# Found a new device
	if( ($host ne "") && ($addr ne "") && (!defined $seen{$addr}) )
	{
            # Get device type
            open(INQ,"$cfg->{'exec'}->{'hcitool'} inq $addr|");
	    my $type = "1";
	    my $trash = "";

            while(<INQ>)
	    {
	    	if($_=~ /class\:\s(.+?)$/)
		{
            	   $type = $1;
		   $type =~ s/\s//g;
		   last;
		}
	    }

            close(INQ);

            # Remember it
	    $seen{$addr} = $type;

            # Log it
	    logme($appname, "Found host $host addr $addr type $type");

            # Play movie
            
            # Device name wins
            $host =~ s/\s//g;
            
            if($cfg->{'devicename'}->{lc($host)})
            {
	    	play_movie($cfg->{'defaultmovie'});
            	play_movie($cfg->{'devicename'}->{lc($host)});
            }
            
            # Handy
            elsif(($type =~ /204$/) || 
		  ($type =~ /3e0100/) || 
		  ($type =~ /520204/))
            {
            	play_movie($cfg->{'devicetype'}->{'handy'});
		send_msg("Found " . $host);
            }            

            # Laptop
            elsif(($type =~ /10c$/) || 
		  ($type =~ /114$/))
            {
            	play_movie($cfg->{'devicetype'}->{'laptop'});
		send_msg("Found " . $host);
            }

            # Anderer Geratetyp?
            else
            {
                $type =~ s/^0x//;
                $type =~ s/0//g;

            	if($cfg->{'devicetype'}->{$type} ne "")
                {
                   play_movie($cfg->{'devicetype'}->{$type});
                }
            }
	}
    }

    close(HCI);
    sleep 1;
    $count++;

    # Sollen die bekannten Devices vergessen werden?
    if($count == $timeout)
    {
       logme($appname, "Resetting known devices");
    }
}

logme($appname, "*blink* *blink* bye");

