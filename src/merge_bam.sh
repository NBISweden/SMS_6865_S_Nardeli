#!/bin/bash -l
# Usage: merge_bam.sh B1_EKDL230008374_R12_Araport_Bait.sorted.bam "_R12_Araport_Bait.sorted.bam"
# f=B1_EKDL230008374_R12_Araport_Bait.sorted.bam
# s=_R12_Araport_Bait.sorted.bam
# Last modified: tis nov 21, 2023  03:12
# Sign: JN

f="$1"
s="$2"

g=$(basename "${f}" "${s}")

module load bioinfo-tools
module load samtools/1.17

samtools merge --threads 10 --write-index \
    -o "${g}".merged.bam \
    "${g}${s}" \
    "${g}"_unpaired_R1_Araport_Bait.sorted.bam \
    "${g}"_unpaired_R2_Araport_Bait.sorted.bam

