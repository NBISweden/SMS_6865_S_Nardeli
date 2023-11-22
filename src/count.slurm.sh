#!/bin/bash -l

# Last modified: fre dec 09, 2022  05:32
# Sign: JN
#
# Slurm script example.
# Start by using
#     sbatch counts.slurm.sh
# Stop by using
#     scancel 1234
#     scancel -i -u $(USER)
#     scancel --state=pending -u $(USER)
# Monitor by using
#    jobinfo -u $(USER)
#    squeue
#
# Note the choices (the whole) "node" or (a single) "core"
# -n 1 is one core

#SBATCH -J count
#SBATCH -o count.slurm.out
#SBATCH -A snic1234-56-789
#SBATCH -t 00:30:00
#SBATCH -p core
#SBATCH -n 10


module load bioinfo-tools
module load python/3.7.2
module load pysam/0.15.3-python3.7.2
module load samtools/1.14
module load bwa/0.7.17

python3 -m venv $SNIC_TMP/env
source $SNIC_TMP/env/bin/activate
pip3 install pyfaidx

# Input
inputfolder='data'
suffix='.fastq.gz'
reflist='list.tab'
ref='ref.fas'

# Output
outputfolder='output'
mkdir -p "${outputfolder}"

# Scripts
parse='./scripts/parse_bam.py'
tab2fasta='./scripts/tab2fasta'
threads=$SLURM_NPROCS

start=$(date +%s)

# Convert tab to fasta and create index
"${tab2fasta}" "${reflist}" > "${ref}"
bwa index "${ref}"

# Run bwa on all input files, and parse. Print
# four tsv files, one for each number of allowed
# mismatches in the core (0,1,2,3)
for f in ${inputfolder}/*${suffix} ; do
    lib=$(basename "${f}" "${suffix}")
    echo ""
    echo "Count in ${lib}"
    echo ""
    bam="${lib}.bam"
    bwa mem -t "${threads}" "${ref}" "${f}" | samtools sort -@"${threads}" -o "${bam}" -
    samtools index -@"${threads}" "${bam}"
    for m in $(seq 0 3); do
       "${parse}" -f "${ref}" -b "${bam}" -t "${threads}" -m "${m}" -o "${outputfolder}"/"${lib}"."${m}".tsv
    done
    rm "${bam}" "${bam}.bai"
done

# Clean up tmp files
rm ${ref}{.amb,.ann,.bwt,.fai,.pac,.sa}
rm "${ref}"
echo ""
echo "End of counts"

deactivate

end=$(date +%s)
runtime=$((end-start))
eval "echo Run took $(date -ud "@$runtime" \
  +'$((%s/3600/24)) days %H hours %M minutes %S seconds')"

