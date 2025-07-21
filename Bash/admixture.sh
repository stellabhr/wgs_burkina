#!/bin/bash

#SBATCH --job-name=admixture        
#SBATCH --output=logs/log.admixture.%j.out      
#SBATCH --array=3-8              
#SBATCH --ntasks=1                           
#SBATCH --mem=100G
#SBATCH --cpus-per-task=6                           
#SBATCH --time=100:00:00                   
#SBATCH -p "htc-el8"                     
#SBATCH -A huber

# Set the value of K based on SLURM_ARRAY_TASK_ID
K=$(printf "%02d" $SLURM_ARRAY_TASK_ID)

# Define the input file (.bed)
INPUT_PREFIX="admixture/everything_tengrela/everything_tengrela_admixture_final.bed"

# Run the admixture command
/home/baehr/dist/admixture_linux-1.3.0/admixture --cv ${INPUT} $K > admixture/everything_tengrela/ktests/k${K}.out
