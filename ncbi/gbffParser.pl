#!/usr/bin/env perl

use strict;
use v5.10;
use Bio::SeqIO;
use Bio::SeqFeatureI;

my $gb_file  = "archaea.3.genomic.gbff";
while(my $seqObj = Bio::SeqIO->new(-file => $gb_file)->next_seq)
{
    my $id = $seqObj->display_id;
    my @cds_features = grep { $_->primary_tag eq 'CDS' } $seqObj->get_SeqFeatures;
    say (join "\t", $id, $_->start, $_->end, $_->get_tag_values('db_xref')) foreach @cds_features
}
