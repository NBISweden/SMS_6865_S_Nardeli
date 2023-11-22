#!/bin/bash -l

# Slurm script example.
# Test by using
#     sbatch --test-only bwa-index.slurm.sh
# Start by using 
#     sbatch bwa-index.slurm.sh
# Stop by using
#     scancel 1234
#     scancel -i -u $USER
#     scancel --state=pending -u $USER
# Monitor by using
#    jobinfo -u $USER
#    squeue
#
# Note the choices (the whole) "node" or (a single) "core"


#SBATCH -J bwa-index
#SBATCH -A naiss2023-22-289
#SBATCH -t 00:10:00
#SBATCH -p core
#SBATCH -n 1
 
module load bioinfo-tools
module load bwa/0.7.17

cd /proj/naiss2023-23-413/soppis/Arabidopsis-data

bwa index Araport11_cdna_20220914_representative_gene_model

