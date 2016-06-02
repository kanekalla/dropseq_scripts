#! /bin/bash
#$ -cwd
#$ -q long
#$ -P regevlab
#$ -l m_mem_free=16g
#$ -e error.err
#$ -o out.log

source /broad/software/scripts/useuse
reuse -q .bcl2fastq2-2.17.1.14
export PATH=/seq/regev_genome_portal/SOFTWARE/10X/cellranger-1.1.0:$PATH

bclPath=path_to_bcl

# outputs to current directory
cellranger demux --run=${bclPath}
