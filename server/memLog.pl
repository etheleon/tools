#!/usr/bin/env perl

use strict;
use v5.18;
use autodie;
# capture the output of system command

die "$0 <processname> <uniqueIdentifier> <anti> insufficient arguments" unless $#ARGV == 2;
my ($processname, $uniq, $anti) = @ARGV;

my $cmd = qq(ps axww -o cmd,size | grep -v "grep"| grep -v "perl");
if($anti)
{
    $cmd .= qq(grep -v $uniq | grep $processname);
}else{
    $cmd .=  qq(grep $uniq | grep $processname);
}

my $ps  = `$cmd`;
chomp($ps);
say '#'.$ps;
while($ps ne '')
{
    $ps =~ m/\s(?<memusage>\d+)$/;  #in kilobytes
    say eval{ $+{memusage} / 1000000 },"G";
    sleep 60;
    my $ps  = `$cmd`;
}
