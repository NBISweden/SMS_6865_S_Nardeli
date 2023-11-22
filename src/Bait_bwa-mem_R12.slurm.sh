#!/bin/bash -l

# Slurm script example.
# Test by using
#     sbatch --test-only Bait_bwa-mem_R12.slurm.sh
# Start by using 
#     sbatch Bait_bwa-mem_R12.slurm.sh
# Stop by using
#     scancel 1234
#     scancel -i -u $USER
#     scancel --state=pending -u $USER
# Monitor by using
#    jobinfo -u $USER
#    squeue
#
# Note the choices (the whole) "node" or (a single) "core"


#SBATCH -J Bait_bwa-mem_R12
#SBATCH -A naiss2023-22-289
#SBATCH -t 04:00:00
#SBATCH -p core
#SBATCH -n 10
 
module load bioinfo-tools
module load bwa/0.7.17
module load samtools/1.16

ref="Bait_Gateway_AtcDNAlibrary.fas"

cd /proj/naiss2023-23-413/soppis/bwa-pilot2

for f in *_R12_Araport.sorted.fq.gz ; do
    g="${f%.sorted.fq.gz}"_Bait
    echo "$g"
    bwa mem \
        -t 10 \
        "$ref" \
        "$f" |
        samtools sort \
            -@10 \
            -o "$g".sorted.bam -
done

