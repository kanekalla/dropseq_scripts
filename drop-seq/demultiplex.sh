#! /bin/bash

#$ -cwd
#$ -q long
#$ -P regevlab
#$ -N test_rnaseq
#$ -l m_mem_free=20g
#$ -e /broad/hptmp/karthik/error_demult.err
#$ -o /broad/hptmp/karthik/out_demult.log

set -x

source /broad/software/scripts/useuse
datadir=${nextseq_loc}
outdir=${fastq_loc}
mkdir -p ${outdir}

echo ${datadir}

use .bcl2fastq2-2.17.1.14
nohup bcl2fastq --runfolder-dir ${datadir} --output-dir ${outdir} --mask-short-adapter-reads 10 --minimum-trimmed-read-length 10 --no-lane-splitting


