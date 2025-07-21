#!/bin/bash
#-----------------------------------------------------------------
# Using selscan for xpehh calculation
#-----------------------------------------------------------------

#SBATCH -J xpehh        
#SBATCH -o logs/log.xpehh.%j.out 
#SBATCH -n 1 
#SBATCH -p "htc-el8"
#SBATCH --mem=10GB
#SBATCH -t 48:00:00
#SBATCH --cpus-per-task=2
#SBATCH -A huber

#----------------------------------------------------------------

# Load modules

#module purge 

module load BCFtools/1.21-GCC-13.3.0
module load plink/1.9-foss-2021b

# Define chromosome names 
CHROMOSOMES=("2L" "2R" "3L" "3R" "X")

## In case some files need to be created 
# bcftools view -i 'F_MISSING=0' -m2 -M2 -v snps ag1000g/ag3_BF.vcf.gz -Oz -o ag1000g/ag3_BF_biallelic.vcf.gz
# bcftools index ag1000g/ag3_BF_coluzzii_biallelic.vcf.gz

# Loop through each chromosome
for CHR in "${CHROMOSOMES[@]}"; do
    echo "Processing chromosome $CHR..."
    module purge
    module load BCFtools/1.21-GCC-13.3.0

    #Create Files
    bcftools view -r "AgamP4_${CHR}" "ehtbf/ehtbf_coluzzii_phased_biallelic_nomissing.vcf.gz" \
        -Oz -o "selscan/xpehh/origin_ag1000g/ehtbf_coluzzii_${CHR}.vcf.gz"
    bcftools view -r "AgamP4_${CHR}" "ag1000g/ag3_BF_biallelic.vcf.gz" \
        -Oz -o "selscan/xpehh/origin_ag1000g/ag1000g_${CHR}.vcf.gz"


    # Index the compressed VCF files
    bcftools index "selscan/xpehh/origin_ag1000g/ehtbf_coluzzii_${CHR}.vcf.gz"
    bcftools index "selscan/xpehh/origin_ag1000g/ag1000g_${CHR}.vcf.gz"

    bcftools isec \
    -n=2 \
    -w1 \
    -Oz \
    -o "selscan/xpehh/origin_ag1000g/regions_ehtbfcoluzzii_ag1000g_${CHR}.vcf.gz" \
    "selscan/xpehh/origin_ag1000g/ehtbf_coluzzii_${CHR}.vcf.gz" \
    "selscan/xpehh/origin_ag1000g/ag1000g_${CHR}.vcf.gz"

    # Filter original VCFs to retain the same variants
    bcftools view -R "selscan/xpehh/origin_ag1000g/regions_ehtbfcoluzzii_ag1000g_${CHR}.vcf.gz" "selscan/xpehh/origin_ag1000g/ehtbf_coluzzii_${CHR}.vcf.gz" \
        -Oz -o "selscan/xpehh/origin_ag1000g/ehtbf_coluzzii_${CHR}_filtered.vcf.gz"
    #rm "selscan/xpehh/origin_ag1000g/ehtbf_coluzzii_${CHR}.vcf.gz"
    
    bcftools view -R "selscan/xpehh/origin_ag1000g/regions_ehtbfcoluzzii_ag1000g_${CHR}.vcf.gz" "selscan/xpehh/origin_ag1000g/ag1000g_${CHR}.vcf.gz" \
        -Oz -o "selscan/xpehh/origin_ag1000g/ag1000g_${CHR}_filtered.vcf.gz"
    #rm "selscan/xpehh/origin_ag1000g/ag1000g_${CHR}.vcf.gz"
    
    module load plink/1.9-foss-2021b
    
    # Generate new map file
    plink --allow-extra-chr --threads 10 --double-id --recode --geno 0\
        --vcf "selscan/xpehh/origin_ag1000g/ag1000g_${CHR}_filtered.vcf.gz" \
        --out "selscan/xpehh/origin_ag1000g/map_file_origin_ag1000g_${CHR}"

    # Run selscan
    /home/baehr/selscan/bin/linux/selscan-2.0.3 --xpehh \
        --pmap \
        --threads 20 \
        --vcf "selscan/xpehh/origin_ag1000g/ehtbf_coluzzii_${CHR}_filtered.vcf.gz" \
        --vcf-ref "selscan/xpehh/origin_ag1000g/ag1000g_${CHR}_filtered.vcf.gz" \
        --map "selscan/xpehh/origin_ag1000g/map_file_origin_ag1000g_${CHR}" \
        --out "selscan/xpehh/origin_ag1000g/output_ehtbfcoluzzii_ag1000g_${CHR}"

    echo "Chromosome $CHR done."
done

echo "All chromosomes processed!"
