#!/bin/bash

cat Zv10.minus_nc.gtf | awk '{if (match($0, /gene_name[^;]*;/)){c=substr($0, RSTART, RLENGTH-1); gsub("gene_name ","",c); gsub("\"","",c); print c}}' > gene_name.txt
cat Zv10.minus_nc.gtf | awk '{if (match($0, /transcript_id[^;]*;/)){c=substr($0, RSTART, RLENGTH-1); gsub("transcript_id ","",c); gsub("\"","",c); print c}}' > transcript_id.txt
sed -i '/^$/d' gene_name.txt
sed -i '/^$/d' transcript_id.txt


