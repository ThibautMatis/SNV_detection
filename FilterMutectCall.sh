# FilterMutectCalls function 
# Input [-V] : raw vcf from Mutect2
# Input [-R] : Reference.fa
# --contamination-table : from CalculateContamination function
# --ob-priors : from LearnReadOrientationModel function
# -- others parameters to settled
# output [-O] : filtered.VCF
#
# awk and cut for only keep PASS mutations and removes Normal column information

Ref_genome = $1
Tumor_bam = $2
Normal_bam = $3
Phred = $4
Results = $5
HRD_settings = $6
AF_gnomad = $7
Pon = $8
Exac = $9
threads = $10
ALT_reads = $11

Normal_ID = basename "$Normal_bam" | sed 's/.bam//g'
Tumor_ID = basename "$Tumor_bam" | sed 's/.bam//g'

mkdir ${Results}/VCF_annot
mkdir ${Results}/VCF_filtered

./gatk FilterMutectCalls -V ${Results}/VCF_raw/${Tumor_ID}.vcf.gz \
-R $Ref_genome \
--contamination-table ${Results}/Contamination/${Tumor_ID}.calculatecontamination.table \
--ob-priors ${Results}/ReadOrientationModel/${Tumor_ID}-read-orientation-model.tar.gz \
--min-reads-per-strand $ALT_reads \
-O ${Results}/VCF_annot/${Tumor_ID}.pair.annot.vcf
awk -F '\t' '{if($0 ~ /\#/) print; else if($7 == "PASS") print}' /${Results}/VCF_annot/${Tumor_ID}.pair.annot.vcf > /${Results}/VCF_filtered/${Tumor_ID}.pair.filtered.vcf
cut  --complement -f10 ${Results}/VCF_filtered/${Tumor_ID}.pair.filtered.vcf >  /${Results}/VCF_filtered/${Tumor_ID}.tumor.filtered.vcf
