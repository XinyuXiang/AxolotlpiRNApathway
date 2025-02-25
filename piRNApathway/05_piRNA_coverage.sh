#!/bin/bash

### set up ###
binSize=1000000
piRNAlencutoff=23
genomesize_path=/reference_AmexG_v6.0/AmexG_v6.0-DD.chr.bed
genomesize_bin_path=./14_piRNAcluster_v2/06_circos/AmexG_v6.0-DD.chr.bin${binSize}.bed

# input 
sRNA_genome_bed=04_STAR_genome_mismatch3_overlap15/${seqfile}_genome_srt_edit.bed

# output
piRNA_genome_fwd_bed=14_piRNAcluster_v2/06_circos/${seqfile}_genome_srt_edit.pirna.fwd.bed
piRNA_genome_rev_bed=14_piRNAcluster_v2/06_circos/${seqfile}_genome_srt_edit.pirna.rev.bed
piRNA_genome_fwd_countsum_bed=14_piRNAcluster_v2/06_circos/${seqfile}_genome_srt_edit.pirna.fwd.bin${binSize}.countsum.bed
piRNA_genome_rev_countsum_bed=14_piRNAcluster_v2/06_circos/${seqfile}_genome_srt_edit.pirna.rev.bin${binSize}.countsum.bed
piRNA_genome_fwd_RPM_bed=14_piRNAcluster_v2/06_circos/${seqfile}_genome_srt_edit.pirna.fwd.bin${binSize}.RPM.bed
piRNA_genome_rev_RPM_bed=14_piRNAcluster_v2/06_circos/${seqfile}_genome_srt_edit.pirna.rev.bin${binSize}.RPM.bed
piRNA_genome_fwd_log2RPM_bed=14_piRNAcluster_v2/06_circos/${seqfile}_genome_srt_edit.pirna.fwd.bin${binSize}.log2RPM.bed
piRNA_genome_rev_log2RPM_bed=14_piRNAcluster_v2/06_circos/${seqfile}_genome_srt_edit.pirna.rev.bin${binSize}.log2RPM.bed


### split genomesize.bed by bin ###
${bedops_path}bedops --chop ${binSize} ${genomesize_path} > ${genomesize_bin_path} 

### obtain piRNA genome_cov.bed ###
# split count.bed by strand
# sRNA_genome_bed col: chr, start, end, readID, length, strand, NH
# piRNA_genome_fwd/rev_bed col: chr, start, end, readID, 1/NH, strand
cat ${sRNA_genome_bed} | awk -v cutoff="$piRNAlencutoff" '$6=="+" && $5 >= cutoff { $7 = sprintf("%.3f", 1 / $7); print }' - | awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$7"\t"$6}' - > ${piRNA_genome_fwd_bed}
cat ${sRNA_genome_bed} | awk -v cutoff="$piRNAlencutoff" '$6=="-" && $5 >= cutoff { $7 = sprintf("%.3f", 1 / $7); print }' - | awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$7"\t"$6}' - > ${piRNA_genome_rev_bed}

# calculate bin count sum
bedmap --echo --delim "\t" --sum --prec 3 ${genomesize_bin_path} ${piRNA_genome_fwd_bed} > ${piRNA_genome_fwd_countsum_bed}
bedmap --echo --delim "\t" --sum --prec 3 ${genomesize_bin_path} ${piRNA_genome_rev_bed} > ${piRNA_genome_rev_countsum_bed}

# normalize bin count sum by RPM (count * 1000000/ totalread )
totalread=$(cat ${piRNA_genome_fwd_bed} ${piRNA_genome_rev_bed} | awk -F "\t" '{sum+=$5} END {printf ("%.3f", sum)}') 
awk -v totalread="$totalread" '{ $4 = sprintf("%.3f", $4 *1000000 / totalread ); print }' ${piRNA_genome_fwd_countsum_bed} > ${piRNA_genome_fwd_RPM_bed}
awk -v totalread="$totalread" '{ $4 = sprintf("%.3f", $4 *1000000 / totalread ); print }' ${piRNA_genome_rev_countsum_bed} > ${piRNA_genome_rev_RPM_bed}

# normalize bin count sum by log2(RPM +1)
awk '{ $4 = sprintf("%.3f", log($4+1)/log(2) ); print }' ${piRNA_genome_fwd_RPM_bed} > ${piRNA_genome_fwd_log2RPM_bed}
awk '{ $4 = sprintf("%.3f", log($4+1)/log(2) ); print }' ${piRNA_genome_rev_RPM_bed} > ${piRNA_genome_rev_log2RPM_bed}
