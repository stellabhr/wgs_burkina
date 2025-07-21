#!/bin/bash
#-----------------------------------------------------------------
# Linkage Disequilibrium Calculation with Plink
#-----------------------------------------------------------------

#SBATCH -J ld        
#SBATCH -o logs/log.ld.%j.out 
#SBATCH -n 1 
#SBATCH -p "htc-el8"
#SBATCH --mem=20GB
#SBATCH -t 5:00:00
#SBATCH --cpus-per-task=2
#SBATCH -A huber

#----------------------------------------------------------------

module load plink/1.9-foss-2021b
module load Python/3.13.1-GCCcore-14.2.0
module load BEDTools/2.30.0-GCC-12.2.0

# Get 2La identifying SNPs (in R), format AgamP4_2L:pos

# # Get the sample IDs in the format needed
# grep prior gwas/pnd_tiefora/maf5/gwas_pnd_tiefora_maf5.fam | awk '{print $1, $2}' > ld/2La_pnd_tiefora_dead/tie_dead_samples.txt
# grep after gwas/pnd_tiefora/maf5/gwas_pnd_tiefora_maf5.fam | awk '{print $1, $2}' > ld/2La_pnd_tiefora_alive/tie_alive_samples.txt
# grep prior gwas/pnd_tengrela/maf5/gwas_pnd_tengrela_maf5.fam | awk '{print $1, $2}' > ld/2La_pnd_tengrela_dead/ten_dead_samples.txt
# grep Tie gwas/all_mortality/gwas_mortality_data.fam | awk '{print $1, $2}' > ld/2La_tiefora/tie_samples.txt

# #get the input files 
# #tiefora
# plink --bfile gwas/pnd_tiefora/maf5/gwas_pnd_tiefora_maf5 \
#     --keep ld/2La_pnd_tiefora_alive/tie_alive_samples.txt  \
#     --allow-extra-chr  \
#     --make-bed \
#     --out ld/2La_pnd_tiefora_alive/2La_tiefora_alive

# plink --bfile gwas/pnd_tiefora/maf5/gwas_pnd_tiefora_maf5 \
#     --keep ld/2La_pnd_tiefora_dead/tie_dead_samples.txt \
#     --allow-extra-chr  \
#     --make-bed \
#     --out ld/2La_pnd_tiefora_dead/2La_tiefora_dead

# #tengrela
# plink --bfile gwas/pnd_tengrela/maf5/gwas_pnd_tengrela_maf5 \
#     --keep ld/2La_pnd_tengrela_alive/ten_alive_samples.txt \
#     --allow-extra-chr \
#     --make-bed \
#     --out ld/2La_pnd_tengrela_alive/2La_tengrela_alive

# plink --bfile gwas/all_mortality/gwas_mortality_data \
#     --keep ld/2La_tiefora/tie_samples.txt  \
#     --allow-extra-chr  \
#     --make-bed \
#     --out ld/2La_tiefora/2La_tiefora



#LD calculation
plink --bfile ld/2La_tiefora/2La_tiefora \
    --r2 inter-chr \
    --ld-snp-list ld/2La_snps.txt \
    --ld-window-r2 0.7 \
    --out ld/2La_tiefora/2La_tiefora \
    --allow-extra-chr

#filter for only linked SNPS not in 2La, write into .bed file, intersect and annotate
awk '!(($4 == "AgamP4_2L") && ($5 >= 20000000 && $5 <= 42500000))' \
    ld/2La_tiefora/2La_tiefora.ld \
    > ld/2La_tiefora/2La_tiefora_filtered.ld

#turn LD output into bed format
python createbed.py ld/2La_tiefora/2La_tiefora_filtered.ld \
    ld/2La_tiefora/2La_tiefora_peaks.bed

#intersect to get genes
bedtools intersect -a stuff/AgamP4_genes.bed \
    -b ld/2La_tiefora/2La_tiefora_peaks.bed \
    -wb > ld/2La_tiefora/2La_tiefora_peaks_anno.tsv
