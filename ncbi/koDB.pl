#!/usr/bin/env perl

use strict;
use v5.18;
use lib "/export2/home/uesu/perl5/lib/perl5";
use autodie;
use IO::File;
use Parallel::ForkManager;

die "USAGE: $0 <number of forks to use>\n" unless $#ARGV == 0;

my $process_count = shift;
my $pm = new Parallel::ForkManager($process_count);

my $refseqDB                              = '/export2/home/uesu/db/refseq/arch_prot';
my $keggDIR                               = '/export2/home/uesu/KEGG/KEGG_SEPT_2014';
my $dir                                   = '/export2/home/uesu/db/refseq/ko';
my %out;        #store the KO filehandles
my %ncbi2ko;    #ncbi <-> ko hash table
my %kohash;
##################################################
#-------------------------------------------------
#AIM:
#Build reference DB for each KO
##################################################

#Build KO<->GI hash table
say "Initialising..";
ko2gi();
say "Loaded NCBI->KO hashtable\n\t# of keys:",scalar keys %ncbi2ko;

#Main
main($pm);

#Combine Outputs
#mkdir "$dir/kocombined" unless -d "$dir/kocombined";
#foreach my $koID(keys %kohash)
#{
#$koID =~ s/ko://g;
#system("cat $dir/*protein*/$koID > $dir/kocombined/$koID");
#}
##find * -size 0 -exec rm -f {} +

sub main
{
    my $pm = shift;
    my @files = glob "$refseqDB/*";
    my @newfiles  = grep {!m/nonredundant/} @files; #not counting redundant

    foreach (@newfiles)
    {
        $pm->start and next;
        ##################################################
        #-------------------------------------------------
        #parallelized Code
        m/\/
            (?<ncbiFile>[^\/]+)  #the filename without .gz
        \.faa\.gz$
        /x;
        my $outputDIR = "$dir/".$+{ncbiFile};
        mkdir $outputDIR unless -d $outputDIR;
        readGZ($_, $outputDIR);
        ##################################################
        $pm->finish;
    }
    $pm->wait_all_children;
}

sub readGZ
{
    my ($gzfna, $outputDIR) = @_;
    open my $in, "-|", "zcat $gzfna";
    my $contents = do { local $/; <$in> };
    my @seq = split /\>/, $contents;
    foreach my $sequence (@seq)
    {
        $sequence =~ m/^gi\|(?<ncbi>\d+)\|/;
        #say $+{ncbi};
        my $ko = $ncbi2ko{$+{ncbi}};
        if (exists $ncbi2ko{$+{ncbi}})   #if the gi is linked to a KO;
        {
            unless($out{$ko})
            {
               $out{$ko} = IO::File->new(">$outputDIR/$ko");
            }
            $out{$ko}->print('>');
            $out{$ko}->print($sequence);
        }
    }
}

sub ko2gi
{
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

##################################################
#-------------------------------------------------
#Check
    open my $output, ">", "/export2/home/uesu/qc.txt";
##################################################
    foreach my $gene (keys %gene2ncbi)
    {
    my $ko = $gene2ko{$gene};
    $kohash{$ko}++;
    my $ncbi = $gene2ncbi{$gene};
        if($ko ne "")
        {
            $ncbi2ko{$ncbi} = $ko;
            say $output join "\t", $ncbi, $ko;
        }
    }
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
