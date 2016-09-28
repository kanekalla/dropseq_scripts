#! /bin/bash
#$ -cwd
#$ -q long
#$ -P regevlab
#$ -l h_vmem=16g
#$ -e qsub_logs/demult.err
#$ -o qsub_logs/demult.log

source /broad/software/scripts/useuse
reuse -q .bcl2fastq2-2.17.1.14
reuse UGER
cellranger_path=path_to_cellranger
bclPath=path_to_bcl

# outputs to current directory
${cellranger_path}/cellranger demux --run=${bclPath}
