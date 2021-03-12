# FilterMutectCalls function 
# Input [-V] : raw vcf from Mutect2
# Input [-R] : Reference.fa
# --contamination-table : from CalculateContamination function
# --ob-priors : from LearnReadOrientationModel function
# -- others parameters to settled
# output [-O] : filtered.VCF
#
# awk and cut for only keep PASS mutations and removes Normal column information


./gatk FilterMutectCalls -V /data/VCF/Unfiltered/Pair2.vcf.gz \
-R /data/Reference/hg19.fa \
--contamination-table /data/gatk-copy/Tumor-table/AFN-1985.calculatecontamination.table \
--ob-priors /data/gatk-copy/Pair19-read-orientation-model.tar.gz \
--min-reads-per-strand 10 \
-O /data/Pair2.prefiltered_0%.vcf
awk -F '\t' '{if($0 ~ /\#/) print; else if($7 == "PASS") print}' /data/Pair2.prefiltered_0%.vcf > /data/Pair2.filtered.vcf
cut  --complement -f10 /data/VCF/Filtered_0%/Pair19.filtered.vcf >  /data/VCF/Filtered_0%/AFN-2214.filtered.vcf
