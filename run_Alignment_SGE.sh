#!/bin/bash

#$ -cwd
#$ -q long
#$ -P regevlab
#$ -l m_mem_free=150g
#$ -N karthik_dropseq
#$ -pe smp 4 -R y
#$ -V


source /broad/software/scripts/useuse 
use Java-1.7
use Python-2.7
use R-3.0
use Samtools

# Author: Karthik Shekhar, 05/26/16
# Template file for executing Drop-seq alignment/quantification steps

set -x

b=fName
bamName=bamFileName
fq1=fastq1
fq2=fastq2
numCells=numCellsNum
reference_fasta=refFasta
metaDataDir=metaDataLoc
toolsPath=/broad/mccarroll/software/dropseq/prod
baseDir=basedir

# STEP 1 : Alignment
${baseDir}/scripts/run_dsq_alignment.sh ${metaDataDir} ${fq1} ${fq2} ${b}

mv ${baseDir}/bams/${bamName}.bam ${baseDir}/bams/${bamName}_old.bam
mv ${baseDir}/bams/${bamName}.bam.bai ${baseDir}/bams/${bamName}_old.bam.bai

# STEP 2 : Detect Bead Synthesis errors
${toolsPath}/DetectBeadSynthesisErrors \
I=${baseDir}/bams/${bamName}_old.bam \
O=${baseDir}/bams/${bamName}_unmerged.bam \
OUTPUT_STATS=${baseDir}/synthesis_err_stats/${bamName}.synthesis_stats.txt \
SUMMARY=${baseDir}/synthesis_err_stats/${bamName}.synthesis_stats.summary.txt \
NUM_BARCODES=$((numCells*2)) \
PRIMER_SEQUENCE=AAGCAGTGGTATCAACGCAGAGTAC \
MAX_NUM_ERRORS=2 \
CELL_BARCODE_TAG=XC

mv ${baseDir}/bams/${bamName}_unmerged.bam ${baseDir}/bams/${bamName}.bam
samtools index ${baseDir}/bams/${bamName}.bam

rm ${baseDir}/bams/${bamName}_old.bam
rm ${baseDir}/bams/${bamName}_old.bam.bai

# STEP 3: Collapse cell barcodes by edit distance
${toolsPath}/CollapseBarcodesInPlace \
I=${baseDir}/bams/${bamName}.bam \
O=${baseDir}/bams/${bamName}_collapsed.bam \
PRIMARY_BARCODE=XC \
OUT_BARCODE=ZC \
MIN_NUM_READS_CORE=5000 \
MIN_NUM_READS_NONCORE=1000 \
EDIT_DISTANCE=1

rm ${baseDir}/bams/${bamName}.bam
rm ${baseDir}/bams/${bamName}.bam.bai
mv ${baseDir}/bams/${bamName}_collapsed.bam ${baseDir}/bams/${bamName}.bam 
samtools index ${baseDir}/bams/${bamName}.bam

# Summary of collapse
${toolsPath}/BAMTagofTagCounts \
I=${baseDir}/bams/${bamName}.bam \
O=${baseDir}/bam_reads/${bamName}.collapse_stats.txt \
PRIMARY_TAG=ZC \
SECONDARY_TAG=XC

# STEP 4: Bam Tag Histogram
${toolsPath}/BAMTagHistogram \
I=${baseDir}/bams/${bamName}.bam \
O=${baseDir}/bam_reads/${bamName}.reads.txt.gz \
TAG=ZC

gunzip ${baseDir}/bam_reads/${bamName}.reads.txt.gz

# STEP 5: DropSeqCumuPlot.R to compute inflection in cumulative plots. Estimates number of cells in the data

Rfile=DropSeqCumuPlot_${bamName}.R
bamReadsFile=${baseDir}/bam_reads/${bamName}.reads.txt
#temp1=`echo ${bamReadsFile} | sed 's:\/:\\\/:g'`
#temp2=`echo ${baseDir} | sed 's:\/:\\\/:g'`\\\/bam_reads\\\/${bamName}
sed "s|fileName|${bamReadsFile}/g;s|figName|${baseDir}|g" < ${baseDir}/scripts/DropSeqCumuPlot.R > ${baseDir}/scripts/run_files/DropSeqCumuPlot_${bamName}.R
R CMD BATCH ${baseDir}/scripts/run_files/DropSeqCumuPlot_${bamName}.R ${baseDir}/bsub_logs/DropSeqCumuPlot.${bamName}.out

readsTable=${bamName}.reads.txt
numCells=`cat ${baseDir}/bam_reads/${bamName}_numCells.txt` 
sed "s|filename_input|${readsTable}|g;s|Ncells_input|${numCells}|g" < ${baseDir}/scripts/collect_cell_barcodes.R > ${baseDir}/scripts/run_files/collect_cell_barcodes.${bamName}.R
R CMD BATCH ${baseDir}/scripts/run_files/collect_cell_barcodes.${bamName}.R ${baseDir}/bsub_logs/collect_cell_barcodes.${bamName}.Rout

# STEP 6: DGE UMIs
${toolsPath}/DigitalExpression I=${baseDir}/bams/${bamName}.bam \
O=${baseDir}/UMI_DGE/${bamName}.umi.dge.txt.gz \
SUMMARY=${baseDir}/UMI_DGE/${bamName}.umi.dge.summary.txt \
CELL_BARCODE_TAG=ZC \
NUM_CORE_BARCODES=${numCells}

# STEP 7: DGE READS
${toolsPath}/DigitalExpression \
I=${baseDir}/bams/${bamName}.bam \
O=${baseDir}/reads_DGE/${bamName}.reads.dge.txt.gz \
SUMMARY=${baseDir}/reads_DGE/${bamName}.reads.dge.summary.txt \
CELL_BARCODE_TAG=ZC \
NUM_CORE_BARCODES=${numCells} \
OUTPUT_READS_INSTEAD=true

# STEP 8: QC
BASEDIR=/broad/mccarroll/software/dropseq/prod
source $BASEDIR/configDropSeqRNAEnvironment.bash

$BASEDIR/DropSeqStandardAnalysis \
--BAMFile ${baseDir}/bams/${bamName}.bam \
--reference $reference_fasta \
--numCells ${numCells} \
--estimatedNumCells ${numCells} \
--estimatedNumBeads $((numCells*20)) \
--report_dir ${baseDir}/QC_files \
--pointSize=0.75 \
--batchSystem sge \
--beadSynthesisErrorDetail ${baseDir}/synthesis_err_stats/${bamName}.synthesis_stats.txt \
--cellTag XC \
--cellTagCollapsed ZC \
--outPDF ${baseDir}/QC_reports/${bamName}_QC.pdf \
--tempDir ${baseDir}/tempQC \
--use_threads \
--verbose 1 

