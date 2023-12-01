#!/bin/bash -l
#SBATCH -J Bait_bwa-mem
#SBATCH -A naiss2023-22-289
#SBATCH -t 04:00:00
#SBATCH -p core
#SBATCH -n 10
 
module load bioinfo-tools
module load bwa/0.7.17
module load samtools/1.16

ref="Bait_Gateway_AtcDNAlibrary.fas"

cd /proj/naiss2023-23-413/soppis/bwa-pilot2

for f in *_R{12,1_unpaired,2_unpaired}.fq.gz ; do
    g="${f%.fq.gz}"_Bait
    echo "$g"
    bwa mem \
        -t 10 \
        "$ref" \
        "$f" |
        samtools sort \
            -@10 \
            -o "$g".sorted.bam -
    samtools index -@10 "$g".sorted.bam
done

