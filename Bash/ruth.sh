#!/bin/bash

#-----------------------------------------------------------------
# Using ruth to calculate HWE p value based on PCs
#-----------------------------------------------------------------

#SBATCH -J ruth          
#SBATCH -o logs/log.ruth.%j.out 
#SBATCH -n 1 
#SBATCH -p "htc-el8"
#SBATCH --mem=10GB
#SBATCH -t 15:00:00
#SBATCH --cpus-per-task=2
#SBATCH -A huber

#----------------------------------------------------------------
module load BCFtools/1.21-GCC-13.3.0


/home/baehr/ruth/bin/ruth --vcf ehtbf/ehtbf_unfiltered.vcf.gz --evec ehtbf_ruth_eigenvec.txt --field PL --out ehtbf_hwe_PL.vcf.gz

