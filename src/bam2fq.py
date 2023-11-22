#! /usr/bin/env python3
# vim:fenc=utf-8
#
# Copyright © 2023 nylander <johan.nylander@nrm.se>
# Distributed under terms of the MIT license.
# Last modified: tis nov 21, 2023  02:52

"""
Read bam file using library pysam. Print reads only if they are mapped.
Will also replace query name with read name in fastq header.
Input: bam (need to be indexed: samtools index -@ 10 bam)
Output: compressed (gzip) fastq
"""

import sys
import re
import argparse
import pysam
import gzip

def main():
    parser = argparse.ArgumentParser(description='Read bam file, print reads as gzipped fastq only if they are mapped, while renaming the fastq header.')
    parser.add_argument('-i', '--input', help='Input bam file', required=True)
    parser.add_argument('-o', '--output', help='Output fq.gz file', required=True)
    args = parser.parse_args()

    bamfile = pysam.AlignmentFile(args.input, 'rb')
    i=0
    with gzip.open(args.output, 'wt') as outfile:
        for read in bamfile.fetch():
            if read.is_unmapped:
                continue
            else:
                i+=1
                #outfile.write('@' + read.query_name + '\n')
                outfile.write('@' + read.reference_name + ':' + str(i) + '\n')
                outfile.write(read.query_sequence + '\n')
                outfile.write('+\n')
                outfile.write(''.join([chr(x+33) for x in read.query_qualities]) + '\n')

if __name__ == '__main__':
    main()

