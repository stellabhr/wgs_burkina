#!/bin/bash
#-----------------------------------------------------------------
# Using plink to perform PCA
#-----------------------------------------------------------------

#SBATCH -J plinkpca          
#SBATCH -o logs/log.plinkpca.%j.out 
#SBATCH -n 1 
#SBATCH -p "htc-el8"
#SBATCH --mem=20GB
#SBATCH -t 8:00:00
#SBATCH --cpus-per-task=2
#SBATCH -A huber

#----------------------------------------------------------------

module load BCFtools/1.21-GCC-13.3.0


# # If need subsets, create files and dont forget to zip and index :)

# vcftools --gzvcf tengrela_vicky/tengrela.vcf.gz --chr AgamP4_X --recode --out tengrela_vicky/tengrela_X.vcf
# bgzip tengrela_vicky/tengrela_X.vcf
# bcftools index tengrela_vicky/tengrela_X.vcf.gz


#create ids
/home/baehr/plink2 --vcf merged/X_all_and_tengrela.vcf.gz --double-id --allow-extra-chr --set-missing-var-ids @:# --export vcf --out intermed/X_all_and_tengrela_with_ids

#remove duplicates
/home/baehr/plink2 --vcf intermed/X_all_and_tengrela_with_ids.vcf --rm-dup force-first --allow-extra-chr --export vcf --out intermed/X_all_and_tengrela_clean

#prune
/home/baehr/plink2 --vcf intermed/X_all_and_tengrela_clean.vcf --allow-extra-chr --indep-pairwise 50 10 0.1 --out pca/X_all_and_tengrela

# create pca
/home/baehr/plink2 --vcf intermed/X_all_and_tengrela_clean.vcf --allow-extra-chr --extract pca/X_all_and_tengrela.prune.in --make-bed --pca --out pca/X_all_and_tengrela_pcadata