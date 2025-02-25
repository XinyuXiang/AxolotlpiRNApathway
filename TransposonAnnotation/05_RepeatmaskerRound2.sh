#!/bin/bash
conda activate RepeatMasker

# setup
RepeatMasker_path=/biosoft/RepeatMasker_related/RepeatMasker/
Refgenome=./01_simple_out/AmexG_v6.0-DD.simple.masked.fasta
consensus_merge_fa=/0231101axolotl_TEanno/04_RepeatMasker/AmexG_v6.0_consensus.known.merge.fa 
outdir=02_known_out

# round 2: annotate known consensus using output from round 1
export BLAST_USAGE_REPORT=false # to accelerate rmblast when run >1 week

${RepeatMasker_path}RepeatMasker -pa 32 -e rmblast -a -dir ${outdir} -gff \
-lib ${consensus_merge_fa} -nolow \
${Refgenome} 2>&1 | tee logs/02_known_out.log

# -a(lignments) Writes alignments in .align output file

mv ./02_known_out/AmexG_v6.0-DD.simple.masked.fasta.masked ./02_known_out/AmexG_v6.0-DD.simple.known.masked.fasta
