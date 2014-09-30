#!/usr/bin/env perl 

use strict;
use v5.10;
use autodie;
use Getopt::Long;

die "$0 -l <kegg links directory> -o <output file> -x <gi2taxid_input> -t <gi2taxid.refseq>\n" unless $#ARGV == 7; 

my ($links_dir, $outputfile, $gi2taxid_vanilla, $gi2taxid_refseq);
my (%genesko, %genesncbi, %ncbirefseq);
GetOptions( 
            'l|links=s'       	=> \$links_dir,
            'o|output=s' 	=> \$outputfile,
            'x|taxoninput=s'	=> \$gi2taxid_vanilla,
            't|taxoutput=s'	=> \$gi2taxid_refseq
           );

#Step 1: gi <-> refseq	#meant for nr 
my $filesInDir = `ls ~/db/nr/*`; 
my @files = map { if ($_ =~ /\d$/){$_}else{()} }  (split /\n/, $filesInDir); 

    giRefseq($_) foreach @files;	#note this only includes Refseq sequences from Bacteria & Archea; 
    say "Finished reading refseq files";
#Step 2: ko <-> gi
    parseGeneGI("$links_dir".'/genes_ncbi-gi.list.gz');
#Step 3: gi<->taxid (only refseq sequences)
    giTaxon($gi2taxid_vanilla, $gi2taxid_refseq);
#Step 4: KO <-> refseq
    linkRefseq2KO("$links_dir/genes_ko.list.gz", $outputfile);
say "DONE";

sub linkRefseq2KO { 
	my ($file, $outputfile)  = @_;
	open my $input, "-|","zcat $file";
	open my $output, ">", $outputfile;
    	while(<$input>) { 
	    chomp;
	    my ($kegggene,$ko) = split(/\t/);
	    $ko =~ s/ko\:K//;
	    if (exists $ncbirefseq{$genesncbi{$kegggene}}) {
	    	say $output join "\t", $ncbirefseq{$genesncbi{$kegggene}}, $ko
	    }else{ 
	    	say "This ".$kegggene." is not associated with a refseq gene (KO is mapped to GI:".$genesncbi{$kegggene}.")"
	    	} 
    	}
}

sub parseGeneGI { 
    my ($file)  = @_;
    open my $input, "-|","zcat $file";
    while(<$input>) { 
	    chomp;
	    my ($kegggene, $gi)  = split(/\t/);
	    $gi =~ s/ncbi-gi://;
	    $genesncbi{$kegggene}= $gi;
    }
    say "Finished storing genes-gi";
}

sub giRefseq { 
my ($inputFile) = @_;
say "Reading ".$inputFile;
open my $input , "<", "$inputFile"; 
    while(<$input>){ 
    	if (m/^\>/){
		my @sequences = split /gi\|/; 
		foreach (@sequences) { 
    	my ($gi, $ref) = (split(/\|/, $_))[0,2];
#    	say join "\t", $gi, $ref;
    	$ncbirefseq{$gi} = $ref;
		}
	}	
    }
}

sub giTaxon { 
    my ($file, $outputfile) = @_;
    open my $input, '<', $file;
    open my $output, '>', $outputfile;
    while(<$input>) { 
	chomp;
	my ($gi, $taxID) = split /\t/; 
	say $output join "\t", 'gi|'.$gi, $taxID if exists $ncbirefseq{$gi}; 
    }
}

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

final output
YP_114235       08684
YP_115248       08684
YP_114234       08684
YP_115247       08684
YP_114236       08684
YP_115249       08684
YP_001940163    08684
YP_001940162    08684
YP_001940158    08684
YP_004511252    08684
