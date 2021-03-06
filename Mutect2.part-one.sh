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


Ref_genome=$1
Interval=$2
Tumor_bam=$3
Normal_bam=$4
Phred=$5
Max_reads_per_alignment_start=$6
Results=$7
AF_gnomad=$8
Pon=$9
Exac=${10}
threads=${11}

Normal_ID=`basename $Normal_bam | sed 's/.bwamem.bam//g'`
Tumor_ID=`basename $Tumor_bam | sed 's/.bwamem.bam//g'`

mkdir $Results/LearnReadOrientationModel
mkdir $Results/ReadOrientationModel
mkdir $Results/Normal_table
mkdir $Results/Tumor_table
mkdir $Results/Contamination
mkdir $Results/VCF_raw

gatk Mutect2 -R $Ref_genome \
-L $Interval \
-I $Tumor_bam \
-I $Normal_bam \
-normal $Normal_ID \
--min-base-quality-score $Phred \
--max-reads-per-alignment-start $Max_reads_per_alignment_start \
--germline-resource $AF_gnomad \
-pon $Pon \
--f1r2-tar-gz ${Results}/LearnReadOrientationModel/${Tumor_ID}-f1r2.tar.gz \
--native-pair-hmm-threads $threads \
-O ${Results}/VCF_raw/${Tumor_ID}.vcf.gz
#
gatk LearnReadOrientationModel -I ${Results}/LearnReadOrientationModel/${Tumor_ID}-f1r2.tar.gz \
-O ${Results}/ReadOrientationModel/${Tumor_ID}-read-orientation-model.tar.gz
#
gatk GetPileupSummaries \
-I $Normal_bam \
-V $Exac \
-L $Exac \
-O ${Results}/Normal_table/${Normal_ID}.getpileupsummaries.table
#
gatk GetPileupSummaries \
-I $Tumor_bam \
-V $Exac \
-L $Exac \
-O ${Results}/Tumor_table/${Tumor_ID}.getpileupsummaries.table
#
gatk CalculateContamination \
-I ${Results}/Tumor_table/${Tumor_ID}.getpileupsummaries.table \
-matched ${Results}/Normal_table/${Normal_ID}.getpileupsummaries.table \
-O ${Results}/Contamination/${Tumor_ID}.calculatecontamination.table

