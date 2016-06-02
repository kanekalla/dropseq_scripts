#!/bin/bash

#$ -cwd
#$ -q long
#$ -P regevlab

#$ -e error.err
#$ -o out.log


source /broad/software/scripts/useuse
reuse UGER
export PATH=/seq/regev_genome_portal/SOFTWARE/10X/cellranger-1.1.0:$PATH

id=my_id
# ./<FLOWCELLID>/outs/fastq_path
fastq_path=path_to_fastq 

#comma seperated sample barcodes
bcs=comma_sep_barcodes
transcriptome_path=path_to_trans

cellranger run --id=${id} \
	       --transcriptome=${transcriptome_path} \
	       --fastqs=${fastq_path} \
	       --jobmode=sge \
	       --indices=${bcs} \
	       --maxjobs=8 \
	       --mempercore=16 \
	       #--uiport=3600
				       	
			
	
