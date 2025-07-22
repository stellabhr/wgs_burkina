#!/bin/bash
#-----------------------------------------------------------------
# Some filtering etc.
#-----------------------------------------------------------------

#SBATCH -J atfilter          
#SBATCH -o logs/log.atfilter.%j.out 
#SBATCH -n 1 
#SBATCH -p "htc-el8"
#SBATCH --mem=10GB
#SBATCH -t 7:00:00
#SBATCH --cpus-per-task=2
#SBATCH -A huber

#----------------------------------------------------------------

module load BCFtools/1.21-GCC-13.3.0


#bcftools +fill-tags rnaseq/ehtbf_rna_combined_filtered_variants.vcf.gz -Oz -o rnaseq/ehtbf_rna_extratags.vcf.gz -- -t all

bcftools filter -e'F_MISSING>=0.05' rnaseq/ehtbf_rna_extratags.vcf.gz -Oz -o rnaseq/ehtbf_rna_missing.vcf.gz

bcftools filter -i'MAF>0.01' rnaseq/ehtbf_rna_missing.vcf.gz -Oz -o rnaseq/ehtbf_rna_miss_maf.vcf.gz

bcftools view -i'FMT/DP>5 && FMT/GQ>20' rnaseq/ehtbf_rna_miss_maf.vcf.gz > rnaseq/ehtbf_rna_miss_maf_gq_dp.vcf

bcftools view -M2 -e'HWE<=0.000001' rnaseq/ehtbf_rna_miss_maf_gq_dp.vcf > rnaseq/ehtbf_rna_final.vcf | bgzip -c > rnaseq/ehtbf_rna_final_zip.vcf.gz

mv rnaseq/ehtbf_rna_final_zip.vcf.gz rnaseq/ehtbf_rna_final.vcf.gz

bcftools stats rnaseq/ehtbf_rna_final.vcf.gz > rnaseq/ehtbf_rna_final.stats

bcftools index rnaseq/ehtbf_rna_final.vcf.gz