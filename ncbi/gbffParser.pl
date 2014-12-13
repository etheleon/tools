#!/usr/bin/env perl

use strict;
use v5.18;

die "$0 <somefile.gbff.gz> <outputFile>\n" unless $#ARGV == 1;
my ($gb_file, $outputfile) = @ARGV;

open my $output,    ">", $outputfile;
open my $input,     "<", $gb_file;

$/ = '//'."\n";

my @lines;
while(<$input>)
{
    my ($displayID) = $_ =~ m/LOCUS\s+(\S+)/;
    @lines = ();
    @lines = split /\n/, $_;
    my $i = 0;
    foreach (@lines)
    {
        my %testing = findCDS($_);
        if ($testing{'retval'})	#if i find a CDS
        {
            my $gi = slurpblock($i);
            $testing{'result'} =~ m/(<|>)?(?<start>\d.*?)\.\.(<|>)?(?<end>\d+)/;
            say $output "$displayID\t$testing{'result'}\t$gi\t$+{start}\t$+{end}";
        }
        $i++;
    }
}

sub findCDS
{
    my ($string) = @_;
    my %hash;
    if ($string =~ m/^ {5}CDS {13}(?<location>\S+)/)
    {
        %hash = (result => $+{location}, retval => 1)
    }else{
        %hash = (retval => 0)
    }
    return %hash
}

sub slurpblock
{
    my ($lineNum) = @_;
    my $block = 1;
    $lineNum++;
    while($block)
    {
       if($lines[$lineNum] =~ m/ {21}\/db_xref="GI:(?<ncbiGI>\d+)"/)
       {
           $block = 0;
           return $+{ncbiGI};
       }elsif($lines[$lineNum] =~ m/^\S/)
       {
       	return "no gi";
       }
       else
       {
       $lineNum++;
       }
    }
}

#__END__
#NC_002689       1531469..1532638        13542330
