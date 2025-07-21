#!/bin/bash
#-----------------------------------------------------------------
# Using selscan for haplotype homozygosity measures
#-----------------------------------------------------------------

#SBATCH -J selscan        
#SBATCH -o logs/log.selscan.%j.out 
#SBATCH -n 1 
#SBATCH -p "htc-el8"
#SBATCH --mem=40GB
#SBATCH -t 12:00:00
#SBATCH --cpus-per-task=2
#SBATCH -A huber

#-----------------------------------------------------------------

module load plink/1.9-foss-2021b
module load VCFtools/0.1.16-GCC-11.2.0

CHRS=(AgamP4_2L AgamP4_2R AgamP4_3L AgamP4_3R AgamP4_X)
VCF_IN="ehtbf/ehtbf_coluzzii_phased_biallelic.vcf.gz"  # <-- Update filename as needed
OUTDIR="selscan/ihs_ihh12/test"
MAPDIR="${OUTDIR}/input"
SELSCAN="/home/baehr/selscan/bin/linux/selscan-2.0.3"

mkdir -p "$OUTDIR" "$MAPDIR"

for CHR in "${CHRS[@]}"; do
    SHORTCHR=${CHR/AgamP4_/}

    # Extract chromosome
    vcftools --gzvcf "$VCF_IN" --chr "$CHR" --recode --out "${OUTDIR}/samples_${SHORTCHR}"

    # Generate map file
    plink --allow-extra-chr --threads 10 --double-id --recode \
          --vcf "${OUTDIR}/samples_${SHORTCHR}.recode.vcf" \
          --out "${MAPDIR}/map_file_${SHORTCHR}"

    VCF="${OUTDIR}/samples_${SHORTCHR}.recode.vcf"
    MAP="${MAPDIR}/map_file_${SHORTCHR}.map"
    OUTBASE="${OUTDIR}/samples_${SHORTCHR}"

    # Run ihh12
    "$SELSCAN" --ihh12 --pmap --threads 20 --vcf "$VCF" --map "$MAP" --out "$OUTBASE"

    # Run ihs
    "$SELSCAN" --ihs --pmap --threads 20 --vcf "$VCF" --map "$MAP" --out "$OUTBASE"
done
