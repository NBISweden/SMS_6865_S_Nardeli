#!/bin/bash -l

# Slurm script example.
# Test by using
#     sbatch --test-only samtools-index.slurm.sh
# Start by using 
#     sbatch samtools-index.slurm.sh
# Stop by using
#     scancel 1234
#     scancel -i -u $USER
#     scancel --state=pending -u $USER
# Monitor by using
#    jobinfo -u $USER
#    squeue
#
# Note the choices (the whole) "node" or (a single) "core"


#SBATCH -J samtools-index
#SBATCH -A naiss2023-22-289
#SBATCH -t 01:00:00
#SBATCH -p core
#SBATCH -n 10
 
module load bioinfo-tools
module load samtools/1.17

cd /proj/naiss2023-23-413/soppis/bwa-pilot2

for f in *.bam ; do
    if [ ! -e "${f}.bai" ] ; then
        samtools index -@ 10 "${f}"
        echo "indexed ${f}"
    fi
done

