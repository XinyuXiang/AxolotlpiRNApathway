#!/bin/bash

sample=`cat configure_merge.txt`
for seqfile in $sample;
do
{
echo ${seqfile} starts
### set up ###
TE_fa_config=/reference_AmexG_v6.0/AmexG_v6.0_TE_xinyu_anno/AmexG_v6.0_consensus.merge.config 
TEsubfamilylist=`awk '$2 != "Others" {print $1}' ${TE_fa_config} | sort | uniq`

### obtain distance to 5' end ###
bam_mapped_TE_ref_sort=./04_STAR_TE_mismatch3_overlap15/${seqfile}_TE_srt.bam
${samtools_path}samtools view ${bam_mapped_TE_ref_sort} > ./11_views_TE/tmp.sam

for TEsubfamily in $TEsubfamilylist;
do
	{
		# out put 
		dis_plus_txt=./11_views_TE_v2/06_5enddis/${seqfile}.${TEsubfamily%#*}.dis_plus.txt
		dis_minus_txt=./11_views_TE_v2/06_5enddis/${seqfile}.${TEsubfamily%#*}.dis_minus.txt
		gap_count_txt=./11_views_TE_v2/06_5enddis/${seqfile}.${TEsubfamily%#*}.gap_count.txt

		# script
		awk -F "\t" '$3=="'"$TEsubfamily"'" ' ./11_views_TE/tmp.sam > ./11_views_TE/tmp2.sam
		perl ./00_script/filter_plus_v3.pl ./11_views_TE/tmp2.sam > ${dis_plus_txt} # filter FLAG==0, best alignment map to + strand, count = 1
		perl ./00_script/filter_minus_v3.pl ./11_views_TE/tmp2.sam > ${dis_minus_txt} # filter FLAG==16, best alignment map to - strand, count = 1

		perl ./00_script/allgap.pl ${dis_minus_txt} ${dis_plus_txt} > ./11_views_TE/tmp.txt
		perl ./00_script/sum_count.pl ./11_views_TE/tmp.txt | perl ./00_script/count_last_column.pl | perl ./00_script/ping-pong_range.pl > ${gap_count_txt} && rm ./11_views_TE/tmp.txt

	}
done

echo ${seqfile} ends
}
done


rm ./11_views_TE/tmp.sam
rm ./11_views_TE/tmp2.sam


