#!/bin/bash
#-----------------------------------------------------------------
# Annotating SNPs
#-----------------------------------------------------------------

#SBATCH -J snpeff          
#SBATCH -o logs/log.snpeff.%j.out 
#SBATCH -n 1
#SBATCH -p "htc-el8"
#SBATCH --mem=20GB
#SBATCH -t 12:00:00
#SBATCH --cpus-per-task=12
#SBATCH -A huber

#----------------------------------------------------------------
module load VCFtools/0.1.16-GCC-11.2.0
module load Java/21.0.2

#need unzipped input for perl
gunzip -c ehtbf/ehtbf_coluzzii.vcf.gz > ehtbf/ehtbf_coluzzii.vcf

#need to recode the chromosomes into 1,2,3,... without disturbing vcf format (need to use perl)
perl -pe 's/^AgamP4_2R\t/2R\t/g;s/^AgamP4_2L\t/2L\t/g;s/^AgamP4_3L\t/3L\t/g;s/^AgamP4_3R\t/3R\t/g;s/^AgamP4_X\t/X\t/g' ehtbf/ehtbf_coluzzii.vcf >  snpeff/ehtbf_coluzzii_for_snpeff.vcf

#run SNPEff
java -Xmx20G -XX:ParallelGCThreads=12 -XX:ConcGCThreads=1 -jar /home/baehr/snpEff/snpEff.jar Anopheles_gambiae snpeff/ehtbf_coluzzii_for_snpeff.vcf > snpeff/ehtbf_coluzzii_snpeff.vcf

#filter by variant impact
java -Xmx20G -XX:ParallelGCThreads=12 -XX:ConcGCThreads=1 -jar /home/baehr/snpEff/SnpSift.jar filter "ANN[*].IMPACT has 'HIGH'" snpeff/ehtbf_coluzzii_snpeff.vcf >  snpeff/ehtbf_coluzzii_high_impact.vcf

java -Xmx20G -XX:ParallelGCThreads=12 -XX:ConcGCThreads=1 -jar /home/baehr/snpEff/SnpSift.jar filter "ANN[*].IMPACT has 'MODERATE'" snpeff/ehtbf_coluzzii_snpeff.vcf > snpeff/ehtbf_coluzzii_moderate_impact.vcf

java -Xmx20G -XX:ParallelGCThreads=12 -XX:ConcGCThreads=1 -jar /home/baehr/snpEff/SnpSift.jar filter "ANN[*].IMPACT has 'MODIFIER'" snpeff/ehtbf_coluzzii_snpeff.vcf > snpeff/ehtbf_coluzzii_modifier.vcf
