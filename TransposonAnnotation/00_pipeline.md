# Transposon Annotation Pipeline

This pipeline outlines the steps to obtain TE consensus sequences and annotate the genome in multiple rounds.

- Software
  - `RepeatMasker v4.1.5`
  - `RepeatModeler v2.0.5`
  - `DeepTE`

## 1. Obtain TE Consensus Sequences

01 **Dfam Consensus for TE Ancestors**  
   - Use `RepeatMasker/famdb.py` to obtain ancestor TE consensus sequences for axolotl.
02 **De Novo Annotation for TE Consensus**  
   - Run `RepeatModeler` to generate de novo TE consensus sequences.

03 **Further Annotation for Unknown TE Consensus**  
   - Apply `DeepTE` to provide additional annotation for TE consensus sequences that remain unclassified.

## 2. Genome Annotation in Multiple Rounds

04 **Round 1: Annotate Simple Repeats**  
   - Identify and annotate simple repeats in the genome.

05 **Round 2: Annotate Known TEs**  
   - Combine the TE consensus from ancestors, de novo predictions, and DeepTE annotated known sequences for comprehensive coverage.
   - Annotate combined known TE consensus

06 **Round 3: Annotate Unknown TEs**  
   - Annotate remaining unknown TEs from DeepTE.
   - Integrate the results from all three rounds to produce the final, comprehensive genome annotation.

## 3. Potential Active TE Annotation
07 **Identify Potential Active TEs**
   - Identify potential active TEs with length cutoff and percDiv cutoff.

