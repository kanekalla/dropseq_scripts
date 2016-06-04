#!/bin/bash

# Wrapper script for 10X pipeline

# To Change 
run_ids=("P17_Retina1" "P17_Retina2")
bcs=("SI-3A-A2" "SI-3A-C2")
bcl_path=/ahg/regev_nextseq/Data/160422_NB501164_0150_AH3MVGBGXY
trans_path=/seq/regev_genome_portal/SOFTWARE/10X/refdata-cellranger-1.1.0/mm10
cellranger_path=/seq/regev_genome_portal/SOFTWARE/10X/cellranger-1.1.0/

# Automatically defined
n=`expr ${#run_ids[@]} - 1`
fastq_path=`basename $bcl_path | cut -f 4 -d'_'`
fastq_path=./${fastq_path/A/}/outs/fastq_path

# cell ranger run

for ((i==0; i<=$n; i++)
do
  run_id=${run_ids[$i]}
  barcode=${bcs[$i]}
  sed "s|path_to_bcl|${bcl_path}|g;s|my_id|${run_id}|g;s|path_to_fastq|${fastq_path}|g" < /home/unix/karthik/repo/dropseq_scripts/10X/run_10X.sh > run_10X_${run_id}.sh
  sed -i "s|path_to_cellranger|${cellranger_path}|g" run_10X_${run_id}.sh
  sed -i "s|barcode|${barcode}|g;s|path_to_trans|${trans_path}|g" run_10X_${run_id}.sh
  sed -i "s|error.err|${run_id}.10X.err|g;s|out.log|${run_id}.10X.out|g" run_10X_${run_id}.sh
done

#use uger
#qsub run_10X_${run_id}.sh >> dispatch.txt 2>&1
