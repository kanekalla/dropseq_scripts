#!/bin/bash

rsemPath=/seq/regev_genome_portal/SOFTWARE/BIN
gene_iso_map_file=Zv10.gene_to_iso
dest_annot_file=./Annotations/Zv10/Zv10.minus_nc.corrected.gtf
annot_install_dir=`readlink -f ./Annotations/Zv10`
genome_fasta=Zv10.fa
${rsemPath}/rsem-prepare-reference --gtf ${dest_annot_file} --transcript-to-gene-map ${gene_iso_map_file} ${genome_fasta} ${annot_install_dir}/rsem_trans_index
