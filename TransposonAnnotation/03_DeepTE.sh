#!/bin/bash
conda activate DeepTE

# setup
out_dir=/20231101axolotl_TEanno/03_DeepTE/
DeepTE_path=/biosoft/RepeatMasker_related/DeepTE/
model_dir=/biosoft/RepeatMasker_related/DeepTE/Metazoans_model/

# split known and unknown 
cat AmexG_v6.0-families.fa | seqkit fx2tab | grep -v "Unknown" | seqkit tab2fx > AmexG_v6.0_consensus.known.fa
cat AmexG_v6.0-families.fa | seqkit fx2tab | grep "Unknown" | seqkit tab2fx > AmexG_v6.0_consensus.unknown.fa

# annotate unknown
input_fasta=/20231101axolotl_TEanno/01_RepeatModeler/AmexG_v6.0_consensus.unknown.fa
python ${DeepTE_path}DeepTE.py -d ${out_dir} -o ${out_dir} -i ${input_fasta} -sp M -m_dir ${model_dir} >& ./logs/AmexG_v6.0.log

# spilt known and still unknown 
cp ./DeepTE.AmexG_v6.0_consensus.unknown/opt_DeepTE.fasta AmexG_v6.0_consensus.unknown.DeepTE.fa
cat AmexG_v6.0_consensus.unknown.DeepTE.fa | seqkit fx2tab | grep "unknown" | seqkit tab2fx > AmexG_v6.0_consensus.unknown.DeepTE.unknown.fa
cat AmexG_v6.0_consensus.unknown.DeepTE.fa | seqkit fx2tab | grep -v "unknown" | seqkit tab2fx > AmexG_v6.0_consensus.unknown.DeepTE.known.fa

# final consensus file
# known: Merge known consensus (ancestor, RepeatModeler-known, DeepTE-known)
cat ./02_famdb_ancestor/Dfam.Amex.ancestors.fa ./01_RepeatModeler/AmexG_v6.0_consensus.known.fa ./03_DeepTE/AmexG_v6.0_consensus.unknown.DeepTE.known.fa > ./04_RepeatMasker/AmexG_v6.0_consensus.known.merge.fa

# unknown: DeepTE-unknown
cp ./03_DeepTE/AmexG_v6.0_consensus.unknown.DeepTE.unknown.fa ./04_RepeatMasker/AmexG_v6.0_consensus.unknown.fa

# merge known and unknown
consensus_merge_fa=/20231101axolotl_TEanno/04_RepeatMasker/AmexG_v6.0_consensus.known.merge.fa 
unknown_fa=/20231101axolotl_TEanno/04_RepeatMasker/AmexG_v6.0_consensus.unknown.fa 
merge_fa=/20231101axolotl_TEanno/04_RepeatMasker/AmexG_v6.0_consensus.merge.fa 

cat $consensus_merge_fa $unknown_fa > $merge_fa

# note: before repeatmasker annotation, "Interspersed_Repeat;Pseudogene;RNA;rRNA/tRNA" from fa files are removed.
