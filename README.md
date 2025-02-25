# AxolotlpiRNApathway
Scripts for axolotl piRNA pathway related analysis

This repository contains a collection of scripts and pipelines developed for the analysis of the axolotl piRNA pathway. The main functionalities include:

- **Axolotl Transposon Annotation**  
  Scripts for annotating transposons and identifying potentially active transposons in axolotl genome. 

- **piRNA Pathway Analysis**  
  Scripts for identifying piRNA factor expression and features of the piRNA pathway in the axolotl germline.

- **DNA Methylation Analysis**  
  Scripts for analyzing DNA methylation patterns for transposon silencing in axolotl sperm and annotating CpG island.

## Requirements

- Operating System: Linux/Unix/MacOS
- Scripting Languages: R (v4.2.1 or higher), Python (v2.7.5 or higher), Perl (v5.16.3 or higher), Bash
- Software: 
  - For axolotl transposon annotation, this pipeline utilizes `RepeatMasker v4.1.5`, `RepeatModeler v2.0.5`, and `DeepTE` to comprehensively identify and annotate transposons. For potentially active transposon identification, custom scripts with filtering criteria are applied.

  - For piRNA pathway related analysis, this pipeline applies `Cutadapt v2.9` for adapter trimming, `STAR v2.7.0e` for read alignment, `proTRAC v2.4.3` for piRNA cluster detection along with `circlize` for visualization.

  - For DNA methylation analysis, this pipeline employs `Trim Galore v0.6.7` for adapter trimming, `Bismark v0.24.0` for bisulfite alignment and methylation calling, `SeqMonk v1.48.1` for downstream analysis, with custom scripts for visualization. For CpG island annotation, `gCluster` is applied with Gardiner-Garden and Frommer (GGF) method.
