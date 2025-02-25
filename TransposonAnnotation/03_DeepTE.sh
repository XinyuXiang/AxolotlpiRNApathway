#!/bin/bash
conda activate DeepTE

# setup
out_dir=/20231101axolotl_TEanno/03_DeepTE/
DeepTE_path=/biosoft/RepeatMasker_related/DeepTE/
model_dir=/biosoft/RepeatMasker_related/DeepTE/Metazoans_model/

# Split known and unknown 
cat AmexG_v6.0-families.fa | seqkit fx2tab | grep -v "Unknown" | seqkit tab2fx > AmexG_v6.0_consensus.known.fa
cat AmexG_v6.0-families.fa | seqkit fx2tab | grep "Unknown" | seqkit tab2fx > AmexG_v6.0_consensus.unknown.fa

# annotate unknown
input_fasta=/20231101axolotl_TEanno/01_RepeatModeler/AmexG_v6.0_consensus.unknown.fa
python ${DeepTE_path}DeepTE.py -d ${out_dir} -o ${out_dir} -i ${input_fasta} -sp M -m_dir ${model_dir} >& ./logs/AmexG_v6.0.log
