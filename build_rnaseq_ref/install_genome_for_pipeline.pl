#!/usr/bin/env perl

use strict;
use warnings;

## Generate bowtie indices
## Generate gmap indices
## Prep genome for use with RNASEQ-QC:

# (Prep:  Be sure to have a genome.dict file:                                                                                                                                                  
# java -jar /seq/software/picard/current/bin/CreateSequenceDictionary.jar R=SP2.genome_wMito.fa O=SP2.genome_wMito.fa.dict                                                                     
#  and samtools faidx SP2.genome_wMito.fa 



my $usage = "usage: $0 genome.fa [rRNA_fasta]\n\n";

my $genome = $ARGV[0] or die $usage;
my $rRNA_fasta = $ARGV[1];

if ($genome =~ /^\.\./ || $genome =~ /^\//) {
    die "Error, run in the directory containing the genome.fa file";
}

main: {

    ## faidx
    my $cmd = "samtools faidx $genome";
    &process_cmd($cmd);
    
    ## generate bowtie2 indices:
    $cmd = "bowtie2-build $genome $genome";
    &process_cmd($cmd);
    
    $cmd = "ln -s $genome $genome.fa"; # bowtie wants to find a fasta fiel with the index name and .fa extension
    &process_cmd($cmd);

    ## generate gmap indices
    $cmd = "gmap_build -D . -d $genome.gmap -k 13 $genome";
    &process_cmd($cmd);

    ## generate the .dict file:
    $cmd = "java -jar /seq/software/picard/1.802/bin/CreateSequenceDictionary.jar R=$genome O=$genome.dict";
    &process_cmd($cmd);

    if ($rRNA_fasta) {
        $cmd = "bwa index $rRNA_fasta";
        &process_cmd($cmd);
    }

    print STDERR "\n\n\nDone.\n\n\n";

    exit(0);
}

####
sub process_cmd {
    my ($cmd) = @_;

    print STDERR "CMD: $cmd\n";
    my $ret = system($cmd);
    
    if ($ret) {
        die "Error, cmd: $cmd died with ret $ret";
    }

    return;
}

