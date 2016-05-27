#!/bin/bash

#set -x
#set -o errexit

#Author : Karthik Shekhar, 05/26/2016
#Master file for invoking Drop-seq pipline

#Depends on sample
refFastaPath=/broad/mccarroll/software/metadata/individual_reference/GRCh37.75_GRCm38.81/m38_transgene/m38_transgene.fasta
numCells=(1500 3000 3000) 
queue=regevlab
baseDir=`readlink -f ..`

#rm -rf ../Analysis ../bsub_logs ../bam* ../*DGE ../temp* ../QC* ./run_files ../synthesis_err_stats
#mkdir -p ../bsub_logs
#mkdir -p ../Analysis
#mkdir -p ../QC_files
#mkdir -p ../QC_reports
#mkdir -p ../tempQC
#mkdir -p ../bam_reads
#mkdir -p ../synthesis_err_stats
#mkdir -p run_files

#mkdir -p ../bams_HUMAN_MOUSE
#mkdir -p ../UMI_DGE
#mkdir -p ../reads_DGE

l=0
for fq1 in ../Fastqs/Data/*R1*;
do

#STEP 1 : CREATE NEW INSTANTIATION OF RUN FILE FOR SAMPLE
fq2=${fq1/R1/R2}

#Get absolute paths
fq1=`readlink -f ${fq1}`
fq2=`readlink -f ${fq2}`

bfq1=`basename ${fq1}`
bfq2=`basename ${fq2}`

b0=`echo ${bfq1} | grep -P '^[a-zA-Z0-9\_]*_R1' -o`
b=${b0/_R1/}
sed "s|fName|${b}|g;s|fastq1|${fq1}|g;s|fastq2|${fq2}|g;s|bamFileName|${b}|g;s|numCellsNum|${numCells[l]}|g;s|refFasta|${refFastaPath}|g;s|basedir|${baseDir}|g" < run_Alignment.sh > run_Alignment_${b}.sh
chmod +x run_Alignment_${b}.sh
mv run_Alignment_${b}.sh run_files

bsub -oo ../bsub_logs/${b}.pipe.log -eo ../bsub_logs/${b}.pipe.err -q ${queue} -R "rusage[mem=150]span[hosts=1]" \
./run_files/run_Alignment_${b}.sh

#qsub ./run_files/run_Alignment_${b}.sh

echo ${numCells[l]}
l=`expr $l + 1`
done








