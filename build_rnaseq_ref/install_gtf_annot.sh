#!/bin/bash

# Author : Karthik Shekhar, 06/14/2016
# Installing transcriptomic index/reference for RNA-seq data
# usage : ./install_gtf_annot.sh

# required arguments
genome_fasta=/path/to/genome.fasta
gtf=/path/to/gtf
annot_name=name
rRNA_fasta=/path/to/rRNA.fasta
no_replace=F # do not replace already installed files (T/F)

# optional arguments (comment out if not providing)
#iso_map=/path/to/genetoisoform_map
igv_genome=/path/to/igv.genome
#just=tophat|rsem
# 

# check arguments
# TO DO

# directories
genome_fasta=`readlink -f ${genome_fasta}`
rRNA_fasta=`readlink -f ${rRNA_fasta}`
genome_dir=`dirname ${genome_fasta}`
annot_install_dir=${genome_dir}/Annotations/${annot_name}
config_dir=${genome_dir}/Config
config_file=${config_dir}/${annot_name}.config

mkdir -p ${annot_install_dir}
mkdir -p ${config_dir}

dest_annot_file=${annot_install_dir}/`basename ${gtf}`
if [ $no_replace == "F" ]
then
    cp ${gtf} ${dest_annot_file}
fi

if [ $no_replace == "T" ] && [ -s $config_file ]
then
else
    echo "GENOME_FA=${genome_fasta}" > ${config_file}
    echo "ANNOT_NAME=${annot_name}" >> ${config_file}
    echo "ANNOT_GTF=${dest_annot_file}" >> ${config_file}
    echo "RRNA_FA=${rRNA_fasta}" >> ${config_file}
    
    if [ -s ${igv_genome} ]
    then
        igv_genome=`readlink -f ${igv_genome}`
        echo "IGV_GENOME=${igv_genome}" >> ${config_file} 
    fi
    
    echo "TOPHAT_TRANS=${annot_install_dir}/tophat_trans_index" >> ${config_file}
    echo "RSEM_TRANS=${annot_install_dir}/rsem_trans_index" >> ${config_file}
fi

####################
## Prep for Tophat
####################

mkdir -p ./tmp
cp ~/repo/dropseq_scripts/build_rnaseq_ref/*fq ./tmp/

if [ -n "$just" ] && [ $just == "rsem"]
then
    echo "Not running tophat"
else
    tophat2 -G ${dest_annot_file} -T --transcriptome-index ${annot_install_dir}/tophat_trans_index -o ./tmp/$$.tophat.out ${genome_fasta} ./tmp/tmp.left.fq ./tmp/tmp.right.fq

####################
## Prep for RSEM
####################



    



