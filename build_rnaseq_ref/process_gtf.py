#!/usr/bin/env python 

# created by : Asma Bankapur
# modified by : Karthik Shekhar

# The following program will read in a gtf file and create a txt file with gene and isoform names as two columns

##### IMPORT MODULES #####
import os
import argparse
import csv 

# GLOBALS
DELIMITER = "\t"
GTF_COMMENT = "#!"
SPLIT_TOKENS = "; "
SPLIT_COUPLE = ' "'
SPLIT_COUPLE_JOIN = ' '
TRANS_ID = "transcript_id"
DEF_TRANS_ID = ""
STRIP_QUOTES = '"'
TRANS_NAME = "transcript_name"
DEF_TRANS_NAME = ""
JOIN_NAID = "_"
UNKNOWN = '"unknown"'
TOKEN_SEP=";"

def correct_gtf( gtf_file ):
    corrected_file = [ ];
    with open(gtf_file, "r") as gtf:
        gtf_reader = csv.reader(gtf, delimiter=DELIMITER)
        for feature_row in gtf_reader:
	    # Add comment feature as is and continue
	    if feature_row[0].startswith( GTF_COMMENT ):
	        corrected_file.append(DELIMITER.join(feature_row))
		continue
	    ###
	    #geneid: dict for last element in feature_row
	    #gene_id_order_list : list to maintain last element token order
	    ###
	    geneid = {}
	    gene_id_order_list = [ ]

	    gene_cood_chr_info = feature_row[0:-1]
	    token_list_coupled = feature_row[-1].split(SPLIT_TOKENS)
            
	    # Loop to split each token pair and append to order list
	    # Also store the token pair in geneid as key val
            for token_couple in token_list_coupled:
	        token, token_value = token_couple.split(SPLIT_COUPLE)
                token_value=STRIP_QUOTES+token_value
		gene_id_order_list.append(token)
		geneid[token] = token_value
	    
	    # Get 'gene_name', if not empty str and strip "

	    trans_id = geneid.get(TRANS_ID, DEF_TRANS_ID).strip(STRIP_QUOTES)
	    new_transname = geneid.get(TRANS_NAME, DEF_TRANS_NAME).strip(STRIP_QUOTES)
	    trans_id = JOIN_NAID.join([id_token for id_token in [new_transname, trans_id] if id_token])
            trans_id = UNKNOWN if not trans_id else STRIP_QUOTES+trans_id+STRIP_QUOTES
	    geneid[TRANS_ID] = trans_id
            
	    # ADD ID TOKEN
	    for id_token in [TRANS_ID]:
	        if id_token not in gene_id_order_list:
                    gene_id_order_list.append(id_token)
            gene_id_str = SPLIT_TOKENS.join([token+SPLIT_COUPLE_JOIN+(geneid[token]).strip(TOKEN_SEP) for token in gene_id_order_list])
	    gene_id_str += TOKEN_SEP
	    corrected_file.append(DELIMITER.join(feature_row[0:-1] + [gene_id_str]))
    return(corrected_file)    	    

def gene_to_isomap( gtf_file, col1=None, col2=None ):
    # Makes a gene to iso map table
    if col1 is None:
        col1 = "gene_name"
    if col2 is None:
        col2 = "transcript_id"
    
    gene_iso = [ ]
    with open(gtf_file, "r") as gtf:
        gtf_reader = csv.reader(gtf, delimiter=DELIMITER)

	for feature_row in gtf_reader:
	    if feature_row[0].startswith(GTF_COMMENT):
	        continue
	    
	    token_list_coupled = feature_row[-1].split(SPLIT_TOKENS)

            geneid = {}
	    gene_id_order_list = []
	    for token_couple in token_list_coupled:
	        token, token_value = token_couple.split(SPLIT_COUPLE)
		token_value=STRIP_QUOTES+token_value.strip(';')
		gene_id_order_list.append(token)
		geneid[token] = token_value
	    
            if (not geneid.has_key(col1)) or (not geneid.has_key(col2)):
	        print "Error gtf file does not have these keys"
		return -1
	    
	    temp_str = DELIMITER.join([geneid[col1].strip('"'), geneid[col2].strip('"').strip(';')])
            gene_iso.append(temp_str)
    temp=set(gene_iso)
    gene_iso=list(temp)
    return gene_iso	 


def write_to_file( reconstructed_feature_list, modified_gtf_file):
    with open(modified_gtf_file, "w") as mgh:
        mgh.write("\n".join(reconstructed_feature_list))

if __name__ == "__main__":
    arg_raw = argparse.ArgumentParser(prog="create_gene_iso_map.py", description="Create a txt file with gene and isoform names for RSEM")
    arg_raw.add_argument("--gtf_input", help="Input GTF file (Required).")
    arg_raw.add_argument("--gtf_output", help="Output GTF file (Required).")
    arg_raw.add_argument("--gene_iso_map_file", help="txt file containing gene to iso map columns (Required). ")
    arg_parsed = arg_raw.parse_args()
    #gtf_corrected = correct_gtf( arg_parsed.gtf_input )
    #write_to_file(gtf_corrected, arg_parsed.gtf_output)
    genes_iso_table = gene_to_isomap(arg_parsed.gtf_output, col1="gene_name", col2="transcript_id")
    #print type(genes_iso_table)
    print(len(genes_iso_table))
    write_to_file(genes_iso_table, arg_parsed.gene_iso_map_file)
