#!/bin/bash

module load gcc/12.2.0 r/4.3.0
cd /ihome/alee/fangyuan/projects/pdo/071023_PDO_WGS/data/

# BO56_P27
/ihome/alee/fangyuan/anaconda3/bin/readCounter --window 1000000 --quality 20 \
--chromosome "chr1,chr2,chr3,chr4,chr5,chr6,chr7,chr8,chr9,chr10,chr11,chr12,chr13,chr14,chr15,chr16,chr17,chr18,chr19,chr20,chr21,chr22,chrX" \
/bgfs/alee/LO_LAB/General/Lab_Data/071023_PDO_WGS/IPM-BO56_P27_LEE5235A4_S18_001_markdup_realigned.bam \
> ichor_wig/BO56_P27.wig

ichorCNApath=/bgfs/alee/LO_LAB/Personal/chelsea/projects/pdo/071023_PDO_WGS/ichorCNA

Rscript $ichorCNApath/scripts/runIchorCNA.R --id BO56_P27 \
  --WIG ichor_wig/BO56_P27.wig --maxCN 5 \
  --gcWig $ichorCNApath/inst/extdata/gc_hg38_1000kb.wig \
  --mapWig $ichorCNApath/inst/extdata/map_hg38_1000kb.wig \
  --centromere $ichorCNApath/inst/extdata/GRCh38.GCA_000001405.2_centromere_acen.txt \
  --chrs "c(\"chr1\",\"chr2\",\"chr3\",\"chr4\",\"chr5\",\"chr6\",\"chr7\",\"chr8\",\"chr9\",\"chr10\",\"chr11\",\"chr12\",\"chr13\",\"chr14\",\"chr15\",\"chr16\",\"chr17\",\"chr18\",\"chr19\",\"chr20\",\"chr21\",\"chr22\",\"chrX\")" \
  --chrTrain "c(\"chr1\",\"chr2\",\"chr3\",\"chr4\",\"chr5\",\"chr6\",\"chr7\",\"chr8\",\"chr9\",\"chr10\",\"chr11\",\"chr12\",\"chr13\",\"chr14\",\"chr15\",\"chr16\",\"chr17\",\"chr18\",\"chr19\",\"chr20\",\"chr21\",\"chr22\")" \
  --estimateNormal True --estimatePloidy True --estimateScPrevalence True \
  --outDir ichor_out/BO56_P27

# BO56_P6
/ihome/alee/fangyuan/anaconda3/bin/readCounter --window 1000000 --quality 20 \
--chromosome "chr1,chr2,chr3,chr4,chr5,chr6,chr7,chr8,chr9,chr10,chr11,chr12,chr13,chr14,chr15,chr16,chr17,chr18,chr19,chr20,chr21,chr22,chrX" \
/bgfs/alee/LO_LAB/General/Lab_Data/071023_PDO_WGS/IPM-BO56_P6_LEE5235A3_S13_001_markdup_realigned.bam \
> ichor_wig/BO56_P6.wig

ichorCNApath=/bgfs/alee/LO_LAB/Personal/chelsea/projects/pdo/071023_PDO_WGS/ichorCNA

Rscript $ichorCNApath/scripts/runIchorCNA.R --id BO56_P6 \
  --WIG ichor_wig/BO56_P6.wig --maxCN 5 \
  --gcWig $ichorCNApath/inst/extdata/gc_hg38_1000kb.wig \
  --mapWig $ichorCNApath/inst/extdata/map_hg38_1000kb.wig \
  --centromere $ichorCNApath/inst/extdata/GRCh38.GCA_000001405.2_centromere_acen.txt \
  --chrs "c(\"chr1\",\"chr2\",\"chr3\",\"chr4\",\"chr5\",\"chr6\",\"chr7\",\"chr8\",\"chr9\",\"chr10\",\"chr11\",\"chr12\",\"chr13\",\"chr14\",\"chr15\",\"chr16\",\"chr17\",\"chr18\",\"chr19\",\"chr20\",\"chr21\",\"chr22\",\"chrX\")" \
  --chrTrain "c(\"chr1\",\"chr2\",\"chr3\",\"chr4\",\"chr5\",\"chr6\",\"chr7\",\"chr8\",\"chr9\",\"chr10\",\"chr11\",\"chr12\",\"chr13\",\"chr14\",\"chr15\",\"chr16\",\"chr17\",\"chr18\",\"chr19\",\"chr20\",\"chr21\",\"chr22\")" \
  --estimateNormal True --estimatePloidy True --estimateScPrevalence True \
  --outDir ichor_out/BO56_P6

# BO53_P13
/ihome/alee/fangyuan/anaconda3/bin/readCounter --window 1000000 --quality 20 \
--chromosome "chr1,chr2,chr3,chr4,chr5,chr6,chr7,chr8,chr9,chr10,chr11,chr12,chr13,chr14,chr15,chr16,chr17,chr18,chr19,chr20,chr21,chr22,chrX" \
/bgfs/alee/LO_LAB/General/Lab_Data/071023_PDO_WGS/IPM-BO53_P13_LEE5235A1_S2_001_markdup_realigned.bam \
> ichor_wig/BO53_P13.wig

ichorCNApath=/bgfs/alee/LO_LAB/Personal/chelsea/projects/pdo/071023_PDO_WGS/ichorCNA

Rscript $ichorCNApath/scripts/runIchorCNA.R --id BO53_P13 \
  --WIG ichor_wig/BO53_P13.wig --maxCN 5 \
  --gcWig $ichorCNApath/inst/extdata/gc_hg38_1000kb.wig \
  --mapWig $ichorCNApath/inst/extdata/map_hg38_1000kb.wig \
  --centromere $ichorCNApath/inst/extdata/GRCh38.GCA_000001405.2_centromere_acen.txt \
  --chrs "c(\"chr1\",\"chr2\",\"chr3\",\"chr4\",\"chr5\",\"chr6\",\"chr7\",\"chr8\",\"chr9\",\"chr10\",\"chr11\",\"chr12\",\"chr13\",\"chr14\",\"chr15\",\"chr16\",\"chr17\",\"chr18\",\"chr19\",\"chr20\",\"chr21\",\"chr22\",\"chrX\")" \
  --chrTrain "c(\"chr1\",\"chr2\",\"chr3\",\"chr4\",\"chr5\",\"chr6\",\"chr7\",\"chr8\",\"chr9\",\"chr10\",\"chr11\",\"chr12\",\"chr13\",\"chr14\",\"chr15\",\"chr16\",\"chr17\",\"chr18\",\"chr19\",\"chr20\",\"chr21\",\"chr22\")" \
  --estimateNormal True --estimatePloidy True --estimateScPrevalence True \
  --outDir ichor_out/BO53_P13

# BO53_P31
/ihome/alee/fangyuan/anaconda3/bin/readCounter --window 1000000 --quality 20 \
--chromosome "chr1,chr2,chr3,chr4,chr5,chr6,chr7,chr8,chr9,chr10,chr11,chr12,chr13,chr14,chr15,chr16,chr17,chr18,chr19,chr20,chr21,chr22,chrX" \
/bgfs/alee/LO_LAB/General/Lab_Data/071023_PDO_WGS/IPM-BO53_P31_LEE5235A2_S8_001_markdup_realigned.bam \
> ichor_wig/BO53_P31.wig

ichorCNApath=/bgfs/alee/LO_LAB/Personal/chelsea/projects/pdo/071023_PDO_WGS/ichorCNA

Rscript $ichorCNApath/scripts/runIchorCNA.R --id BO53_P31 \
  --WIG ichor_wig/BO53_P31.wig --maxCN 5 \
  --gcWig $ichorCNApath/inst/extdata/gc_hg38_1000kb.wig \
  --mapWig $ichorCNApath/inst/extdata/map_hg38_1000kb.wig \
  --centromere $ichorCNApath/inst/extdata/GRCh38.GCA_000001405.2_centromere_acen.txt \
  --chrs "c(\"chr1\",\"chr2\",\"chr3\",\"chr4\",\"chr5\",\"chr6\",\"chr7\",\"chr8\",\"chr9\",\"chr10\",\"chr11\",\"chr12\",\"chr13\",\"chr14\",\"chr15\",\"chr16\",\"chr17\",\"chr18\",\"chr19\",\"chr20\",\"chr21\",\"chr22\",\"chrX\")" \
  --chrTrain "c(\"chr1\",\"chr2\",\"chr3\",\"chr4\",\"chr5\",\"chr6\",\"chr7\",\"chr8\",\"chr9\",\"chr10\",\"chr11\",\"chr12\",\"chr13\",\"chr14\",\"chr15\",\"chr16\",\"chr17\",\"chr18\",\"chr19\",\"chr20\",\"chr21\",\"chr22\")" \
  --estimateNormal True --estimatePloidy True --estimateScPrevalence True \
  --outDir ichor_out/BO53_P31