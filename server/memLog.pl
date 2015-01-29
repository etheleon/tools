#!/usr/bin/env perl

use strict;
use v5.18;
use autodie;
# capture the output of system command

die "$0 <processname> <uniqueIdentifier> <anti> <sleep> insufficient arguments" unless $#ARGV == 3;
my ($processname, $uniq, $anti, $sleep) = @ARGV;

my $cmd = qq(ps aux | grep -v "grep"| grep -v "perl" |);
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
    $ps  = `$cmd`;
    chomp($ps);
    my @columns = split /\s+/, $ps;
    say $columns[3],"%";
    sleep $sleep;
    my $ps  = `$cmd`;
}
