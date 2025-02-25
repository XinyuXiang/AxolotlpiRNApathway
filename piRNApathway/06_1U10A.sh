#!/bin/bash

### set up ###
TE_fa_config=/reference_AmexG_v6.0/AmexG_v6.0_TE_xinyu_anno/AmexG_v6.0_consensus.merge.config 

sample=`cat configure_merge.txt`
TEsubfamilylist=`awk '$2 != "Others" {print $1}' ${TE_fa_config} | sort | uniq`

### calculate 1U10A ###
for seqfile in $sample;
do
{
        ## input ##
        bam_mapped_TE_ref_sort=./04_STAR_TE_mismatch3_overlap15/${seqfile}_TE_srt.bam
        tmp_sam=11_views_TE_v2/07_1U10A/tmp.${seqfile}.sam
        ${samtools_path}samtools view ${bam_mapped_TE_ref_sort} > ${tmp_sam}

        for TEsubfamily in $TEsubfamilylist;
        do
        {
                # output
                tmp_count_txt=11_views_TE_v2/07_1U10A/tmp.txt
                count_nuc_txt=11_views_TE_v2/07_1U10A/piRNA.${seqfile}.${TEsubfamily%#*}.count_nuc.txt

                # extract sequence and mapped score = 1/NH (mul-alignment site number) for each TEsubfamily
                awk -F "\t" -v TEsubfamily="$TEsubfamily" ' $3 == TEsubfamily {print $10"\t"$12}' ${tmp_sam} | sed 's/NH:i://g' | awk '{printf "%s\t%.2f\n", $1, (1/$2)}' > ${tmp_count_txt}
                # calculate sum(score) for ATCG at first and tenth nucleotide
                perl ./00_script/First_tenth_base_ID_v2.pl ${tmp_count_txt} > ${count_nuc_txt} && rm ${tmp_count_txt}
        }
        done

echo ${seqfile} ends  && rm ${tmp_sam}
}
done


