#!/bin/bash
#-----------------------------------------------------------------
# Hard Filter The Variants 
#-----------------------------------------------------------------

#SBATCH -J VariantFiltration          
#SBATCH -o logs/log.variantfiltration.at.%j.out 
#SBATCH -n 1 
#SBATCH -p "htc-el8"
#SBATCH --mem=24GB
#SBATCH -t 24:00:00
#SBATCH --cpus-per-task=2
#SBATCH -A huber

#----------------------------------------------------------------
# Load modules
module load SAMtools/1.16.1-GCC-11.3.0
module load GATK/4.2.3.0-GCCcore-11.2.0-Java-11
module load picard/3.1.0-Java-17

#----------------------------------------------------------------
# Define Variables (edit here as needed)

REF="/g/huber/users/baehr/stuff/VectorBase-68_AgambiaePEST_Genome.fasta"
INTERVALS="/g/huber/users/baehr/stuff/intervals.list"
VCF_INPUT="/g/huber/users/baehr/rnaseq/ehtbf_rna_combined.vcf.gz"
TMPDIR="/g/huber/users/baehr/tmpdir"

OUTDIR="/g/huber/users/baehr/rnaseq"
SNPS_VCF="$OUTDIR/ehtbf_rna_combined_snps.vcf.gz"
INDELS_VCF="$OUTDIR/ehtbf_rna_combined_indels.vcf.gz"
SNPS_FILTERED_VCF="$OUTDIR/ehtbf_rna_combined_filtered_snps.vcf.gz"
INDELS_FILTERED_VCF="$OUTDIR/ehtbf_rna_combined_filtered_indels.vcf.gz"
FINAL_VCF="$OUTDIR/ehtbf_rna_combined_filtered_variants.vcf.gz"

JAVA_OPTS="-Xms20G -Xmx20G -XX:+UseParallelGC -XX:ParallelGCThreads=2 -Djava.io.tmpdir=$TMPDIR"

#----------------------------------------------------------------
# Extract the SNPs
gatk --java-options "$JAVA_OPTS" SelectVariants \
    -R $REF \
    -L $INTERVALS \
    -V $VCF_INPUT \
    -select-type SNP \
    -O $SNPS_VCF

# Extract the Indels
gatk --java-options "$JAVA_OPTS" SelectVariants \
    -R $REF \
    -L $INTERVALS \
    -V $VCF_INPUT \
    -select-type INDEL \
    -O $INDELS_VCF

# Hard filter the SNPs
gatk --java-options "$JAVA_OPTS" VariantFiltration \
    -R $REF \
    -L $INTERVALS \
    -V $SNPS_VCF \
    -filter "QD < 2.0" --filter-name "QD2" \
    -filter "QUAL < 30.0" --filter-name "QUAL30" \
    -filter "SOR > 3.0" --filter-name "SOR3" \
    -filter "FS > 60.0" --filter-name "FS60" \
    -filter "MQ < 40.0" --filter-name "MQ40" \
    -filter "MQRankSum < -12.5" --filter-name "MQRankSum-12.5" \
    -filter "ReadPosRankSum < -8.0" --filter-name "ReadPosRankSum-8" \
    -O $SNPS_FILTERED_VCF

# Hard filter the Indels
gatk --java-options "$JAVA_OPTS" VariantFiltration \
    -R $REF \
    -L $INTERVALS \
    -V $INDELS_VCF \
    -filter "QD < 2.0" --filter-name "QD2" \
    -filter "QUAL < 30.0" --filter-name "QUAL30" \
    -filter "FS > 200.0" --filter-name "FS200" \
    -filter "ReadPosRankSum < -20.0" --filter-name "ReadPosRankSum-20" \
    -O $INDELS_FILTERED_VCF

# Combine SNPs and Indels for final VCF
java -Xmx20G -XX:ParallelGCThreads=12 -XX:ConcGCThreads=1 -jar $EBROOTPICARD/picard.jar MergeVcfs \
    I=$SNPS_FILTERED_VCF \
    I=$INDELS_FILTERED_VCF \
    O=$FINAL_VCF
