#!/bin/bash

#SBATCH --job-name=haplotype_caller          
#SBATCH --output=logs/log.vcrna.%j_%a.out       
#SBATCH --array=1,2,3,4,5,6,7,8,9,10,11                      
#SBATCH --ntasks=1                           
#SBATCH --cpus-per-task=4                    
#SBATCH --mem=24G                            
#SBATCH --time=48:00:00                      
#SBATCH -p "htc-el8"                        
#SBATCH -A huber

#Load modules
module load SAMtools/1.16.1-GCC-11.3.0
module load GATK/4.2.3.0-GCCcore-11.2.0-Java-11
module load picard/3.1.0-Java-17

# Define directories (adjust paths as needed)
input_dir="/g/huber/users/baehr/rnaseq/bam_recal"
output_dir="/g/huber/users/baehr/rnaseq/variants"

# Format the array ID  to match sample naming
sample_id=$(printf $SLURM_ARRAY_TASK_ID)
base_name="T00${sample_id}"

# Construct the file name pattern
file="$input_dir/${base_name}_recal.bam"

output="$output_dir/${base_name}_variants.g.vcf"

# Run HaplotypeCaller for the current sample
echo "Running HaplotypeCaller for sample $base_name"
gatk HaplotypeCaller --java-options "-Xmx20G -XX:+UseParallelGC -XX:ParallelGCThreads=1 -Djava.io.tmpdir=/g/huber/users/baehr/tmpdir" \
  -R /g/huber/users/baehr/stuff/VectorBase-68_AgambiaePEST_Genome.fasta \
  -I "$file" \
  -O "$output" \
  --QUIET \
  -ERC GVCF \
  -ploidy 2 \
  -L /g/huber/users/baehr/stuff/intervals.list \
  --interval-padding 100

echo "Output generated: $output"