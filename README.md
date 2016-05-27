

### Demultiplexing

qsub -v nextseq_loc=/ahg/regev_nextseq/Data/<FOLDER>,fastq_loc=<PATH> demultiplex.sh

### Aligning and quantifying

1. Check that you have the following in your path,
   * R-3.2, Java-1.8, Samtools, Picard-Tools
2. Check that your local R repository has the package "ineq"
3. Create a working folder. Copy all the attached files in the following directory in a subfolder called "scripts",
4. Ensure sure all the fastq files are in a folder called "Data" (case sensitive) next to scripts
5.The format for the fastq files must be <SampleName>_R1.fastq.gz and <SampleName>_R2.fastq.gz. 
6. Open `run_dsq_pipeline_XXX.sh` (XXX = LSF or uger)
    *Change the `numCells=(6000 1500 3000)` line to indicate the estimated number of cells in each of your samples. This is an example of 3 samples with 6000, 1500 and 3000 cells respectively. The order in which the samples will be processed will be the alphabetical order in which they exist within the folder Data.
7. while in the scripts folder, type
    *`$chmod +x *.sh`
8. Now you are all set. You can kick off the pipeline by the following command,
    `$ ./run_dsq_pipeline_XXX.sh` 

Note that `run_dsq_pipeline_XXX.sh` uses the LSF job runner and invokes a "bsub" command to submit the job to the cluster. This will need to be modified accordingly. 

