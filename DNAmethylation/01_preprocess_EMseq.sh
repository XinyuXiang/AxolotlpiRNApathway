#!/bin/bash
### setup ###
ref_genome_dir="/reference_AmexG_v6.0/"

### fastqc ###
input_fastq_R1=./01_fq/${seqfile}.R1.fastq.gz
input_fastq_R2=./01_fq/${seqfile}.R2.fastq.gz

${fastqc_path}fastqc ${input_fastq_R1} ${input_fastq_R2} -o ./01_fastqc

### trim ###
input_fastq_R1=./01_fq/${seqfile}.R1.fastq.gz
input_fastq_R2=./01_fq/${seqfile}.R2.fastq.gz

trim_galore --paired \
--quality 20 --length 25 --trim-n --clip_R2 5 \
--fastqc --fastqc_args "--outdir ./02_fastqc" \
-o ./02_fq_trim \
${input_fastq_R1} ${input_fastq_R2} && echo ${seqfile} trimming is done

### bismark index ###
perl /biosoft/Bismark-0.24.0/bismark_genome_preparation \
--bowtie2 --path_to_aligner /library/software/bin/ --large-index --parallel 20 ./20230124axolotlRRBS/tmp \
--genomic_composition --verbose >& 00_bismarkidx.log

### bismark alignment ###
input_fastq_R1=./02_fq_trim/${seqfile}.R1_val_1.fq.gz
input_fastq_R2=./02_fq_trim/${seqfile}.R2_val_2.fq.gz

${bismark_path}bismark \
--bowtie2 -N 1 -p 4 --ambig_bam --nucleotide_coverage \
-o ./03_bismark $ref_genome_dir -1 ${input_fastq_R1} -2 ${input_fastq_R2} && echo "03 bismark alignment ends" 
# -N 1: mismatch 1. For bismark, unique best alignment is used for downstream analysis

### bismark report ###
${bismark_path}bismark2report --alignment_report ./03_bismark/${seqfile}.R1_val_1_bismark_bt2_PE_report.txt \
--dir ./03_bismark_report && echo "03 bismark2report ends"
${bismark_path}bismark2summary ./03_bismark/${seqfile}.R1_val_1_bismark_bt2_pe.bam \
-o ./03_bismark_report/${seqfile}_bismark_summary_report && echo "03 bismark2summary ends"

### bismark deduplicate reads ### 
${bismark_path}deduplicate_bismark -p ./03_bismark/${seqfile}.R1_val_1_bismark_bt2_pe.bam \
--output_dir ./04_bismark_dedup && echo "04 deduplicate reads ends"

### bismark methylation extract & cytosine report ###
${bismark_path}bismark_methylation_extractor -p --no_header --bedGraph --cytosine_report --parallel 20 --genome_folder $ref_genome_dir \
-o ./05_bismark_met ./04_bismark_dedup/${seqfile}.R1_val_1_bismark_bt2_pe.deduplicated.bam && echo "05 bismark methylation extract ends"

