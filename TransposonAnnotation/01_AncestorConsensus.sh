#!/bin/bash
conda activate RepeatMasker

# setup
RepeatMasker_path=/biosoft/RepeatMasker_related/RepeatMasker/
Dfam_h5=/biosoft/RepeatMasker_related/RepeatMasker/Libraries/Dfam.h5

# obtain Dfam database consensus
# https://github.com/Dfam-consortium/FamDB
${RepeatMasker_path}famdb.py -i ${Dfam_h5} families --ancestors -f fasta_name --include-class-in-name "Ambystoma mexicanum" > Dfam.Amex.ancestors.fasta
