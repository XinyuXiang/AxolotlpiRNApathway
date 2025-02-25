#!/bin/bash

### ref ###
# https://github.com/Xiangyang1984/Gcluster

### annotate CGI by gCluster ###
# prepare sequences and index
python prepareAssembly.py -i AmexG_v6.0-DD.fa -o ./ -l AmexG_v6.0-DD
java -jar makeSeqObj.jar AmexG_v6.0-DD_canonical.fa

# Detect the clusters of DNA words
java -jar gCluster.jar genome=AmexG_v6.0-DD_canonical.zip pattern=CG output=./AmexG_v6.0-DD_CG  writedistribution=true chromStat=true

# filter CGI
# 05_CGI_filter.Rmd
# CGI.df <- data.df %>% filter(gc >= 0.5, len >= 200, oe >= 0.6, pvalue <= 1e-05)

# Clusters of clusters: GenomeCluster.pl
perl GenomeCluster.pl start ./AmexG_v6.0-DD_CG/AmexG_v6.0-DD_CGI.bed gi 1E-5 ./AmexG_v6.0-DD_canonical.N 0
