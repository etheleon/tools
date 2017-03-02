#!/usr/bin/env python

import os
import re
import sqlite3
import argparse

from Bio import SeqIO


def storeInSQL(sqlite3File, koFolder, debug=False):
    '''
    Creates a NEW sqlite3 DB and stores the ko information inside it
    '''

    kos_unfiltered = os.listdir(koFolder)
    kos = [ko for ko in kos_unfiltered if re.search('^ko\:K\d{5}$', ko)]
    conn = sqlite3.connect(sqlite3File)
    c = conn.cursor()
    c.execute('CREATE TABLE IF NOT EXISTS kotable (GI INT PRIMARY KEY, REFSEQ TEXT,KO TEXT, AASEQ TEXT, RECORDID TEXT, RECORDDESCRIPTION TEXT);')
    if debug:
        ko = kos[1]
        koname = re.sub('ko\:', '', ko)
        with open("%s/%s" % (koFolder, ko)) as fh:
            for record in SeqIO.parse(fh, "fasta"):
                _, gi, _, refseqID,_ = record.id.split('|')
                c.execute("INSERT INTO kotable (GI, REFSEQ, KO, AASEQ,RECORDID,RECORDDESCRIPTION) VALUES (?, ?, ?, ?, ?, ?)", (gi, refseqID,koname, str(record.seq), record.id, record.description))
    # c.execute('SELECT * FROM kotable where KO=={ko}.format(ko='K00001')')
    else:
        i = 0
        for ko in kos:
            i = i + 1
            koname = re.sub('ko\:', '', ko)
            # print("processing ko:%s"%koname)
            with open("%s/%s" % (koFolder, ko)) as fh:
                for record in SeqIO.parse(fh, "fasta"):
                    _, gi, _, refseqID,_ = record.id.split('|')
                    # print("%s %s %s" % (record.description, koname, gi))
                    c.execute("INSERT INTO kotable (GI, REFSEQ, KO, AASEQ,RECORDID,RECORDDESCRIPTION) VALUES (?, ?, ?, ?, ?, ?)", (gi, refseqID,koname, str(record.seq), record.id, record.description))
                    # print(record.id)
        print("Processed %s KOs" % i)
    conn.commit()
    conn.close()
    print("Finished")
if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("koNR", help="Relative path to the konr directory")
    parser.add_argument("SQL", help="SQL file NOTE must be full path")
    args = parser.parse_args()

    storeInSQL(args.SQL, args.koNR)
