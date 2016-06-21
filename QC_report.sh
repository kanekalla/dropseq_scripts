#!/bin/bash

wd=`readlink -f .`
config=/seq/regev_genome_portal/RESOURCES/Zebrafish/Zv10/Config/Zv10.config
annot_name=Zv10
expmat_name=HabSCZv10

/seq/regev_genome_portal/SOFTWARE/RNASEQ_genome_pipeline/aggregate_links_to_sample_outputs.pl $wd

/seq/regev_genome_portal/SOFTWARE/RNASEQ_genome_pipeline/generate_sample_summary_stats.pl --annot_conf $config --reads_list_file samples.txt --project_base_dir $wd > QC_short.txt

/seq/regev_genome_portal/SOFTWARE/RNASEQ_genome_pipeline/util/summarize_rnaseqQC_results.pl samples.txt $wd > QC_long.txt

find RSEM_${annot_name}/ -type f  | egrep 'genes.results' > rsem.genes.list

/seq/regev_genome_portal/SOFTWARE/RNASEQ_genome_pipeline/merge_RSEM_output_to_matrix.pl --rsem_files rsem.genes.list --mode counts > ${expmat_name}.RSEM.genes.counts.matrix
/seq/regev_genome_portal/SOFTWARE/RNASEQ_genome_pipeline/merge_RSEM_output_to_matrix.pl --rsem_files rsem.genes.list --mode tpm > ${expmat_name}.RSEM.genes.tpm.matrix
