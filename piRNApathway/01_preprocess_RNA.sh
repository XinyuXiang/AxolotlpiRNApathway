#!/bin/bash

### prefetch and dump ###
prefetch -X 150G -O ./01_fq ${seqfile} 

fastq-dump --gzip --split-3  ./01_fq/${seqfile} -O ./01_fq && echo "fastq-dump ends"
fastqc ./01_fq/${seqfile}_1.fastq.gz ./01_fq/${seqfile}_2.fastq.gz -o ./02_fastqc && echo ${seqfile} fastqc is done


### trimming sequences ###
trim_galore --paired --length 25 --trim-n --clip_R1 5 --clip_R2 5 --gzip --fastqc \
--fastqc_args "-o ./02_fastqc" -o ./02_fq_trim \
./01_fq/${seqfile}_1.fastq.gz ./01_fq/${seqfile}_2.fastq.gz && echo ${seqfile} trimming is done


### STAR alignment ###
${STAR_path}STAR --runMode genomeGenerate --limitGenomeGenerateRAM 130000000000 \
--genomeDir ./STAR_index_AmexG_v6.0_withGTF --genomeFastaFiles AmexG_v6.0-DD.fa --sjdbGTFfile AmexT_v47-AmexG_v6.0-DD.gtf

${STAR_path}STAR \
--genomeDir ${ref_path}STAR_index_AmexG_v6.0_withGTF \
--readFilesCommand zcat \
--readFilesIn ./02_fq_trim/${seqfile}_1_val_1.fq.gz ./02_fq_trim/${seqfile}_2_val_2.fq.gz \
--outFilterMultimapNmax 1000 --outFilterMismatchNmax 3 --outSAMmultNmax 1 \
--outFileNamePrefix ./03_STAR_v2/$seqfile && echo "STAR align ends"


### sort mkdix ###
${samtools_path}samtools view -bS ./03_STAR_v2/${seqfile}Aligned.out.sam > ./03_STAR_v2/${seqfile}.bam && rm ./03_STAR_v2/${seqfile}Aligned.out.sam
${samtools_path}samtools sort ./03_STAR_v2/${seqfile}.bam -o ./03_STAR_v2/${seqfile}_srt.bam && rm ./03_STAR_v2/${seqfile}.bam
${samtools_path}samtools index -c ./03_STAR_v2/${seqfile}_srt.bam


### count gene ###
${featureCounts_path}featureCounts -a ${ref_path}AmexT_v47-AmexG_v6.0-DD.gtf \
-p -B -P -C -T 20 \
-t exon -g gene_id \
-o ./05_count_v2/${seqfile}_gene.txt ./03_STAR_v2/${seqfile}_srt.bam

