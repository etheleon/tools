#!/usr/bin/env perl

use strict;
use v5.18;
use lib "/export2/home/uesu/perl5/lib/perl5";
use autodie;
use IO::File;
use Parallel::ForkManager;

die "USAGE: $0 <number of forks to use>\n" unless $#ARGV == 0;

my $refseqDB                              = '/export2/home/uesu/db/refseq/arch_prot';
my $keggDIR                               = '/export2/home/uesu/KEGG/KEGG_SEPT_2014';
my $dir                                   = '/export2/home/uesu/db/refseq/ko';
my %ncbi2ko;    #ncbi <-> ko hash table
my %kohash;

my $process_count = shift;
my $pm = new Parallel::ForkManager($process_count);


ko2gi();
main($pm);

sub main
{
    my $pm = shift;
    my @newfiles  = grep {!m/nonredundant/} <$refseqDB/*>;

    foreach (@newfiles)
    {

        $pm->start and next;
        ##################################################
        #-------------------------------------------------
        #parallelized Code
        m/\/
            (?<ncbiFile>[^\/]+)     #the filename without .gz
            \.faa\.gz$              #the file extensions
        /x;

        my $outputDIR = "$dir/".$+{ncbiFile};
        readGZ($_, $outputDIR);
        ##################################################
        $pm->finish;
    }
    $pm->wait_all_children;
}

sub readGZ
{
    my ($gzfna, $outputDIR) = @_;
    my %out;        #hash table to store the lexical KO filehandles
    mkdir $outputDIR unless -d $outputDIR;

    open my $in, "-|", "zcat $gzfna";
    my $contents = do { local $/; <$in> };
    my @seq = split /\>/, $contents;
    foreach my $sequence (@seq)
    {
        $sequence =~ m/^gi\|(?<ncbi>\d+)\|/;

        my $ko = $ncbi2ko{$+{ncbi}};
        if ($ko)   #if the gi is linked to a KO;
        {
            unless($out{$ko})
            {
               $out{$ko} = IO::File->new(">$outputDIR/$ko");
            }
            $out{$ko}->print(">$sequence");
        }
    }
}

sub ko2gi
{
say "Initialising..";
    open my $input, '<', "$keggDIR/genes/links/genes_ko.list";
    my %gene2ncbi;
    my %gene2ko;

    while(<$input>)
    {
        chomp;
        #hsa:100131801   ko:K18186
        my @a = split /\t/;
        $gene2ko{$a[0]} = $a[1];
    }
    close $input;

    open my $input2, '<', "$keggDIR/genes/links/genes_ncbi-gi.list";
    while(<$input2>)
    {
        chomp;
        #hsa:100125288   ncbi-gi:157266269
        my @a = split /\t/;
        $a[1] =~ s/^ncbi-gi\://;
        $gene2ncbi{$a[0]} = $a[1];
    }
    close $input2;

    foreach my $gene (keys %gene2ncbi)
    {
    my $ko = $gene2ko{$gene};
    $kohash{$ko}++;
    my $ncbi = $gene2ncbi{$gene};
        if($ko ne "")
        {
            $ncbi2ko{$ncbi} = $ko;
        }
    }
say "Loaded NCBI->KO hashtable\n\t# of keys:", scalar keys %ncbi2ko;
}

__END__
  -p  Type of file
         T - protein
         F - nucleotide [T/F]  Optional
    default = T (CHOSEN)
  -o  Parse options
         T - True: Parse SeqId and create indexes.
         F - False: Do not parse SeqId. Do not create indexes. (CHOSEN)
  -n  Base name for BLAST files [String]  Optional


#When i glob
/export2/home/uesu/db/refseq/arch_prot/bacteria.99.protein.faa.gz


#Combine Outputs
#mkdir "/export2/home/uesu/db/refseq/kocombined" unless -d "/export2/home/uesu/db/refseq/kocombined";
#foreach my $koID (keys %kohash)
#{
#system("cat $dir/*/$koID > /export2/home/uesu/db/refseq/kocombined/$koID");
#}
#find * -size 0 -exec rm -f {} +
#
#perl -nE 'say $1 if m/\t(\S+)$/' ~/KEGG/KEGG_SEPT_2014/genes/links/genes_ko.list | sort | uniq | wc -l
