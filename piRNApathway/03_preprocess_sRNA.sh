#!/bin/bash

### fasqc ###
${fastqc_path}fastqc ./01_fq/${seqfile}.fq.gz -o ./01_fastqc && echo fastqc ends

### cutadapt ###
# Adapter sequences: fw=AGATCGGAAGAGCACACGTCT; rv=AGATCGGAAGAGCGTCGTGTA
# + 4 bases to avoid ligation biases. (trim +-4nt)

cutadapt --cores=16 -a AGATCGGAAGA -o ./02_fq_trim/${seqfile}_trimmed.fq.gz -m 16 --trimmed-only ./01_fq/${seqfile}.fq.gz && echo cutadapt ends
cutadapt --cores=16 -u 4 -u -4 -o ./02_fq_trim_v3/${seqfile}_trimmed.fq.gz -m 16 ./02_fq_trim/${seqfile}_trimmed.fq.gz && echo cutadapt -u 4 -u -4 ends



