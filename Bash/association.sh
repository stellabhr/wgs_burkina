#!/bin/bash

#-----------------------------------------------------------------
# Basic Association using plink
#-----------------------------------------------------------------

#SBATCH -J assoc       
#SBATCH -o logs/log.assoc.%j.out 
#SBATCH -n 1 
#SBATCH -p "htc-el8"
#SBATCH --mem=10GB
#SBATCH -t 2:00:00
#SBATCH --cpus-per-task=2
#SBATCH -A huber

#----------------------------------------------------------------

#get SNPEff vcf into plink format

module load plink/1.9-foss-2021b

#create bed file
plink --vcf association/rdl/rdl.vcf \
    --maf 0.05 \
    --make-bed \
    --const-fid \
    --allow-extra-chr \
    --set-missing-var-ids @:# \
    --out association/rdl/rdl


#assign pheno file for association (in this case village)
plink --bfile association/rdl/rdl  \
    --pheno association/rdl/pheno_village.txt \
    --maf 0.05 \
    --make-bed \
    --allow-extra-chr \
    --allow-no-sex \
    --const-fid \
    --out association/rdl/rdl_pheno

#Run Log with covariates as before
plink --bfile association/rdl/rdl_pheno \
    --allow-extra-chr \
    --const-fid \
    --allow-no-sex \
    --covar gwas/all_mortality/covariates_mortality.txt \
    --logistic recessive hide-covar perm \
    --out association/rdl/rdl

#Run Fisher
plink --bfile association/rdl/rdl_pheno \
    --allow-extra-chr \
    --const-fid \
    --assoc fisher \
    --allow-no-sex \
    --out association/rdl/rdl

#Run Chi-squred
plink --bfile association/rdl/rdl_pheno \
    --allow-extra-chr \
    --const-fid \
    --assoc \
    --allow-no-sex \
    --out association/rdl/rdl


#If need, can get vcf back from plink
plink \
  --bfile association/rdl/rdl \
  --recode vcf \
  --const-fid \
  --allow-no-sex \
  --allow-extra-chr \
  --out rdl_maf005

