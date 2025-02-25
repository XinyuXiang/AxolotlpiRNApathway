# DNA methylation Analysis Pipeline

This pipeline outlines the steps to annotate CpG islands, process EM-seq raw data and visualize DNA methylation levels.

- Software
  - `FastQC v0.11.8`
  - `Trim Galore v0.6.7`
  - `Bismark v0.24.0`
  - `SeqMonk v1.48.1`
  - `gCluster`



## 1. EM-seq analysis

01 **preprocess**  
   - Use `fastqc` for QC, `Trim Galore` for adptor trimming, `Bismark` for bisulfite alignment and methylation calling.

02 **analysis**  
   - Use `Seqmonk` for downstream analysis.

03 **plot**  
   - Plot methylation level over genomic regions and TEs.


## 2. CpG island annotation

04 **annotation**  
   - Annotate CpG islands by `gCluster`.
     
05 **filter**  
   - Filter CpG islands by Gardiner-Garden and Frommer (GGF) criteria.

06 **plot**  
   - Plot CGI statistics, overlap with TEs and TSSs.
