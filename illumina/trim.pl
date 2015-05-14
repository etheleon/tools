#!/usr/bin/env perl

use v5.20;
use experimental 'signatures';
use List::MoreUtils 'uniq';

die "$0 fastq.gzDIR outputDIR\n" unless $#ARGV == 1;
$ARGV[0] =~ s/\/*$//g;

my $command = <DATA>;
chomp $command;

writeTrim($_, $command) for
    uniq
    map { s|_R\d_|_readNum_|r }
        <"$ARGV[0]/*">;

sub writeTrim ($sample, $command)
{
    my @input  = map {$sample=~s|readNum|$_|r} qw|R1 R2|;
    my @output = map {
        (split(/\//, $input[$_]))[-1] =~ s|^(.*)\.fastq\.gz$|$ARGV[1]/$1|r
    } 0..1;
    $command =~ s|read1|$input[0]|x;
    $command =~ s|read2|$input[1]|x;
    $command =~ s|output1|$output[0]|gx;
    $command =~ s|output2|$output[1]|gx;
    say $command;
}

__DATA__
java -jar ~/Documents/software/Trimmomatic-0.33/trimmomatic-0.33.jar PE -phred33 read1 read2 output1_ofp.fastq.gz output1_orp.fastq.gz output2_ofp.fastq.gz output2_orp.fastq.gz LEADING:2 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:75"

