# File: preprocessing.smk
# Author: Tomas Bencomo
# Email: tjbencomo@gmail.com
# Description:
# Holds rules to create an 'analysis ready bam' according
# to the GATK best practices guide. This bam can then be
# used for either germline or somatic variant calling


rule combine_fqs:
    input:
        unpack(get_fastq)
    output:
        temp("bams/{patient}.{sample_type}.{readgroup}.unaligned.bam")
    params:
        pl=get_platform,
        tmp=tmp_dir
    singularity: gatk_env
    shell:
        """
        gatk FastqToSam -F1 {input.r1} -F2 {input.r2} \
            -O {output} \
            -SM {wildcards.patient}.{wildcards.sample_type} \
            -RG {wildcards.patient}.{wildcards.sample_type}.{wildcards.readgroup} \
            --TMP_DIR {params.tmp} \
            -PL {params.pl}
        """


rule bwa_index:
    input:
        ref_fasta
    output:
        [f"{ref_fasta}.{suffix}" for suffix in file_suffixes]
    singularity: gatk_env 
    shell:
        """
        bwa index {input}
        """

rule bwa:
    input:
        bwt_files=[f"{ref_fasta}.{suffix}" for suffix in file_suffixes],
        bam="bams/{patient}.{sample_type}.{readgroup}.unaligned.bam",
        ref=ref_fasta
    output:
        temp("bams/{patient}.{sample_type}.{readgroup}.aligned.bam")
    threads: 8
    singularity: gatk_env
    shell:
        """
        gatk SamToFastq -I {input.bam} -F /dev/stdout -INTER true -NON_PF true \
        | \
        bwa mem -p -v 3 -t {threads} -T 0 \
            {input.ref} /dev/stdin - 2> >(tee {log} >&2) \
        | \
        samtools view -Shb -o {output}
        """

rule merge_bams:
    input:
        unaligned="bams/{patient}.{sample_type}.{readgroup}.unaligned.bam",
        aligned="bams/{patient}.{sample_type}.{readgroup}.aligned.bam",
        ref=ref_fasta
    output:
        temp("bams/{patient}.{sample_type}.{readgroup}.merged.bam")
    params:
        tmp=tmp_dir
    singularity: gatk_env
    shell:
        """
        gatk MergeBamAlignment \
            -R {input.ref} \
            -UNMAPPED {input.unaligned} \
            -ALIGNED {input.aligned} \
            -O {output} \
            --SORT_ORDER queryname \
            --TMP_DIR {params.tmp}
        """

rule markdups_sort:
    input:
        get_dedup_input
    output:
        bam=temp("bams/{patient}.{sample_type}.sorted.bam"),
        bai=temp("bams/{patient}.{sample_type}.sorted.bam.bai"),
        sbi=temp("bams/{patient}.{sample_type}.sorted.bam.sbi")
    params:
        inbams=lambda wildcards, input: " -I  ".join(input),
        tmp=tmp_dir
    threads: 4
    singularity: gatk_env
    shell:
        """
        gatk MarkDuplicatesSpark \
            -I {params.inbams} \
            -O {output.bam} \
            --tmp-dir {params.tmp} \
            --conf 'spark.executor.cores={threads}' \
            --conf 'spark.local.dir={params.tmp}'
        """

rule bqsr:
    input:
        bam="bams/{patient}.{sample_type}.sorted.bam",
        known=known_sites,
        ref=ref_fasta
    output:
        recal="qc/{patient}.{sample_type}.recal_data.table"
    params:
        ks=['--known-sites ' + s for s in known_sites],
        tmp=tmp_dir
    singularity: gatk_env
    shell:
        """
        gatk BaseRecalibrator -I {input.bam} -R {input.ref} -O {output.recal} \
            {params.ks} --tmp-dir {params.tmp}
        """

rule apply_bqsr:
    input:
        bam="bams/{patient}.{sample_type}.sorted.bam",
        recal="qc/{patient}.{sample_type}.recal_data.table",
        ref=ref_fasta
    output:
        bam="bams/{patient}.{sample_type}.bam",
        bai="bams/{patient}.{sample_type}.bai"
    params:
        tmp=tmp_dir
    singularity: gatk_env
    shell:
        """
        gatk ApplyBQSR \
            -I {input.bam} \
            -R {input.ref} \
            -O {output.bam} \
            -bqsr {input.recal} \
            --add-output-sam-program-record \
            --tmp-dir {params.tmp}
        """

rule coverage:
    input:
        unpack(get_coverage_input)
    output:
        "qc/{patient}.{sample_type}.mosdepth.region.dist.txt",
        "qc/{patient}.{sample_type}.regions.bed.gz",
        "qc/{patient}.{sample_type}.mosdepth.global.dist.txt",
        "qc/{patient}.{sample_type}.mosdepth.summary.txt"
    threads: 4
    params:
        by=lambda wildcards, input: '500' if seqtype == 'WGS' else input.regions
    singularity: mosdepth_env
    shell:
        """
        mosdepth --by {params.by} -t {threads} qc/{wildcards.patient}.{wildcards.sample_type} \
            {input.bam}
        """

rule stats:
    input:
        "bams/{patient}.{sample_type}.bam"
    output:
        "qc/{patient}.{sample_type}.flagstat"
    singularity: gatk_env
    shell:
        """
        samtools flagstat {input} > {output}
        """

rule fastqc:
    input:
        "bams/{patient}.{sample_type}.bam"
    output:
        html="qc/fastqc/{patient}.{sample_type}_fastqc.html",
        zipdata="qc/fastqc/{patient}.{sample_type}_fastqc.zip"
    singularity: fastqc_env
    shell:
        """
        tmpdir=qc/fastqc/{wildcards.patient}-{wildcards.sample_type}.tmp 
        mkdir $tmpdir 
        fastqc --outdir $tmpdir {input} 
        mv $tmpdir/{wildcards.patient}.{wildcards.sample_type}_fastqc.html {output.html} 
        mv $tmpdir/{wildcards.patient}.{wildcards.sample_type}_fastqc.zip {output.zipdata} 
        rm -r $tmpdir
        """

rule multiqc:
    input:
        expand("qc/fastqc/{patient}.{sample_type}_fastqc.zip", patient=patients, sample_type=sample_types),
        expand("qc/{patient}.{sample_type}.mosdepth.region.dist.txt", patient=patients, sample_type=sample_types),
        expand("qc/{patient}.{sample_type}.flagstat", patient=patients, sample_type=sample_types)
    output:
        "qc/multiqc_report.html"
    log:
        "logs/multiqc.log"
    singularity: multiqc_env
    wrapper:
        "0.50.4/bio/multiqc"

rule seq_depths:
    input:
        expand("qc/{patient}.{sample_type}.mosdepth.summary.txt", patient=patients, sample_type=sample_types)
    output:
        "qc/depths.csv"
    singularity: eda_env
    script:
        "../scripts/gather_depths.py"

rule plot_depths:
    input:
        "qc/depths.csv"
    output:
        "qc/depths.svg"
    singularity: eda_env
    script:
        "../scripts/plot_depth.R"

rule split_intervals:
    input:
        ref=ref_fasta,
        intervals=regions_gatk
    output:
        interval_files
    params:
        N=num_workers,
        d="interval-files"
    singularity: gatk_env
    shell:
        """
        gatk SplitIntervals -R {input.ref} -L {input.intervals} \
            --scatter-count {params.N} -O {params.d} \
            --subdivision-mode BALANCING_WITHOUT_INTERVAL_SUBDIVISION
        """
rule make_gatk_regions:
    input:
        bed=regions_bed,
        d=ref_dict
    output:
        intlist=regions_gatk
    singularity: gatk_env
    shell:
        """
        gatk BedToIntervalList \
            -I {input.bed} \
            -SD {input.d} \
            -O {output}
        """

rule gen_wig:
    input:
        bam="bams/{patient}.{sample_type}.sorted.bam",
        bai="bams/{patient}.{sample_type}.sorted.bam.bai"
    output:
        wig="ichor_wig/{patient}.{sample_type}.wig"
    params:
        readCounterPath="/ihome/alee/fangyuan/anaconda3/bin/readCounter",
        quality=20,
        window=1000000
    shell:
        """
        module purge
        module load gcc/12.2.0 r/4.3.0

        {params.readCounterPath} --window {params.window} --quality {params.quality} \
        --chromosome "chr1,chr2,chr3,chr4,chr5,chr6,chr7,chr8,chr9,chr10,chr11,chr12,chr13,chr14,chr15,chr16,chr17,chr18,chr19,chr20,chr21,chr22,chrX" \
        {input.bam} > {output.wig}
        """

rule ichor_cna_analysis:
    input:
        wig="ichor_wig/{patient}.{sample_type}.wig",
        gcWig="/bgfs/alee/LO_LAB/Personal/chelsea/projects/pdo/ichorCNA/inst/extdata/gc_hg38_1000kb.wig",
        mapWig="/bgfs/alee/LO_LAB/Personal/chelsea/projects/pdo/ichorCNA/inst/extdata/map_hg38_1000kb.wig",
        centromere="/bgfs/alee/LO_LAB/Personal/chelsea/projects/pdo/ichorCNA/inst/extdata/GRCh38.GCA_000001405.2_centromere_acen.txt"
    output:
        ichorOut="ichor_out/{patient}.{sample_type}"
    params:
        ichorCNApath="/bgfs/alee/LO_LAB/Personal/chelsea/projects/pdo/ichorCNA"
    shell:
        """
        module purge
        module load gcc/12.2.0 r/4.3.0

        Rscript {params.ichorCNApath}/scripts/runIchorCNA.R --id {wildcards.patient} \
        --WIG {input.wig} --maxCN 5 \
        --gcWig {input.gcWig} \
        --mapWig {input.mapWig} \
        --centromere {input.centromere} \
        --chrs "c(\"chr1\",\"chr2\",\"chr3\",\"chr4\",\"chr5\",\"chr6\",\"chr7\",\"chr8\",\"chr9\",\"chr10\",\"chr11\",\"chr12\",\"chr13\",\"chr14\",\"chr15\",\"chr16\",\"chr17\",\"chr18\",\"chr19\",\"chr20\",\"chr21\",\"chr22\",\"chrX\")" \
        --chrTrain "c(\"chr1\",\"chr2\",\"chr3\",\"chr4\",\"chr5\",\"chr6\",\"chr7\",\"chr8\",\"chr9\",\"chr10\",\"chr11\",\"chr12\",\"chr13\",\"chr14\",\"chr15\",\"chr16\",\"chr17\",\"chr18\",\"chr19\",\"chr20\",\"chr21\",\"chr22\")" \
        --estimateNormal True --estimatePloidy True --estimateScPrevalence True \
        --outDir {output.ichorOut}
        """