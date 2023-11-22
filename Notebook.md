# NBIS #6865

- Last modified: ons nov 22, 2023  01:36
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

Download file `Araport11_cdna_20220914_representative_gene_model.gz` (15M)

    $ mkdir -p /proj/naiss2023-23-413/soppis/Arabidopsis-data
    $ cd /proj/naiss2023-23-413/soppis/Arabidopsis-data
    $ wget https://www.arabidopsis.org/download_files/Sequences/Araport11_blastsets/Araport11_cdna_20220914_representative_gene_model.gz .
    $ get_fasta_info Araport11_cdna_20220914_representative_gene_model.gz
    Nseqs	Min.len	Max.len	Avg.len	File
    27562	3	16444	1631	Araport11_cdna_20220914_representative_gene_model.gz
    $ gunzip Araport11_cdna_20220914_representative_gene_model.gz
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
    $ bwa index Bait_Gateway_AtcDNAlibrary.fas

## Read mapping [**DONE**]

Strategy:

1. Map original fastq with bwa mem against the `Araport11_cdna_20220914_representative_gene_model` (Araport) as reference.
2. Filter output to retain only mapped reads, rename fastq headers as we go, save as fastq
3. Map the mapped fastq against the reference db (Bait), save as bam
4. merge mappings (bam files) from R12, unpaired R1, unpaired R2
5. Parse the bam (or fasta) and check for presence of the different parts

### Map the merged reads (`*_R12.fq.gz`) against Araport [**DONE**]

Align with `Araport11_cdna_20220914_representative_gene_model` as reference.
13,275,049 million reads against 27,562 sequences (3-16,444 bp).

On rackham:

    $ mkdir -p /proj/naiss2023-23-413/soppis/bwa-pilot2
    $ cd /proj/naiss2023-23-413/soppis/bwa-pilot2
    $ ln -s /proj/naiss2023-23-413/soppis/Arabidopsis-data/A* .
    $ ln -s /proj/naiss2023-23-413/soppis/fastp-pilot2/output/fastq/*_R12.fq.gz .

    $ sbatch Araport_bwa-mem_R12.slurm.sh

### Map the unpaired R1 and R2 reads against Araport [**DONE**]

Will produce bam files with names ending in `*_Araport.sorted.bam`.

    $ cd /proj/naiss2023-23-413/soppis/bwa-pilot2
    $ ln -s /proj/naiss2023-23-413/soppis/fastp-pilot2/output/fastq/*_R{1,2}_unpaired.fq.gz .

    $ sbatch Araport_bwa-mem_unpaired_R1.slurm.sh
    $ sbatch Araport_bwa-mem_unpaired_R2.slurm.sh

### Extract and relabel mapped reads [**DONE**]

Will produce compressed fastq files ending in `*_Araport.sorted.fq.gz`

    #bam2fq.py -i B1_EKDL230008374_R12_Araport.sorted.bam -o B1_EKDL230008374_R12_Araport.sorted.fq.gz
    $ pip3 install --user pysam

    $ cd /proj/naiss2023-23-413/soppis/bwa-pilot2
    $ module load gnuparallel/20230422
    $ find /proj/naiss2023-23-413/soppis/bwa-pilot2 -type f -name '*_Araport.sorted.bam' | \
        parallel sbatch \
          -A naiss2023-22-289 \
          -p core \
          -n 1 \
          --wrap \"/proj/naiss2023-23-413/soppis/bwa-pilot2/src/bam2fq.py -i {} -o {.}.fq.gz\"

    $ get_fastq_info -n *_Araport.sorted.fq.gz
    604221	30	269	187	B1_EKDL230008374_R12_Araport.sorted.fq.gz
    113241	30	150	147	B1_EKDL230008374_unpaired_R1_Araport.sorted.fq.gz
    102013	30	150	148	B1_EKDL230008374_unpaired_R2_Araport.sorted.fq.gz
    578662	30	269	187	B2_EKDL230008375_R12_Araport.sorted.fq.gz
    81724	30	150	147	B2_EKDL230008375_unpaired_R1_Araport.sorted.fq.gz
    77729	30	150	147	B2_EKDL230008375_unpaired_R2_Araport.sorted.fq.gz
    576821	30	269	178	Ncre_pool_EKDL230008376_R12_Araport.sorted.fq.gz
    93800	30	150	145	Ncre_pool_EKDL230008376_unpaired_R1_Araport.sorted.fq.gz
    93740	30	150	146	Ncre_pool_EKDL230008376_unpaired_R2_Araport.sorted.fq.gz

### Map the previous mapped and relabeled R12 reads against Bait [**DONE**]

Will produce files ending in `*_Bait.sorted.bam`.

Reference db is now `Bait_Gateway_AtcDNAlibrary.fas`.

    $ cd /proj/naiss2023-23-413/soppis/bwa-pilot2
    $ sbatch src/Bait_bwa-mem_R12.slurm.sh

### Map the previous mapped and relabeled R1 reads against Bait [**DONE**]

Will produce files ending in `*_Bait.sorted.bam`.

    $ cd /proj/naiss2023-23-413/soppis/bwa-pilot2
    $ sbatch src/Bait_bwa-mem_unpaired_R1.slurm.sh

### Map the previous mapped and relabeled R2 reads against Bait [**DONE**]

Will produce files ending in `*_Bait.sorted.bam`.

    $ cd /proj/naiss2023-23-413/soppis/bwa-pilot2
    $ sbatch src/Bait_bwa-mem_unpaired_R2.slurm.sh

### Merge bam files [**DONE**]

Will produce files ending in `*.merged.bam`

    $ module load gnuparallel/20230422
    $ cd /proj/naiss2023-23-413/soppis/bwa-pilot2
    $ find . -type f -name '*_R12_Araport_Bait.sorted.bam' | \
        parallel sbatch \
          -A naiss2023-22-289 \
          -p core \
          -n 10 \
          --wrap \"/proj/naiss2023-23-413/soppis/bwa-pilot2/src/merge_bam.sh {} _R12_Araport_Bait.sorted.bam\"

We now have

    B1_EKDL230008374.merged.bam
    B2_EKDL230008375.merged.bam
    Ncre_pool_EKDL230008376.merged.bam

## Parse bam files [**NOT DONE**]

Samtools can give us a quick overview over the number of mapped reads:
`reference sequence name`, `sequence length`, `# mapped read-segments`, `# unmapped read-segments`

    $ cd /proj/naiss2023-23-413/soppis/bwa-pilot2
    $ for f in *.merged.bam ; do
        echo "# ${f}"
        samtools idxstat "${f}"
        echo ""
      done

    # B1_EKDL230008374.merged.bam
    SmB-A_AT5G44500.1	100	1407	0
    SmB-B_AT4G20440.1	100	1234	0
    SmD1-A_AT3G07590.1	100	1091	0
    SmD1-B_AT4G02840.2	100	1107	0
    SmD2-A_AT2G47640.1	100	3721	0
    SmD2-B_AT3G62840.1	100	2414	0
    SmD3-A_AT1G76300.1	100	6814	0
    SmD3-B_AT1G20580.1	100	10357	0
    SmE-A_AT2G18740.1	100	1156	0
    SmE-B_AT4G30330.1	100	1751	0
    SmF-A_AT4G30220.2	100	1112	0
    SmF-B_AT2G14285.1	100	2900	0
    SmG-A_AT2G23930.1	100	6455	0
    SmG-B_AT3G11500.1	100	1763	0
    LSM1A_AT1G19120.1	100	2167	0
    LSM1B_AT3G14080.1	100	1113	0
    LSM2_AT1G03330.1	100	2549	0
    LSM3A_AT1G21190.1	100	1532	0
    LSM3B_AT1G76860.1	100	3726	0
    LSM4_AT5G27720.1	100	2589	0
    LSM5_AT5G48870.1	100	1034	0
    LSM6A_AT3G59810.1	100	1283	0
    LSM6B_AT2G43810.1	100	15579	0
    LSM7_AT2G03870.2	100	8564	0
    LSM8_AT1G65700.3	100	3770	0
    *	0	0	733650

    # B2_EKDL230008375.merged.bam
    SmB-A_AT5G44500.1	100	1108	0
    SmB-B_AT4G20440.1	100	1069	0
    SmD1-A_AT3G07590.1	100	3327	0
    SmD1-B_AT4G02840.2	100	954	0
    SmD2-A_AT2G47640.1	100	2382	0
    SmD2-B_AT3G62840.1	100	989	0
    SmD3-A_AT1G76300.1	100	4980	0
    SmD3-B_AT1G20580.1	100	7665	0
    SmE-A_AT2G18740.1	100	989	0
    SmE-B_AT4G30330.1	100	938	0
    SmF-A_AT4G30220.2	100	885	0
    SmF-B_AT2G14285.1	100	2111	0
    SmG-A_AT2G23930.1	100	5524	0
    SmG-B_AT3G11500.1	100	4826	0
    LSM1A_AT1G19120.1	100	1538	0
    LSM1B_AT3G14080.1	100	2863	0
    LSM2_AT1G03330.1	100	2057	0
    LSM3A_AT1G21190.1	100	1173	0
    LSM3B_AT1G76860.1	100	2510	0
    LSM4_AT5G27720.1	100	2111	0
    LSM5_AT5G48870.1	100	979	0
    LSM6A_AT3G59810.1	100	5077	0
    LSM6B_AT2G43810.1	100	9005	0
    LSM7_AT2G03870.2	100	6509	0
    LSM8_AT1G65700.3	100	2532	0
    *	0	0	664289

    # Ncre_pool_EKDL230008376.merged.bam
    SmB-A_AT5G44500.1	100	1482	0
    SmB-B_AT4G20440.1	100	1471	0
    SmD1-A_AT3G07590.1	100	1455	0
    SmD1-B_AT4G02840.2	100	1424	0
    SmD2-A_AT2G47640.1	100	1532	0
    SmD2-B_AT3G62840.1	100	1424	0
    SmD3-A_AT1G76300.1	100	1501	0
    SmD3-B_AT1G20580.1	100	1527	0
    SmE-A_AT2G18740.1	100	1506	0
    SmE-B_AT4G30330.1	100	1427	0
    SmF-A_AT4G30220.2	100	1433	0
    SmF-B_AT2G14285.1	100	1451	0
    SmG-A_AT2G23930.1	100	1478	0
    SmG-B_AT3G11500.1	100	1488	0
    LSM1A_AT1G19120.1	100	1443	0
    LSM1B_AT3G14080.1	100	1423	0
    LSM2_AT1G03330.1	100	1494	0
    LSM3A_AT1G21190.1	100	1424	0
    LSM3B_AT1G76860.1	100	1451	0
    LSM4_AT5G27720.1	100	1477	0
    LSM5_AT5G48870.1	100	1431	0
    LSM6A_AT3G59810.1	100	1419	0
    LSM6B_AT2G43810.1	100	1441	0
    LSM7_AT2G03870.2	100	1521	0
    LSM8_AT1G65700.3	100	1466	0
    *	0	0	727847

We can compare the number of mapped reads with the number of original reads (in the fastp output):

    $ cd /proj/naiss2023-23-413/soppis/fastp-pilot2/output/fastq
    $ get_fastq_info -n B1_EKDL230008374*.fq.gz
    13275049	116	269	189	B1_EKDL230008374-1A_HF5CYDSX7_L2_R12.fq.gz
    5784130	116	150	150	B1_EKDL230008374-1A_HF5CYDSX7_L2_R1.fq.gz
    749352	116	150	149	B1_EKDL230008374-1A_HF5CYDSX7_L2_R1_unpaired.fq.gz
    5784130	116	150	149	B1_EKDL230008374-1A_HF5CYDSX7_L2_R2.fq.gz
    698684	116	150	149	B1_EKDL230008374-1A_HF5CYDSX7_L2_R2_unpaired.fq.gz

    $ get_fastq_info -n B2_EKDL230008375*.fq.gz
    9075983	116	269	189	B2_EKDL230008375-1A_HF5CYDSX7_L2_R12.fq.gz
    4467275	116	150	150	B2_EKDL230008375-1A_HF5CYDSX7_L2_R1.fq.gz
    503744	116	150	148	B2_EKDL230008375-1A_HF5CYDSX7_L2_R1_unpaired.fq.gz
    4467275	116	150	149	B2_EKDL230008375-1A_HF5CYDSX7_L2_R2.fq.gz
    525014	116	150	149	B2_EKDL230008375-1A_HF5CYDSX7_L2_R2_unpaired.fq.gz

    $ get_fastq_info -n Ncre_pool_EKDL230008376*.fq.gz
    11761936	116	269	180	Ncre_pool_EKDL230008376-1A_HF5CYDSX7_L2_R12.fq.gz
    2147782	116	150	149	Ncre_pool_EKDL230008376-1A_HF5CYDSX7_L2_R1.fq.gz
    403574	116	150	148	Ncre_pool_EKDL230008376-1A_HF5CYDSX7_L2_R1_unpaired.fq.gz
    2147782	116	150	149	Ncre_pool_EKDL230008376-1A_HF5CYDSX7_L2_R2.fq.gz
    475579	116	150	149	Ncre_pool_EKDL230008376-1A_HF5CYDSX7_L2_R2_unpaired.fq.gz

- `B1_EKDL230008374`
    - fq: 26,291,345
    - bam: 87,188

- `B2_EKDL230008375`
    - fq: 19,039,291
    - bam: 74,101

- `Ncre_pool_EKDL230008376`
    - fq: 16,936,653
    - bam: 36,589

**Note**: the number in reads in bam files are unfiltered reads (for sequencing errors making
them, e.g., unidentifyable as "gene").

For detailed parsing, we need a dedicated script. For a prototype, see [6865.ipynb](6865.ipynb).

---



