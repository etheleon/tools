#!/usr/bin/env perl

use v5.20;
use experimental        'signatures';
use List::MoreUtils     'uniq';

die "USAGE: $0 fastqDIR outputDIR\n" unless $#ARGV == 1;

=pod

=head1 DESCRIPTION

This script has positional 2 arguments.

B<fastqDIR> : Path to folder containing only the fasta.gz files. to be trimmed.

B<outputDIR>: Path to the output folder to store the trimmed fasta.gz files.

It will print the commands neccessary to run Trimmomatic

NOTE: Edit please edit the command to run Trimmomatic to suit your system ie. Path to jar and Trimmomatic's arguments.

=cut




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
        (split(/\//, $input[$_]))[-1] =~ s|^(?<fileName>.*)\.fastq\.gz$|$ARGV[1]/$+{fileName}|r
    } 0..1;

    $command =~ s|read1|$input[0]|;
    $command =~ s|read2|$input[1]|;
    $command =~ s|output1|$output[0]|g;
    $command =~ s|output2|$output[1]|g;
    say $command;
}

__DATA__
java -jar ~/Documents/software/Trimmomatic-0.33/trimmomatic-0.33.jar PE -phred33 read1 read2 output1_ofp.fastq.gz output1_orp.fastq.gz output2_ofp.fastq.gz output2_orp.fastq.gz LEADING:2 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:75"
