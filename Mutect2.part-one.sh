# Mutect2 function to provide a first raw vcf Unfiltered
# Input [-I / Tumor] : Tumor.Bam
# Input [-I / Normal] : Normal.bam
# -normal : to inform which one is the normal one
#--germline ressource : gnomAD.vcf dans dossier HRD_settings
#--pon : PanelOfNormal.vcf dans dossier HRD_settings
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

Tumor_bam = $1
Normal_bam = $2
Results = $3
HRD_settings = $4

Normal_ID = basename "$Normal_bam" | sed 's/.bam//g'
Tumor_ID = basename "$Tumor_bam" | sed 's/.bam//g'

mkdir ${Results}/LearnReadOrientationModel
mkdir ${Results}/ReadOrientationModel
mkdir ${Results}/Normal_table
mkdir ${Results}/Tumor_table
mkdir ${Results}/Contamination
mkdir ${Results}/VCF_raw

./gatk Mutect2 -R /data/Reference/hg19.fa \
-I $Tumor_bam \
-I $Normal_bam \
-normal $Normal_ID \
--min-base-quality-score 30 \
--germline-resource /data/gnomAD/af-only-gnomad.raw.sites.hg19.vcf.gz \
-pon /data/PON/PoN.vcf.gz \
--f1r2-tar-gz ${Results}/LearnReadOrientationModel/${Tumor_ID}-f1r2.tar.gz \
--native-pair-hmm-threads 2 \
-O ${Results}/VCF_raw/${Tumor_ID}.vcf.gz
#
./gatk LearnReadOrientationModel -I ${Results}/LearnReadOrientationModel/${Tumor_ID}-f1r2.tar.gz \
-O ${Results}/ReadOrientationModel/${Tumor_ID}-read-orientation-model.tar.gz
#
./gatk GetPileupSummaries \
-I $Normal_bam \
-V /data/gnomAD/small_exac_common_3_hg19.vcf \
-L /data/gnomAD/small_exac_common_3_hg19.vcf \
-O ${Results}/Normal_table/${Normal_ID}.getpileupsummaries.table
#
./gatk GetPileupSummaries \
-I $Tumor_bam \
-V /data/gnomAD/small_exac_common_3_hg19.vcf \
-L /data/gnomAD/small_exac_common_3_hg19.vcf \
-O ${Results}/Tumor_table/${Tumor_ID}.getpileupsummaries.table
#
./gatk CalculateContamination \
-I ${Results}/Tumor_table/${Tumor_ID}.getpileupsummaries.table \
-matched ${Results}/Normal_table/${Normal_ID}.getpileupsummaries.table \
-O ${Results}/Contamination/${Tumor_ID}.calculatecontamination.table
