#!/bin/bash

#$ -cwd
#$ -q long
#$ -P regevlab
#$ -e qsub_logs/error.err
#$ -o qsub_logs/out.log


source /broad/software/scripts/useuse

# Variables defined by wrapper script
cellranger_path=path_to_cellranger
id=my_id
# ./<FLOWCELLID>/outs/fastq_path
fastq_path=path_to_fastq 
#comma seperated sample barcodes
bcs=barcode
transcriptome_path=path_to_trans

${cellranger_path}/cellranger run --id=${id} \
	       			  --transcriptome=${transcriptome_path} \
	                          --fastqs=${fastq_path} \
	                          --jobmode=sge \
	       			  --indices=${bcs} \
	       			  --maxjobs=8 \
	       			  --mempercore=16 \
	       			 #--uiport=3600
				       	
			
	
