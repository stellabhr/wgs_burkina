#!/bin/bash
#-----------------------------------------------------------------
# Genotype the combined vcf
#-----------------------------------------------------------------

#SBATCH -J Genotypevcf          
#SBATCH -o logs/log.genotypevcf.ag1000g.%j.out 
#SBATCH -n 1 
#SBATCH -p "htc-el8"
#SBATCH --mem=24GB
#SBATCH -t 24:00:00
#SBATCH --cpus-per-task=2
#SBATCH -A huber

#----------------------------------------------------------------

#Load modules
module load SAMtools/1.16.1-GCC-11.3.0
module load GATK/4.2.3.0-GCCcore-11.2.0-Java-11
module load picard/3.1.0-Java-17

gatk --java-options "-Xms20G -Xmx20G -XX:+UseParallelGC -XX:ParallelGCThreads=2 -Djava.io.tmpdir=/g/huber/users/baehr/tmpdir" GenotypeGVCFs \
    -R /g/huber/users/baehr/stuff/VectorBase-68_AgambiaePEST_Genome.fasta \
    -L /g/huber/users/baehr/stuff/intervals.list \
    -V gendb://ag1000g_database \
    -O ag1000g/diy/ag1000g_combined.vcf.gz
