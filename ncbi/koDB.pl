#!/usr/bin/env perl

use Modern::Perl '2015';
use experimental 'signatures';
use autodie;
use Bio::SeqIO;
use IO::File;
use Parallel::ForkManager;

die "USAGE: $0 <number of forks to use>\n" unless $#ARGV == 0;

my $refseqDB                              = '/export2/home/uesu/db/refseq/arch_prot';
my $keggDIR                               = '/export2/home/uesu/KEGG/KEGG_SEPT_2014';
my $dir                                   = '/export2/home/uesu/db/refseq/ko2'; #stores the uncombined sequences
my $kodb                                  = '/export2/home/uesu/db/kodb2';      #redundant but combined
my $nr                                    = '/export2/home/uesu/db/konr';       #non-redudnant partitioned by ko
my %ncbi2ko;    #ncbi <-> ko hash table

my $threads= shift;
my $pm = new Parallel::ForkManager($threads);
open my $batch, ">", "./batch/kodb";

#say "# building gi-ko link";
    #ko2gi();
#say "# output to files";
    #main($pm);
#say "# main is done";
    my @kos = map {chomp; $_ } `find $dir -type f -maxdepth 2 -printf "%f\n" | sort | uniq`;
#say "# merging kos";
    #mergekos($_) for @kos;
say "# removing Redundant";
for (@kos)
{
    $pm->start and next;
    removeRedundant($_);
    $pm->finish;
}
$pm->wait_all_children;


#Functions
sub main($pm)
{
    my @newfiles  = grep {!m/nonredundant/} <$refseqDB/*>;
    foreach (@newfiles)
    {
        $pm->start and next;
        ##################################################
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

sub readGZ($gzfna, $outputDIR)
{
    my %out;        #hash table to store the lexical KO filehandles
    mkdir $outputDIR unless -d $outputDIR;

    open my $in, "-|", "zcat $gzfna";
    my $contents = do { local $/; <$in> };
    my @seq = split /\>/, $contents;
    for my $sequence (@seq)
    {
        $sequence =~ m/^gi\|(?<ncbi>\d+)\|/;
        if(exists $ncbi2ko{$+{ncbi}})
        {
            my $ko = $ncbi2ko{$+{ncbi}};
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
    my %gene;
    while(<$input>)
    {
        chomp;
        #hsa:100131801   ko:K18186
        my @a = split /\t/;
        $gene{$a[0]}->{ko} = $a[1];
    }
    close $input;

    open my $input2, '<', "$keggDIR/genes/links/genes_ncbi-geneid.list";
    while(<$input2>)
    {
        chomp;
        #hsa:100125288   ncbi-gi:157266269
        my @a = split /\t/;
        $a[1] =~ s/^ncbi-gi\://;
        $gene{$a[0]}->{gi} = $a[1];
    }
    close $input2;

    for my $gene (keys %gene)
    {
        if(exists $gene{$gene}->{gi} && exists $gene{$gene}->{ko})
        {
            $ncbi2ko{$gene{$gene}->{gi}} = $gene{$gene}->{ko};
        }
    }
    say "Loaded NCBI->KO hashtable\n\t# of keys:", scalar keys %ncbi2ko;
}

sub mergekos
{
    my ($ko) = @_;
    system "cat $dir/*/$ko > $kodb/$ko";
}

sub removeRedundant($ko)
{
    my %gihash;

    my $in = Bio::SeqIO->new(-file=>"$kodb/$ko", -format=>"fasta");
    my $out = Bio::SeqIO->new(-file=>">$nr/$ko", -format=>"fasta");

    while(my $seqObj = $in->next_seq){
        my $refseqID = $seqObj->display_id;
        my ($ncbi) = $refseqID =~ m/^gi\|(\d+)\|/;
        unless (exists $gihash{$ncbi})
        {
            $gihash{$ncbi}++;
            $out->write_seq($seqObj);
        }
    }
}
