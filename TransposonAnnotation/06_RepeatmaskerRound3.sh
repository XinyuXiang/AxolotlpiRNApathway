#!/bin/bash
conda activate RepeatMasker

# setup
RepeatMasker_path=/biosoft/RepeatMasker_related/RepeatMasker/
Refgenome=./02_known_out/AmexG_v6.0-DD.simple.known.masked.fasta
unknown_fa=/20231101axolotl_TEanno/04_RepeatMasker/AmexG_v6.0_consensus.unknown.fa 
outdir=03_unknown_out

# round 3: annotate/mask still unknown TEs using output from round 2
export BLAST_USAGE_REPORT=false # to accelerate rmblast when run >1 week

${RepeatMasker_path}RepeatMasker -pa 24 -e rmblast -a -dir ${outdir} -gff \
-lib ${unknown_fa} -nolow \
${Refgenome} 2>&1 | tee logs/03_unknown_out.log

# -a(lignments) Writes alignments in .align output file

# Merge and generate TE.bed
# adjust format and merge
awk 'NR > 3 {print $5"\t"$6"\t"$7"\t"$10"\t"$2"\t"$9"\t"$11}' 01_simple_out/AmexG_v6.0-DD.fa.out > 01_simple_out/AmexG_v6.0-DD.simple.bed
awk 'NR > 3 {print $5"\t"$6"\t"$7"\t"$10"\t"$2"\t"$9"\t"$11}' 02_known_out/AmexG_v6.0-DD.simple.masked.fasta.out | awk 'BEGIN { FS=OFS="\t" } { if ($6 == "C") $6 = "-"; print }' > 02_known_out/AmexG_v6.0-DD.known.bed
awk 'NR > 3 {print $5"\t"$6"\t"$7"\t"$10"\t"$2"\t"$9"\t"$11}' 03_unknown_out/AmexG_v6.0-DD.simple.known.masked.fasta.out | awk 'BEGIN { FS=OFS="\t" } { if ($6 == "C") $6 = "-"; print }' > 03_unknown_out/AmexG_v6.0-DD.unknown.bed

cat 01_simple_out/AmexG_v6.0-DD.simple.bed 02_known_out/AmexG_v6.0-DD.known.bed 03_unknown_out/AmexG_v6.0-DD.unknown.bed | sort -k1,1 -k2,2n -k3,3n > 04_merge/AmexG_v6.0-DD.TE.bed 

# generate TE class info
awk -F "\t" 'BEGIN {OFS="\t"} {split($7,a,"/"); $8=a[1]; print}' 04_merge/AmexG_v6.0-DD.TE.bed > 04_merge/AmexG_v6.0-DD.TE.v2.bed

# copy to annotation folder
cp 04_merge/AmexG_v6.0-DD.TE.v2.bed /reference_AmexG_v6.0/AmexG_v6.0-DD.TE.bed
