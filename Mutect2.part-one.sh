# Mutect2 function to provide a first raw vcf Unfiltered
# Input [-I / Tumor] : Tumor.Bam
# Input [-I / Normal] : Normal.bam
# -normal : to inform which one is the normal one
#--germline ressource : gnomAD.vcf
#--pon : PanelOfNormal.vcf
# output --f1r2 : file for LearnReadOrientationModel for strand bias analysis
# output [-O] : output.raw.vcf
#
# LearnReadOrientationModel function for strand bias analysis
# Input [-I] : f1r2 obtain previously from Mutect2 function
# output [-O] : table with strand bias information for FilterMutectCalls function
#
# GetPileupSummaries for Normal and Tumor, for cross sample contamination
# Input [-I] : [Normal or Tumor].Bam
# Input [-V] & [-L] : are a small common snp list
# output [-O] : GetPileupSummaries.[Normal or Tumor].table
#
# CalculateContamination
# Input [-I] : GetPileupSummaries.tumor.table
# Input [-I] : GetPileupSummaries.normal.table
# output [-O] : contamination.tumor.table


./gatk Mutect2 -R /data/Reference/hg19.fa \
-I /data/Bam_data/Tumor/AFN-2174.bam \
-I /data/Bam_data/Blood/AFN-2492.bam \
-normal AFN-02492 \
--min-base-quality-score 30 \
--germline-resource /data/gnomAD/af-only-gnomad.raw.sites.hg19.vcf.gz \
-pon /data/PON/PoN.vcf.gz \
--f1r2-tar-gz Pair23-f1r2.tar.gz \
--native-pair-hmm-threads 2 \
-O /data/VCF/Pair23.vcf.gz
#
./gatk LearnReadOrientationModel -I Pair23-f1r2.tar.gz -O Pair23-read-orientation-model.tar.gz
#
./gatk GetPileupSummaries \
-I /data/Bam_data/Tumor/AFN-2174.bam \
-V /data/gnomAD/small_exac_common_3_hg19.vcf \
-L /data/gnomAD/small_exac_common_3_hg19.vcf \
-O Tumor-table/AFN-2214.getpileupsummaries.table
#
./gatk GetPileupSummaries \
-I /data/Bam_data/Blood/AFN-2205.bam \
-V /data/gnomAD/small_exac_common_3_hg19.vcf \
-L /data/gnomAD/small_exac_common_3_hg19.vcf \
-O Normal-table/AFN-2205.getpileupsummaries.table
#
./gatk CalculateContamination \
-I Tumor-table/AFN-2214.getpileupsummaries.table \
-matched Normal-table/AFN-2205.getpileupsummaries.table \
-O Tumor-table/AFN-2214.calculatecontamination.table
