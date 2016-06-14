#!/usr/bin/env perl

use strict;
use warnings;

use Carp;
use Getopt::Long qw(:config no_ignore_case bundling pass_through);
use Cwd;

use File::Basename;

my $usage = <<__EOUSAGE__;

# Process installs the annotation set under basename(\${genome})/Annotations/\${annot_name}/*
# and writes a configuration for it as      basename(\${genome})/Config/\${annot_name}.config


################################################################################
#
# Required:
#
#  --genome <string>      path to genome.fasta
#
#  --GTF <string>         path to annotation GTF-formatted file 
#                         (ex. from UCSC genome browser or from genome-studio)
#
#  --annot_name <string>  give a simple name to be used for this annotation set. 
#                         (ex. mm9_refseq or mm9_ucsc)
#
#  --rRNA <string>        path to rRNA fasta file for use with rnaseq-qc
#
# Optional:
#
#  --iso_map <string>     gene-to-isoform mapping file.  By default, extract this data directly from the GTF file.
#
#  --IGV_genome <string>  path to the corresponding .genome file used by IGV 
#                          (needed for making tdf files)
#
#  --just <string>         tophat|rsem
#
#  --no_replace           do not replace existing already-installed files
#
################################################################################


__EOUSAGE__


    ;



my $help_flag;
my $genome_fasta;
my $gtf_file;
my $annot_name;
my $IGV_genome;
my $rRNA_file;
my $just;
my $iso_map_file;
my $NO_REPLACE = 0;

&GetOptions ( 'h' => \$help_flag,

              'genome=s' => \$genome_fasta,
              'GTF=s' => \$gtf_file,
              'annot_name=s' => \$annot_name,
              'rRNA=s' => \$rRNA_file,

              'iso_map=s' => \$iso_map_file,

              'IGV_genome=s' => \$IGV_genome,
         
              'just=s' => \$just,
     
              'no_replace' => \$NO_REPLACE,

              );

if ($help_flag) {
    die $usage;
}

unless ($genome_fasta && $gtf_file && $annot_name && $rRNA_file) {
    die $usage;
}

if ($just) {
    unless ($just =~ /^(rsem|tophat)$/) {
        die "Error, dont recognize just: $just";
    }
}


main: {


    $genome_fasta = &create_full_path($genome_fasta);
    $rRNA_file = &create_full_path($rRNA_file);
    
    my $genome_dir = dirname($genome_fasta);
    my $annot_install_dir = "$genome_dir/Annotations/$annot_name";
    my $config_dir = "$genome_dir/Config";
    my $config_file = "$config_dir/$annot_name.config";


    &process_cmd("mkdir -p $annot_install_dir") unless (-d $annot_install_dir);
    &process_cmd("mkdir -p $config_dir") unless (-d $config_dir);
    
    my $dest_annot_file = "$annot_install_dir/" . basename($gtf_file);
    &process_cmd("cp $gtf_file $dest_annot_file") unless ($NO_REPLACE && -s $dest_annot_file);
    
    unless ($NO_REPLACE && -s $config_file) {
        open (my $config_ofh, ">$config_file") or die "Error, cannot write to $config_file";
        
        
        print $config_ofh "GENOME_FA=$genome_fasta\n";
        print $config_ofh "ANNOT_NAME=$annot_name\n";
        print $config_ofh "ANNOT_GTF=$dest_annot_file\n";
        print $config_ofh "RRNA_FA=$rRNA_file\n";
        
        if ($IGV_genome) {
            $IGV_genome = &create_full_path($IGV_genome);
            print $config_ofh "IGV_GENOME=$IGV_genome\n";
        }

        
        print $config_ofh "TOPHAT_TRANS=$annot_install_dir/tophat_trans_index\n";
        
        print $config_ofh "RSEM_TRANS=$annot_install_dir/rsem_trans_index\n";
        
        close $config_ofh;
        
    }

    ###################
    ## Prep for tophat
    ###################

    
    
    my $cmd = "tophat2 -G $dest_annot_file -T --transcriptome-index $annot_install_dir/tophat_trans_index -o /tmp/$$.tophat.out $genome_fasta /tmp/tmp.left.fq /tmp/tmp.right.fq";
 
    unless ($just && $just ne 'tophat') {
        
        &write_tmp_fq_files("/tmp/tmp.left.fq", "/tmp/tmp.right.fq");
        
        eval {
            # sometimes fails at alignment stage due to only having a few reads
            # not a problem for setup, though.
            &process_cmd($cmd);
            
        };
    }


    #################
    ## Prep for RSEM
    #################

    
    unless ($just && $just ne 'rsem') {

        my $gene_iso_map_file = ($iso_map_file) ? $iso_map_file : &write_RSEM_iso_map($dest_annot_file);
        
        $cmd = "/seq/regev_genome_portal/SOFTWARE/BIN/rsem-prepare-reference --gtf $dest_annot_file --transcript-to-gene-map $gene_iso_map_file $genome_fasta $annot_install_dir/rsem_trans_index";
        
        
        &process_cmd($cmd);
        
    }

    
    print STDERR "Done.\n";
    
    exit(0);
}

####
sub process_cmd {
    my ($cmd) = @_;

    print STDERR "CMD: $cmd\n";
    my $ret = system($cmd);

    if ($ret) {
        die "Error, CMD: $cmd died with ret $ret";
    }

    return;
}


####
sub write_tmp_fq_files {
    my ($left_fq_file, $right_fq_file) = @_;

    my $left_fq_ex = '@61G9EAAXX100520:5:100:10000:12335/1
CGGGTTAGAATCAACAAGTGTAGGAGGAACTTGGTAACGATGATTTAAATTATCTGCACTACGGTCGT
+
GGGFEGGGGFGGGGGGGGEGDGGEFGGEEFGGFFCFCGGEFFDEEEEAEGDEEBDEDCDEAEBCACED
@61G9EAAXX100520:5:100:10000:14468/1
ACGAGTAATCTTGGTGGGGATACCAAGAGCTTGGAAGAAAGAGGTCTTACCGGGTTCCATACCAGTGT
+
GGGGGGGGGDGGGGBGGGGGGGGFDFGGGGGGGFEFGEFFGDEFDDEGGEEEEECDDFDEDDACDCDE
@61G9EAAXX100520:5:100:10000:19359/1
GAGGGATATAAGAGCAGACCGATTTTGGTAAGTATGTGTCCATGGCATAAAGAAGATAATTACGGCGA
+
GGGDFGGEGGGGGGGGECGGFEGGGDEE@EEFDFEEDBBEEDEFDD?EBBBED?E=DBDDBBB?BAB@
@61G9EAAXX100520:5:100:10000:20525/1
ATAAAATCGATTTTACCCTTCCATTAATAGCATCTTGTCCGCAATTATTTTTAGCCTATTTTTGAATC
+
GGGGGGGGGGDGGGGGGFDGEDGEFFFGBDEFEFDD?CBDBE@?EDCDEF???:CDC?CCBC>-ACCE
@61G9EAAXX100520:5:100:10000:5699/1
ATTGAGGAATAGTAATAAACGGAGGACTATTTAACCTGTTTCCTTTCTTTACGTTTTTTAAATCCTTT
+
DDDDABBD?DDDCDDDDD?DD5DDD:CB=DACBCCDDBB:BCCCBBA=?AABBABBBBBBB@B=BAAA';

    my $right_fq_ex = '@61G9EAAXX100520:5:100:10000:12335/2
GGATCTTTCACATTTGAAATGTCTCTTCCTCACCGTAATCCCTCATTGTCTTCCCTTCCAACTACTGG
+
GGDGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGEGFGGGGGGFFFGEFFGGGGGGGGDEEGEFGFG
@61G9EAAXX100520:5:100:10000:14468/2
GTCTTCACCAACGCTGATTTGAAGGAAGTCCGTGAGACCATTATTGCTAATGTTATTGCTGCTCCTGC
+
GGFGGGGGDGGGGGGGGGGGFEGGFGGGEGGGFGGGGGFGGGGGGGGGGGGGDGBGFFFFFEEFEFFB
@61G9EAAXX100520:5:100:10000:19359/2
GCAATTTGTAAAAGAACTTATTCCTTCATTCTTAAGTATGGATGTCGACGGTCGTGTCATCCGTATGG
+
GFGGEFGFGGGGGFFAGGDGFDGFGGGBFEGGGEED:EEDEECEAEAFFF?+AB@CBCBB?:BBB5?5
@61G9EAAXX100520:5:100:10000:20525/2
TCTTTTCAAAGCAATGCTAACAAGGTCAACAATGCAAACAGCCAACCCGCTGGGTTTCCGTTCAACTC
+
GGFGGGGGGGGGDGFBGGGGGGFGGEGGGGEFGGGFGGFGGGGGGGGFDFDBDGCEFEFDCEDEDDDF
@61G9EAAXX100520:5:100:10000:5699/2
AGTCGCTGTGCCTTACATACAGCTGCTAAGGATCCTTTTCGATCTAAAAATTCGCTCCGGTGTAACAG
+
EDGFGGFGGGBGGGGDFEGEFGGGGGDGGDDFBDG?DFFEGEEFEFD?EFBDDGDGGD=AEEBEEDBD';

    open (my $ofh, ">$left_fq_file") or die $!;
    print $ofh $left_fq_ex;
    close $ofh;

    open ($ofh, ">$right_fq_file") or die $!;
    print $ofh $right_fq_ex;
    close $ofh;
    
    return;
}


####
sub write_RSEM_iso_map {
    my ($gtf_file) = @_;

    my %gene_to_trans;

    open (my $fh, $gtf_file) or die "Error, cannot open file $gtf_file";
    while (<$fh>) {
        chomp;
        my ($gene_id, $trans_id);
        if (/gene_id \"([^\"]+)\"/) {
            $gene_id = $1;
        }
        if (/transcript_id \"([^\"]+)\"/) {
            $trans_id = $1;
        }
    
        if (defined($gene_id) && defined($trans_id)) {
            $gene_to_trans{$gene_id}->{$trans_id} = 1;
        }
        
    }
    close $fh;

    my $gene_iso_map = "$gtf_file.gene_iso_map";
    open (my $ofh, ">$gene_iso_map") or die "Error, cannot write to file $gene_iso_map";
    
    foreach my $gene_id (keys %gene_to_trans) {

        my $trans_href = $gene_to_trans{$gene_id};
        foreach my $trans_id (keys %$trans_href) {

            print $ofh join("\t", $gene_id, $trans_id) . "\n";
        }
    }

    close $ofh;

    print STDERR "-wrote $gene_iso_map\n";
    
    return ($gene_iso_map);
}


sub create_full_path {
    my ($path) = @_;

    unless ($path =~ /^\//) {
        ## must be a relative path.
        $path = cwd() . "/$path"; # now fully qualified.
    }

    return($path);
}
