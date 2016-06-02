#!/bin/bash

# Wrapper script for 10X pipeline

# To Change 
run_id=P17_Retina
bcl_path=/ahg/regev_nextseq/Data/160422_NB501164_0150_AH3MVGBGXY
trans_path=/ahg/regevdata/projects/10X_runs/REFERENCES/refdata-cellranger-1.0.0/mm10
bcs=<bc1>,<bc2>,<bc3>,...

# Automatically defined
fastq_path=`basename $bcl_path | cut -f 4 -d'_'`
fastq_path=./${fastq_path/A/}/outs/fastq_path

sed "s|path_to_bcl|${bcl_path}|g;s|my_id|${run_id}|g;s|path_to_fastq|${fastq_path}|g" < /home/unix/karthik/repo/dropseq_scripts/10X/run_10X.sh > run_10X_${run_id}.sh
sed -i "s|comma_sep_barcodes|${bcs}|g;s|path_to_trans|${trans_path}|g" run_10X_${run_id}.sh
sed -i "s|error.err|${run_id}.10X.err|g;s|out.log|${run_id}.10X.out|g" run_10X_${run_id}.sh

use uger
qsub run_10X_${run_id}.sh >> dispatch.txt 2>&1
