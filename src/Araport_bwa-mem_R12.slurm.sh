#!/bin/bash -l

# Slurm script example.
# Test by using
#     sbatch --test-only Araport_bwa-mem_R12.slurm.sh
# Start by using 
#     sbatch Araport_bwa-mem_R12.slurm.sh
# Stop by using
#     scancel 1234
#     scancel -i -u $USER
#     scancel --state=pending -u $USER
# Monitor by using
#    jobinfo -u $USER
#    squeue
#
# Note the choices (the whole) "node" or (a single) "core"


#SBATCH -J Araport_bwa-mem_R12
#SBATCH -A naiss2023-22-289
#SBATCH -t 04:00:00
#SBATCH -p core
#SBATCH -n 10
 
module load bioinfo-tools
module load bwa/0.7.17
module load samtools/1.16

ref="Araport11_cdna_20220914_representative_gene_model"

cd /proj/naiss2023-23-413/soppis/bwa-pilot2

for f in *-1A_HF5CYDSX7_L2_R12.fq.gz ; do
    g="${f%-1A_HF5CYDSX7_L2_R12.fq.gz}"_R12_Araport
    bwa mem \
        -t 10 \
        "$ref" \
        "$f" |
        samtools sort \
            -@10 \
            -o "$g".sorted.bam -
    samtools index -@ 10 "$g".sorted.bam
done
