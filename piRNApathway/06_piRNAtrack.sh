#!/bin/bash

### 00. set up ###
TE_fa_config=/datastore/home/s2215896/reference_AmexG_v6.0/AmexG_v6.0_TE_xinyu_anno/AmexG_v6.0_consensus.merge.config 
TE_fa_fai=/datastore/home/s2215896/reference_AmexG_v6.0/AmexG_v6.0_TE_xinyu_anno/AmexG_v6.0_consensus.merge.fa.fai
TE_fa_bed=/datastore/home/s2215896/reference_AmexG_v6.0/AmexG_v6.0_TE_xinyu_anno/AmexG_v6.0_consensus.merge.bed

TEsubfamilylist=`awk '$2 != "Others" {print $1}' ${TE_fa_config} | sort | uniq`


### 01. obtain TE_consensi.bed ###
#awk '{print $1 "\t" "0" "\t" $2}' ${TE_fa_fai} > ${TE_fa_bed}


### 02. split TE_consensi.bed by bin ###
binSize=1
for TEsubfamily in $TEsubfamilylist;
do
{
        TEbed_chop=11_views_TE_v2/01_TE_track/TEsplitbin/${TEsubfamily%#*}.bed 
        awk '$1=="'"$TEsubfamily"'"{print $0}' ${TE_fa_bed} | bedops --chop ${binSize} - > ${TEbed_chop}
}
done && echo split TE_consensi.bed by bin ends



### 03. obtain TEcov.bed for piRNA ###
piRNAlencutoff=23

sample_list=`cat configure_merge.txt`
for seqfile in $sample_list;
do
{
        echo ${seqfile} starts
        # input
        map_bed=04_STAR_TE_mismatch3_overlap15/${seqfile}_TE_srt_edit.bed
        # output
        map_fwd_bed=04_STAR_TE_mismatch3_overlap15/${seqfile}_TE_srt_edit.fwd.bed
        map_rev_bed=04_STAR_TE_mismatch3_overlap15/${seqfile}_TE_srt_edit.rev.bed

        # split count.bed by strand, calculate mapped score = 1/NH (mul-alignment site number)
        cat ${map_bed} | awk '$6=="+" {printf "%s\t%s\t%s\t%s\t%.2f\t%s\n", $1, $2, $3, $4, (1/$7), $6}' - > ${map_fwd_bed}
        cat ${map_bed} | awk '$6=="-" {printf "%s\t%s\t%s\t%s\t%.2f\t%s\n", $1, $2, $3, $4, (1/$7), $6}' - > ${map_rev_bed}
        

        for TEsubfamily in $TEsubfamilylist;
        do
        {
                # input
                TEbed_chop=11_views_TE_v2/01_TE_track/TEsplitbin/${TEsubfamily%#*}.bed
                # output
                tmp_fwd_bed=04_STAR_TE_mismatch3_overlap15/tmp.fwd.bed
                tmp_rev_bed=04_STAR_TE_mismatch3_overlap15/tmp.rev.bed
                bedmap_fwd_bed=11_views_TE_v2/01_TE_track/TEcovbed_piRNA/${seqfile}.${TEsubfamily%#*}.fwd.bed
                bedmap_rev_bed=11_views_TE_v2/01_TE_track/TEcovbed_piRNA/${seqfile}.${TEsubfamily%#*}.rev.bed

                # obtain TEcov.bed for piRNA
                awk -v TEsubfamily="$TEsubfamily" -v piRNAlencutoff="$piRNAlencutoff" '$1 == TEsubfamily && length($4) >= piRNAlencutoff {print $0}' ${map_fwd_bed} > ${tmp_fwd_bed}
                bedmap --echo --delim "\t" --sum --prec 2 ${TEbed_chop} ${tmp_fwd_bed} > ${bedmap_fwd_bed} && rm ${tmp_fwd_bed}
                        
                awk -v TEsubfamily="$TEsubfamily" -v piRNAlencutoff="$piRNAlencutoff" '$1 == TEsubfamily && length($4) >= piRNAlencutoff {print $0}' ${map_rev_bed} > ${tmp_rev_bed}
                bedmap --echo --delim "\t" --sum --prec 2 ${TEbed_chop} ${tmp_rev_bed} > ${bedmap_rev_bed} && rm ${tmp_rev_bed}

        }
        done
        
echo ${seqfile} ends
}
done && echo obtain TEcov.bed for piRNA ends



