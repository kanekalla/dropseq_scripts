#! /bin/bash
#$ -cwd
#$ -q long
#$ -P regevlab
#$ -l m_mem_free=16g
#$ -e error.err
#$ -o out.log

source /broad/software/scripts/useuse
reuse -q .bcl2fastq2-2.17.1.14
cellranger_path=path_to_cellranger
bclPath=path_to_bcl

# outputs to current directory
${cellranger_path}/cellranger demux --run=${bclPath}
