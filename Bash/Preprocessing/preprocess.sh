#!/bin/bash

#SBATCH --job-name=preprocess                        
#SBATCH --output=logs/log.preprocess.%j_%a.out          
#SBATCH --array=1,2,3,4,5,6,7,8,9
#SBATCH --ntasks=1                                      
#SBATCH --cpus-per-task=4                               
#SBATCH --mem=24G                                       
#SBATCH --time=24:00:00                                 
#SBATCH -p "htc-el8"                                    
#SBATCH -A huber

#Load modules
module load SAMtools/1.16.1-GCC-11.3.0
module load GATK/4.2.3.0-GCCcore-11.2.0-Java-11
module load picard/3.1.0-Java-17

sample_id=$(printf $SLURM_ARRAY_TASK_ID)

input_dir="/g/huber/users/baehr/rnaseq/map"
output_dir="/g/huber/users/baehr/rnaseq/bam"

base_name="T000${sample_id}"
alignfile="$input_dir/${base_name}_hisat_sort.bam"

dup_file="$output_dir/${base_name}_dup.bam"
metrics_file="$output_dir/${base_name}_hisat_dup_reorder_rg.metrics"
reordered_file="$output_dir/${base_name}_hisat_dup_reorder.bam"
output="$output_dir/${base_name}_hisat_dup_reorder_rg.bam"

echo "$base_name used as basename"

#Mark the duplicates and write into intermediate dup file
java -Xmx20G -XX:ParallelGCThreads=12 -XX:ConcGCThreads=1 -jar $EBROOTPICARD/picard.jar MarkDuplicates \
    -I ${alignfile} -O ${dup_file} -M ${metrics_file}

echo "$dup_file with marked duplicates"

#Reorder the created file
java -Xmx20G -XX:ParallelGCThreads=12 -XX:ConcGCThreads=1 -jar $EBROOTPICARD/picard.jar ReorderSam \
    -I ${dup_file} -O ${reordered_file} -SD /g/huber/users/baehr/stuff/VectorBase-68_AgambiaePEST_Genome.fasta


echo "$reordered_file based on dup now reordered, dup will be removed"
#Remove the intermediate dup file
rm ${dup_file}

java -jar $EBROOTPICARD/picard.jar AddOrReplaceReadGroups \
    I=${reordered_file} \
    O=${output} \
    RGID=FLOWCELL_${base_name} \
    RGLB=LIB_${base_name} \
    RGPL=illumina \
    RGPU=unit1 \
    RGSM=${base_name}

echo "$output created now with read group "


#Index the file 
samtools index ${output}

echo "$output has been indexed "

#remove intermediate reordered file
rm ${reordered_file}

