#! /usr/bin/env python3
# vim:fenc=utf-8
#
# Copyright © 2023 nylander <johan.nylander@nrm.se>
#
# Distributed under terms of the MIT license.

"""

"""

import pysam
from pyfaidx import Fasta
#from pyfaidx import Faidx
from Bio.Seq import Seq

baits_file = 'Bait_Gateway_AtcDNAlibrary.fas'
baits = Fasta(baits_file, sequence_always_upper=True)
baits_dict = {}
gene_length = 9

for seq in baits:
    #print(seq.name) # LSM8_AT1G65700.3
    #print(seq[0:9]) # TGCCGCCAT
    baits_dict[seq.name] = seq[0:gene_length]

for key in baits_dict:
    print(key)             # LSM8_AT1G65700.3
    print(baits_dict[key]) # TGCCGCCAT

# Read baits_file and create a hash/hashes with key=SmB-A_AT5G44500.1, value=CATCGACAT ("gene")


