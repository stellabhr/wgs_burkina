#!/bin/bash
#-----------------------------------------------------------------
# Mapping RNASeq samples to PEST genome
#-----------------------------------------------------------------

#SBATCH -J RNASeq-Align               
#SBATCH -o logs/log.Ag1000GMap.%j.out 	
#SBATCH --array=1,2,3,4,5,6,7,8,9
#SBATCH -n 1                   
#SBATCH -p "htc-el8"          
#SBATCH --mem=80GB            
#SBATCH -t 48:00:00            
#SBATCH -c 30                   
#SBATCH -A huber
#----------------------------------------------------------------

# Load all necessary modules
module purge
module load SAMtools/1.16.1-GCC-11.3.0
module load Subread/2.0.3-GCC-11.2.0
module load Boost.Python/1.81.0-GCC-12.2.0 # needed by hisat2

# Environment:
# adjust folders and files
input_dir="/g/huber/users/baehr/rnaseq/fastq"
map_dir="/g/huber/users/baehr/rnaseq/map"
GENOME="/g/huber/users/hartke/RESOURCES/References/AgamP3/VectorBase-68_AgambiaePEST_Genome.fasta"
SPLICE="/g/huber/users/hartke/RESOURCES/References/AgamP3/VectorBase-68_AgambiaePEST.ss" # for hisat index
EXON="/g/huber/users/hartke/RESOURCES/References/AgamP3/VectorBase-68_AgambiaePEST.exon" # for hisat index
ANNOTATION="/g/huber/users/hartke/RESOURCES/References/AgamP3/VectorBase-68_AgambiaePEST.gff"
sample_id=$(printf $SLURM_ARRAY_TASK_ID)
name="T000${sample_id}"
reads1="/g/huber/users/baehr/rnaseq/fastq/${name}_good_1.fq.gz"
reads2="/g/huber/users/baehr/rnaseq/fastq/${name}_good_2.fq.gz"

echo "$sample_id used as sample_id"
echo "$name used as name"
echo "$reads1 used as reads 1"
echo "$reads2 used as reads 2"

srun /home/baehr/hisat2-2.2.1/hisat2 -p $SLURM_CPUS_ON_NODE \
        --dta -x $GENOME -1 $reads1 -2 $reads2 \
        --summary-file $map_dir/"$name".hisat.stats.txt|\
        samtools view -b - |\
        samtools sort - \
        > $map_dir/"$name"_hisat_sort.bam


# run Hisat2, if necessary, run below command on genome file to create all needed files
# hisat2-build -p 20 --ss $SPLICE --exon $EXON $GENOME $GENOME



