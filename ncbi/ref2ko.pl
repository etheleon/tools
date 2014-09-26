#!/usr/bin/env perl 

use strict;
use v5.10;
use autodie;
use Getopt::Long;

die "$0 -l <kegg links directory> -r <refseq dir> -o <output file>\n" unless $#ARGV == 2; 

my ($links_dir, $refseq_dir, $outputfile);
my (%genesko, %genesncbi, %ncbirefseq);
GetOptions( 
            'l|links=s'       	=> \$links_dir,
            'r|refseq=s'	=> \$refseq_dir,
            'o|output=s' 	=> \$outputfile,
           );


#gi <-> refseq
my @refseq = <$refseq_dir/*>;
foreach (@refseq) { 
    say "Reading ".$_;
open my $refseq, "-|", "zcat $_"; 
    while(<$refseq>){ 
    	my ($gi, $ref) = (split(/\|/, $_))[1,3] if (m/^\>/); 
    	$ncbirefseq{$gi} = $ref;
	    }	
	  say "\t".scalar keys %ncbirefseq;
	    }
say "Finished reading refseq files";

#ko <-> genes
open my $genesncbi, "-|","zcat $links_dir/genes_ko.list.gz";
while(<$genesncbi>) { 
	chomp;
	my ($gene, $ncbi)  = split(/\t/);
	$gene =~ s/ncbi-gene://;
	$genesncbi{$gene}= $ncbi;
}
say "Finished storing gene2ko";

#generate refseq KO mapping
open my $genesko, "-|","zcat $links_dir/genes_ko.list.gz";
open my $output, $outputfile;
while(<$genesko>) { 
	chomp;
	my ($gene,$ko) = split(/\t/);
	$ko =~ s/ko\:K//;
	my $ref = $ncbirefseq{$genesncbi{$gene}};
	say $output join "\t", $ref, $ko; 
}
say "DONE";
__END__

genes_ncbi-geneid.list.gz
hsa:1   ncbi-geneid:1
hsa:10  ncbi-geneid:10
hsa:100 ncbi-geneid:100
hsa:1000        ncbi-geneid:1000
hsa:10000       ncbi-geneid:10000

genes_ko.list.gz
hsa:10004       ko:K01301
hsa:100049587   ko:K06549
hsa:10005       ko:K11992
hsa:10007       ko:K02564
hsa:10008       ko:K04897
hsa:10009       ko:K10507
hsa:1001        ko:K06796
