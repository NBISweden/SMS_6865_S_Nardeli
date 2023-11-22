#!/bin/bash -l

# Slurm script example.
# Test by using
#     sbatch --test-only Araport_bwa-mem_unpaired_R2.slurm.sh
# Start by using 
#     sbatch Araport_bwa-mem_unpaired_R2.slurm.sh
# Stop by using
#     scancel 1234
#     scancel -i -u $USER
#     scancel --state=pending -u $USER
# Monitor by using
#    jobinfo -u $USER
#    squeue
#
# Note the choices (the whole) "node" or (a single) "core"


#SBATCH -J Araport_bwa-mem_unpaired_R2
#SBATCH -A naiss2023-22-289
#SBATCH -t 04:00:00
#SBATCH -p core
#SBATCH -n 10
 
module load bioinfo-tools
module load bwa/0.7.17
module load samtools/1.16

ref="Araport11_cdna_20220914_representative_gene_model"

cd /proj/naiss2023-23-413/soppis/bwa-pilot2

for rtwo in *-1A_HF5CYDSX7_L2_R2_unpaired.fq.gz ; do
    g="${rtwo%-1A_HF5CYDSX7_L2_R2_unpaired.fq.gz}"_unpaired_R2_Araport
    echo "rtwo: " $rtwo
    bwa mem \
        -t 10 \
        "$ref" \
        "$rtwo" |
        samtools sort \
            -@10 \
            -o "$g".sorted.bam -
    samtools index -@10 "$g".sorted.bam
done

