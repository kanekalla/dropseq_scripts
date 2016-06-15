#!/bin/bash

tophatPath=/seq/regev_genome_portal/SOFTWARE/tophat2/current
dest_annot_file=./Annotations/Zv10/Zv10.minus_nc.corrected.gtf
annot_install_dir=`readlink -f ./Annotations/Zv10`
genome_fasta=Zv10.fa
${tophatPath}/tophat2 -G ${dest_annot_file} -T --transcriptome-index ${annot_install_dir}/tophat_trans_index -o ./tmp/$$.tophat.out ${genome_fasta} ./tmp/tmp.left.fq ./tmp/tmp.right.fq
