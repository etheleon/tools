#!/usr/bin/env perl

use strict;
use v5.18;
use autodie;
# capture the output of system command

die "$0 <processname> <uniqueIdentifier> insufficient arguments" unless $#ARGV == 0;

my $cmd = 'ps -aef | grep -v "grep"| grep -v "perl" | grep '.$ARGV[0];
my $ps  = `$cmd`; 
chomp($ps);
#say $ps;
#say 'true' if $ps ne '';
while($ps ne '') { 
    	# get the line about tomcat process
            my @vals = split /\s+/, $ps;
            my $mem_used_percent = $vals[3];
            say "$mem_used_percent";
	    sleep 60;
my $ps  = `$cmd`; 
    }
