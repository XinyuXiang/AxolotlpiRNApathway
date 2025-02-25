#!/bin/bash

### ref ###
# https://sourceforge.net/projects/protrac/

### set up ###
fastq_file=./02_fq_trim_v3/${seqfile}_trimmed.fq.gz
genome_ref_path=/reference_AmexG_v6.0/AmexG_v6.0-DD.fa

### modify fq and rm low-complexity ###
zcat ${fastq_file} > ./14_piRNAcluster_v2/tmp.fq
perl ./00_proTRAC/TBr2_collapse.pl -i ./14_piRNAcluster_v2/tmp.fq -o ./14_piRNAcluster_v2/${seqfile}.collapsed 
perl ./00_proTRAC/TBr2_duster.pl -i ./14_piRNAcluster_v2/${seqfile}.collapsed 

### mapping ###
perl ./00_proTRAC/sRNAmapper.pl -i ./14_piRNAcluster_v2/${seqfile}.collapsed.no-dust -g ${genome_ref_path} -mismatch 3 -seedmatch 15 -alignments best 

### piRNA cluster analysis ###
perl ./00_proTRAC/proTRAC_2.4.3.pl -map ./14_piRNAcluster_v2/${seqfile}.collapsed.no-dust.map -genome ${genome_ref_path} -swsize 5000 -pdens 0.01 -pimin 23 -pimax 33 -nohtml -nomotif && rm tmp.fq #-geneset ${gene_gtf_path} 

