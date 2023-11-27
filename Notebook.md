# NBIS #6865

- Last modified: mån nov 27, 2023  06:19
- Sign: JN

## Description

Project URL: <https://projects.nbis.se/issues/6865>

GitHub URL: <https://github.com/nylander/SMS_6865_S_Nardeli>

Data on rackham.uppmax.uu.se

- `/proj/naiss2023-23-413/soppis/pilot2`
- `/proj/naiss2023-23-413/soppis/pilot3`

CPU account (NBIS): naiss2023-22-289

## Filtering data [**DONE**]

On rackham:

`/proj/naiss2023-23-413/soppis/pilot2`:

    B1_EKDL230008374-1A_HF5CYDSX7_L2_1.fq.gz
    B1_EKDL230008374-1A_HF5CYDSX7_L2_2.fq.gz
    B2_EKDL230008375-1A_HF5CYDSX7_L2_1.fq.gz
    B2_EKDL230008375-1A_HF5CYDSX7_L2_2.fq.gz
    Ncre_pool_EKDL230008376-1A_HF5CYDSX7_L2_1.fq.gz
    Ncre_pool_EKDL230008376-1A_HF5CYDSX7_L2_2.fq.gz

    $ cd /proj/naiss2023-23-413/soppis
    $ git clone https://github.com/nylander/fastp-cleaning-6439.git fastp-pilot2
    $ cd fastp-pilot2
    $ sed -i -e 's/snic1234-56-789/naiss2023-22-289/' rackham/rackham.yaml
    $ cd /proj/naiss2023-23-413/soppis/fastp-pilot2/input/
    $ ln -s /proj/naiss2023-23-413/soppis/pilot2/*.fq.gz .
    $ for f in *_1.fq.gz ; do mv $f ${f%_1.fq.gz}_R1_001.fastq.gz ; done
    $ for f in *_2.fq.gz ; do mv $f ${f%_2.fq.gz}_R2_001.fastq.gz ; done
    $ vim /proj/naiss2023-23-413/soppis/fastp-pilot2/config/config.yaml
    # Change to
        ## Workflow steps
        #run_fastp:          True
        #run_fastp_dedup:    True
        #run_fastp_merge:    True
        #run_fastq_to_fasta: True
        #run_bwa_mem:        False
        #run_parse_bam:      False
    $ cd /proj/naiss2023-23-413/soppis/fastp-pilot2
    $ screen -S fastp-pilot2 # rackham3
    $ source rackham/scripts/init.sh
    $ make slurm-test
    $ make slurm-run

We now have filtered and paired data in `/proj/naiss2023-23-413/soppis/fastp-pilot2/output/fastq`
and `/proj/naiss2023-23-413/soppis/fastp-pilot2/output/fasta`.

## Download data from Arabidopsis.org  [**DONE**]

Reference data from the Arabidopsis.org web site.

File descriptions (<https://www.arabidopsis.org/download_files/Sequences/Araport11_blastsets/README.20220914.md>):

    Arabidopsis thaliana Genome Annotation Official Release (Approved by NCBI GenBank)
    Starting Version: Araport11
    Original Release date: June 2016
    Latest Update date: September 2022

    Changes compared to previous release (Apr 2016)
    Fixed mis-formatted Symbol names in FASTA headers from date format to Symbol name.

    Files in this release:

    Araport11_seq_20220914.gz                        All gene sequences in FASTA format
    Araport11_cds_20220914.gz                        Coding sequences in FASTA format
    Araport11_pep_20220914.gz                        Protein translations in FASTA format
    Araport11_cdna_20220914.gz                       Transcript sequences in FASTA format
    Araport11_3_utr_20220914.gz                      3' UTR sequences in FASTA format
    Araport11_5_utr_20220914.gz                      5' UTR sequences in FASTA format
    Araport11_intergenic_20220914.gz                 Intergenic sequences in FASTA format
    Araport11_intron_20220914.gz                     Intronic sequences in FASTA format
    Araport11_pep20220914.gz                         Peptide sequences in FASTA format
    Araport11_downstream_[500/1000/3000]_20220914.gz Sequences [500/1000/3000/] downstream of each gene in FASTA format
    Araport11_upstream_[500/1000/3000]_20220914.gz   Sequences [500/1000/3000/] upstream of each gene in FASTA format

    README.20220914.md                     	- This README file

    These files were generated at TAIR.

    If you have any questions regarding the data, please write to <mailto:curator@arabidopsis.org>

Download files `Araport11_cdna_20220914_representative_gene_model.gz` (15M), and
`Araport11_cds_20220914_representative_gene_model.gz` (12 MB)

    $ mkdir -p /proj/naiss2023-23-413/soppis/Arabidopsis-data
    $ cd /proj/naiss2023-23-413/soppis/Arabidopsis-data
    $ wget https://www.arabidopsis.org/download_files/Sequences/Araport11_blastsets/Araport11_cdna_20220914_representative_gene_model.gz .
    $ get_fasta_info Araport11_cdna_20220914_representative_gene_model.gz
    Nseqs	Min.len	Max.len	Avg.len	File
    27562	3	16444	1631	Araport11_cdna_20220914_representative_gene_model.gz
    $ gunzip Araport11_cdna_20220914_representative_gene_model.gz
    $ wget https://www.arabidopsis.org/download_files/Sequences/Araport11_blastsets/Araport11_cds_20220914_representative_gene_model.gz .
    $ get_fasta_info Araport11_cds_20220914_representative_gene_model.gz
    Nseqs	Min.len	Max.len	Avg.len	File
    27562	3	16203	1220	Araport11_cds_20220914_representative_gene_model.gz
    $ gunzip Araport11_cds_20220914_representative_gene_model.gz
    $ sbatch bwa-index.slurm.se

## Prepare "Bait"-file [**DONE**]

On nylander-s:

Input file: `Bait_Gateway_AtcDNAlibrary.xlsx`

Manually open `Bait_Gateway_AtcDNAlibrary.xlsx`, open tab "`25_Sm_Lsm_scheme`",
and export the tab to tsv format: `Bait_Gateway_AtcDNAlibrary.tsv`

Convert to fasta:

    $ scp Bait_Gateway_AtcDNAlibrary.tsv rackham.uppmax.uu.se:/proj/naiss2023-23-413/soppis/bwa-pilot2/.

On rackham:

    $ cd /proj/naiss2023-23-413/soppis/bwa-pilot2/
    $ tail +2 Bait_Gateway_AtcDNAlibrary.tsv | \
          sed 's/^/>/' | \
          sed 's/\t/\n/' | \
          sed 's/\t//g' > Bait_Gateway_AtcDNAlibrary.fas
    $ module load bioinfo-tools bwa/0.7.17
    $ bwa index Bait_Gateway_AtcDNAlibrary.fas

## Read mapping [**DONE**]

Strategy:

1. Map original fastq with bwa mem against the `Bait_Gateway_AtcDNAlibrary.fas`
   (Baits), save as bam.
2. Filter output to retain only mapped reads, rename fastq headers as we go,
   save as fastq.
3. Map the mapped fastq against the
   `Araport11_cds_20220914_representative_gene_model` (Araport) as reference,
   save as bam.
4. Merge mappings (bam files) from R12, unpaired R1, unpaired R2, save as bam.
5. Parse the bam and check for presence of the different parts

Note: The "opposite" strategy (first mapping against Araport, then Baits) was
also evaluated. It had even lower number of "surviving" reads after the double
mapping.

### Map against Baits [**DONE**]

- Input: filtered fq.gz files (`*_L2_R*.fq.gz`)
- Output: bam files (`*_Bait.sorted.bam`)

Map fastp-filtered reads (both merged `*_R12.fq.gz`, and unpaired
`*_R{1,2}_unpaired.fq.gz`) against `Bait_Gateway_AtcDNAlibrary.fas`.

On rackham:

    $ cd /proj/naiss2023-23-413/soppis/bwa-pilot2
    $ sbatch src/Bait_bwa-mem.slurm.sh

### Extract and relabel mapped reads [**DONE**]

- Input: bam files (`*_Bait.sorted.bam`)
- Output: fq.gz files (`*_Bait.sorted.fq.gz`)

On rackham:

    $ pip3 install --user pysam

    $ cd /proj/naiss2023-23-413/soppis/bwa-pilot2
    $ module load gnuparallel/20230422
    $ find /proj/naiss2023-23-413/soppis/bwa-pilot2 -type f -name '*_Bait.sorted.bam' | \
        parallel sbatch \
          -A naiss2023-22-289 \
          -p core \
          -n 1 \
          --wrap \"/proj/naiss2023-23-413/soppis/bwa-pilot2/src/bam2fq.py -i {} -o {.}.fq.gz\"

### Map the previous mapped and relabeled reads against Araport [**DONE**]

- Input: .fq.gz files (`*_Bait.sorted.fq.gz`)
- Output: bam files (`*_Bait_Araport.sorted.bam`)

Use `Araport11_cds_20220914_representative_gene_model` as reference.

On rackham:

    $ cd /proj/naiss2023-23-413/soppis/bwa-pilot2
    $ sbatch src/Araport_bwa-mem.slurm.sh

### Merge bam files [**DONE**]

- Input: bam files (`*_Bait_Araport.sorted.bam`)
- Output: bam files (`*.merged.bam`)

On rackham:

    $ module load gnuparallel/20230422
    $ cd /proj/naiss2023-23-413/soppis/bwa-pilot2
    # We will search for the `*_R12_*`, and the script will collect the `*_R{1,2}_unpaired*` as well
    $ find . -type f -name '*_R12_Bait_Araport.sorted.bam' | \
        parallel sbatch \
          -A naiss2023-22-289 \
          -p core \
          -n 10 \
          --wrap \"/proj/naiss2023-23-413/soppis/bwa-pilot2/src/merge_bam.sh {} _R12_Bait_Araport.sorted.bam\"

We now have:

    B1_EKDL230008374-1A_HF5CYDSX7_L2.merged.bam
    B2_EKDL230008375-1A_HF5CYDSX7_L2.merged.bam
    Ncre_pool_EKDL230008376-1A_HF5CYDSX7_L2.merged.bam

### Mapping statistics [**DONE**]

Compare number of reads in fastp-filtered files, with number of mapped reads in the final (`Baits_Araport`) mapping.

**Note**: the number in reads in bam files are unfiltered reads (for sequencing errors making
them, e.g., unidentifyable as "gene").

    $ cd /proj/naiss2023-23-413/soppis/bwa-pilot2
    $ for f in *.merged.bam ; do
        echo "# ${f}"
        samtools idxstat "${f}" | awk '{sum=sum+$3}END{print sum}'
        echo ""
      done

    # B1_EKDL230008374-1A_HF5CYDSX7_L2.merged.bam
    188123

    # B2_EKDL230008375-1A_HF5CYDSX7_L2.merged.bam
    110688

    # Ncre_pool_EKDL230008376-1A_HF5CYDSX7_L2.merged.bam
    75990

Summary ("opposite" mapping strategy in parantheses)

`B1_EKDL230008374`
- fq: 26,291,345
- bam: 188,123 (87,188)

`B2_EKDL230008375`
- fq: 19,039,291
- bam: 110,688 (74,101)

`Ncre_pool_EKDL230008376`
- fq: 16,936,653
- bam: 75,990 (36,589)

## Parse bam files [**NOT DONE**]

For detailed parsing, we need a dedicated script. For a prototype, see [6865.ipynb](6865.ipynb).

---

