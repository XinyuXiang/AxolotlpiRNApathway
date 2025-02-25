#!/bin/bash
conda activate RepeatMasker

# setup
RepeatMasker_path=/biosoft/RepeatMasker_related/RepeatMasker/
Refgenome=/reference_AmexG_v6.0/AmexG_v6.0-DD.fa
outdir=01_simple_out

# make a directory for storing logs
mkdir -p logs 01_simple_out 02_known_out 03_unknown_out

# round 1: annotate/mask simple repeats
export BLAST_USAGE_REPORT=false # to accelerate rmblast when run >1 week
${RepeatMasker_path}RepeatMasker -pa 32 -e rmblast -a -dir ${outdir} -gff \
-species "Ambystoma mexicanum" -noint -xsmall \
${Refgenome} 2>&1 | tee logs/01_simple_out.log

# -pa 4 = -threads 16
# -e(ngine) [crossmatch|wublast|abblast|ncbi|hmmer|decypher]
# -a(lignments) Writes alignments in .align output file
# -noint /-int Only masks/annotate low complex/simple repeats (no interspersed repeats)
# -xsmall Returns repetitive regions in lowercase (rest capitals) rather than masked

mv ./01_simple_out/AmexG_v6.0-DD.fa.masked ./01_simple_out/AmexG_v6.0-DD.simple.masked.fasta
