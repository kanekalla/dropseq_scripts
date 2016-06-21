#! /bin/bash

#$ -cwd
#$ -q long
#$ -P <project space>
#$ -l m_mem_free=1g
#$ -N <Name of your run>
#$ -e </path/to/error_file>
#$ -o </path/to/out_file>

source /broad/software/scripts/useuse
cd </path/to/output_dir>
/seq/regev_genome_portal/SOFTWARE/KCO/RNASEQ_pipeline/run_RNASEQ_pipeline_many_samples_UGER_array.sh \
--annot_conf <annot_config> \
--run_conf <path_to_run_config>\
--reads_list_file </path/to/read_list_file> \
--project_base_dir </path/to/output_dir>  \
--queue long --memory 20 \
--num_threads_each 1
--project_name <project space>
