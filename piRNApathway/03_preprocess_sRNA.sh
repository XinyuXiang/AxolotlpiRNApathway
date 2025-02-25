#!/bin/bash

### fasqc ###
${fastqc_path}fastqc ./01_fq/${seqfile}.fq.gz -o ./01_fastqc && echo fastqc ends


### cutadapt ###
# Adapter sequences: fw=AGATCGGAAGAGCACACGTCT; rv=AGATCGGAAGAGCGTCGTGTA
# + 4 bases to avoid ligation biases. (trim +-4nt)

cutadapt --cores=16 -a AGATCGGAAGA -o ./02_fq_trim/${seqfile}_trimmed.fq.gz -m 16 --trimmed-only ./01_fq/${seqfile}.fq.gz && echo cutadapt ends
cutadapt --cores=16 -u 4 -u -4 -o ./02_fq_trim_v3/${seqfile}_trimmed.fq.gz -m 16 ./02_fq_trim/${seqfile}_trimmed.fq.gz && echo cutadapt -u 4 -u -4 ends


##### genome #####
### set up ###
fastq_file=./02_fq_trim_v3/${seqfile}_trimmed.fq.gz
genome_ref_path=/reference_AmexG_v6.0/STAR_index_AmexG_v6.0_noGTF
TEref=/reference_AmexG_v6.0/AmexG_v6.0_TE_xinyu_anno/AmexG_v6.0-DD.TE.bed
Generef=/reference_AmexG_v6.0/AmexT_v47-AmexG_v6.0-DD.bed

STAR_align_prefix=./04_STAR_genome_mismatch3_overlap15/${seqfile}_genome
sam_mapped_genome_ref=./04_STAR_genome_mismatch3_overlap15/${seqfile}_genomeAligned.out.sam
bam_mapped_genome_ref=./04_STAR_genome_mismatch3_overlap15/${seqfile}_genome.bam
bam_mapped_genome_ref_sort=./04_STAR_genome_mismatch3_overlap15/${seqfile}_genome_srt.bam
bed_mapped_genome_ref_sort=./04_STAR_genome_mismatch3_overlap15/${seqfile}_genome_srt.bed
bed_mapped_genome_ref_sort_edit=./04_STAR_genome_mismatch3_overlap15/${seqfile}_genome_srt_edit.bed


### STAR alignment ###
${STAR_path}STAR --runMode genomeGenerate --runThreadN 32 --limitGenomeGenerateRAM 120000000000 \
--genomeDir ./STAR_index_AmexG_v6.0_noGTF --genomeFastaFiles AmexG_v6.0-DD.fa

# 15nt matched bases, report all hits and count 1/n for quantification
${STAR_path}STAR \
--genomeDir ${genome_ref_path} \
--readFilesIn ${fastq_file} --readFilesCommand zcat \
--outFilterMultimapNmax 1000 --outFilterMismatchNmax 3 --outSAMmultNmax -1 --outFilterMatchNmin 15 \
--outSAMunmapped Within --outReadsUnmapped Fastx \
--outFileNamePrefix ${STAR_align_prefix} && echo "STAR align ends"


### sort mkdix ###
${samtools_path}samtools view -bS -o ${bam_mapped_genome_ref} ${sam_mapped_genome_ref} && rm ${sam_mapped_genome_ref}
${samtools_path}samtools sort -o ${bam_mapped_genome_ref_sort} ${bam_mapped_genome_ref} && rm ${bam_mapped_genome_ref}


### output count ###
${bedtools_path}bedtools bamtobed -tag NH -i ${bam_mapped_genome_ref_sort} > ${bed_mapped_genome_ref_sort} # NH: mul-alignment site number
perl ./00_script/bed_edit.pl ${bed_mapped_genome_ref_sort} > ${bed_mapped_genome_ref_sort_edit} && rm ${bed_mapped_genome_ref_sort} # output: chr, start, end, readID, length, strand, NH


### TE annotation ###
${bedtools_path}bedtools intersect -a ./04_STAR_genome_mismatch3_overlap15/${seqfile}_genome_srt_edit.bed -b ${TEref} -wa -wb > ./05_STARmis3_overlap15_anno_Genome/${seqfile}_RM.bed

### gene annotation ###
# note: only exon regions are used (due to long intron length)
${bedtools_path}bedtools intersect -a ./04_STAR_genome_mismatch3_overlap15/${seqfile}_genome_srt_edit.bed -b ${TEref} -v > ./05_STARmis3_overlap15_anno_Genome/${seqfile}_nonRM.bed
${bedtools_path}bedtools intersect -a ./05_STARmis3_overlap15_anno_Genome/${seqfile}_nonRM.bed -b ${Generef} -wa -wb > ./05_STARmis3_overlap15_anno_Genome/${seqfile}_gene.bed

### non-coding annotation ###
${bedtools_path}bedtools intersect -a ./05_STARmis3_overlap15_anno_Genome/${seqfile}_nonRM.bed -b ${Generef} -wa -wb -v > ./05_STARmis3_overlap15_anno_Genome/${seqfile}_other.bed && rm ./05_STARmis3_overlap15_anno_Genome/${seqfile}_nonRM.bed




##### TE consensus #####
### set up ###
fastq_file=./02_fq_trim_v3/${seqfile}_trimmed.fq.gz
TE_ref_path=/reference_AmexG_v6.0/STAR_index_AmexG_v6.0_consensus.merge
STAR_align_prefix=./04_STAR_TE_mismatch3_overlap15/${seqfile}_TE
sam_mapped_TE_ref=./04_STAR_TE_mismatch3_overlap15/${seqfile}_TEAligned.out.sam
bam_mapped_TE_ref=./04_STAR_TE_mismatch3_overlap15/${seqfile}_TE.bam
bam_mapped_TE_ref_sort=./04_STAR_TE_mismatch3_overlap15/${seqfile}_TE_srt.bam
bed_mapped_TE_ref_sort=./04_STAR_TE_mismatch3_overlap15/${seqfile}_TE_srt.bed
bed_mapped_TE_ref_sort_edit=./04_STAR_TE_mismatch3_overlap15/${seqfile}_TE_srt_edit.bed


### STAR alignment ###
${STAR_path}STAR --runMode genomeGenerate --runThreadN 32 --limitGenomeGenerateRAM 120000000000 \
--genomeSAindexNbases 9 --genomeDir ./STAR_index_AmexG_v6.0_consensus.merge --genomeFastaFiles AmexG_v6.0_consensus.merge.fa

# 15nt matched bases, report all hits and count 1/n for quantification
${STAR_path}STAR \
--genomeDir ${TE_ref_path} \
--readFilesIn ${fastq_file} --readFilesCommand zcat \
--outFilterMultimapNmax 1000 --outFilterMismatchNmax 3 --outSAMmultNmax -1 --outFilterMatchNmin 15 \
--outSAMunmapped Within --outReadsUnmapped Fastx \
--outFileNamePrefix ${STAR_align_prefix} && echo "STAR align ends"

### sort mkdix ###
${samtools_path}samtools view -bS -o ${bam_mapped_TE_ref} ${sam_mapped_TE_ref} && rm ${sam_mapped_TE_ref}
${samtools_path}samtools sort -o ${bam_mapped_TE_ref_sort} ${bam_mapped_TE_ref} && rm ${bam_mapped_TE_ref}

${bedtools_path}bedtools bamtobed -tag NH -i ${bam_mapped_TE_ref_sort} > ${bed_mapped_TE_ref_sort} # NH: mul-alignment site number
perl ./00_script/bed_edit.pl ${bed_mapped_TE_ref_sort} > ${bed_mapped_TE_ref_sort_edit} && rm ${bed_mapped_TE_ref_sort} # output: chr, start, end, readID, length, strand, NH



