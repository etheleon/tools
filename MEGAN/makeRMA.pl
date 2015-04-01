#!/usr/bin/env perl

use Modern::Perl '2015';
use autodie;
use experimental qw/signatures/;

die "usage: $0 tabbedBlast.m8 outputDIR MEGAN\n" unless $#ARGV == 2;

my ($blast, $out, $megan) = @ARGV;
my ($fileName) = $blast =~ m/([^\/]+)\.m8/;

die unless -f $blast;
die unless -f $megan;

my $temp = rand().time();
prep();
runMegan(1);

sub runMegan ($count)
{
    if($count <= 20){
        $count++;
    }else{
        say STDERR "$blast query has failed";
        exit 1;
    };
    unlink "$fileName.lock" if -e "$fileName.lock";
    unlink "$fileName.log" if -e "$fileName.log";

    my $scr = int(30000 * rand());

    #try new screen number if its taken;
    $scr = int(30000 * rand()) while -e "/tmp/.X$scr-lock";

    my $signal = `xvfb-run -n $scr -f $fileName.lock -e $fileName.log $megan -g -d -E  -c $temp`;
    #cant check for xvfb-run's own error [xc's version]
    if($signal)
    {
        unlink "$fileName.lock", $temp;
        exit 1;
    }else{
        say STDERR "reattempt";
        say STDERR $signal;
        runMegan($count);
    }
}

sub prep {
    my $CMD = join '', <DATA>;
    $CMD =~ s/blastx.txt/$blast/;   #text file
    $CMD =~ s/blastx.rma/$fileName.rma/;
    $CMD =~ s/example/$out/;
    open my $cmdIO, ">", $temp;
    print $cmdIO $CMD;
    close $cmdIO;
    mkdir $out unless -d $out;
}

__DATA__
load taxGIFile='/export2/home/uesu/simulation_fr_the_beginning/data/classifier/gi2taxid.refseq.map';
set taxUseGIMap=true;
load keggRefSeqFile='/export2/home/uesu/simulation_fr_the_beginning/data/classifier/ref2ko.map';
set keggUseRefSeqMap=true;
import blastFile='blastx.txt' meganFile='example/blastx.rma' maxMatches=100 minScore=35.0 maxExpected=0.01 topPercent=10.0 minSupportPercent=0.1 minSupport=1 minComplexity=0.44 useMinimalCoverageHeuristic=false useSeed=false useCOG=false useKegg=true paired=false useIdentityFilter=false textStoragePolicy=Embed blastFormat=BlastTAB mapping='Taxonomy:BUILT_IN=true, Taxonomy:GI_MAP=true, KEGG:REFSEQ_MAP=true, COG:REFSEQ_MAP=true';
quit;
