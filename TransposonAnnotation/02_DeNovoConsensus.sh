#!/bin/bash

# setup
RepeatModeler_path=/biosoft/RepeatMasker_related/RepeatModeler-2.0.3/
Refgenome=AmexG_v6.0-DD.fa

# make a directory for storing logs
mkdir -p logs

# build new RepeatModeler BLAST database
${RepeatModeler_path}BuildDatabase -engine rmblast -name AmexG_v6.0 ${Refgenome}

# run RepeatModeler
export BLAST_USAGE_REPORT=false # to accelerate rmblast when run >1 week
${RepeatModeler_path}RepeatModeler -pa 32 -database AmexG_v6.0 -LTRStruct -engine rmblast  >& ./logs/AmexG_v6.0.run.log
