# piRNA Pathway Analysis Pipeline

This pipeline outlines the steps to process RNA-seq and sRNA-seq raw data, visualize piRNA factor expression, annotate piRNA clusters and analysis 1U10A and 10nt-opverlap features.

- Software
  - `FastQC v0.11.8`
  - `Trim Galore v0.6.7`
  - `Cutadapt v2.9`
  - `STAR v2.7.0e`
  - `SAMtools v1.9`
  - `bedtools v2.29.1`
  - `FeatureCounts v2.0.0`
  - `proTRAC v2.4.3`
  - `pheatmap R package`
  - `circlize R package`
  - `ggplot2 R package`


## 1. RNA-seq analysis

01 **preprocess**  
   - Use `fastqc` for QC, `trim_galore` for adptor trimming, `STAR` for alignment, `samtools` for bam sort, `featurecounts` for read quantification.
     
02 **visualization**  
   - Plot heatmap for piRNA factor expression. Normalize to RPKM and plot by pheatmap in R.



## 2. small RNA-seq analysis

03 **preprocess**  
   - Use `fastqc` for QC, `cutadapt` for adptor trimming, `STAR` for alignment, `samtools` for bam sort, `bedtools` for annotation.

04 **genomic analysis**  
   - Get genomic statistics.
   - Identify piRNA clusters

05 **TE consensus analysis**  
   - Plot piRNA tracks over consensus sequences
   - Analysis ping-pong cycle features (1U10A and 10nt-opverlap).





