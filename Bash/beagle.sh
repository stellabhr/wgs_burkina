#!/bin/bash
#-----------------------------------------------------------------
# Using beagle to phase the genome
#-----------------------------------------------------------------

#SBATCH -J beagle        
#SBATCH -o logs/log.beagle.%j.out 
#SBATCH -n 1 
#SBATCH -p "htc-el8"
#SBATCH --mem=80GB
#SBATCH -t 72:00:00
#SBATCH --cpus-per-task=2
#SBATCH -A huber

#----------------------------------------------------------------

module load picard/3.1.0-Java-17


java -Xmx50G -XX:+UseParallelGC -XX:ParallelGCThreads=2 -jar \
    /home/baehr/beagle.17Dec24.224.jar \
    gt=tengrela_vicky/tengrela.vcf.gz \
    map=stuff/AgamP4_map.map \
    nthreads=10 \
    impute=true \
    out=tengrela_phased

