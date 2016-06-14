#!/bin/bash

# remove ncRNA
grep -v "rRNA" Danio_rerio.GRCz10.84.gtf > Danio_rerio.GRCz10.84.minus_nc0.gtf
grep -v "snRNA" Danio_rerio.GRCz10.84.minus_nc0.gtf > Danio_rerio.GRCz10.84.minus_nc.gtf
grep -v "snoRNA" Danio_rerio.GRCz10.84.minus_nc.gtf > Danio_rerio.GRCz10.84.minus_nc0.gtf
grep -v "scaRNA" Danio_rerio.GRCz10.84.minus_nc0.gtf > Danio_rerio.GRCz10.84.minus_nc.gtf
grep -v "pseudogene" Danio_rerio.GRCz10.84.minus_nc.gtf > Danio_rerio.GRCz10.84.minus_nc0.gtf
grep -v "miRNA" Danio_rerio.GRCz10.84.minus_nc0.gtf > Danio_rerio.GRCz10.84.minus_nc.gtf
grep -v "antisense" Danio_rerio.GRCz10.84.minus_nc.gtf > Danio_rerio.GRCz10.84.minus_nc0.gtf

mv Danio_rerio.GRCz10.84.minus_nc0.gtf Danio_rerio.GRCz10.84.minus_nc.gtf
rm Danio_rerio.GRCz10.84.minus_nc0.gtf

# ribosomal RNA
cat Danio_rerio.GRCz10.ncrna.fa | awk '/^>/ && /rRNA/{flag=1; print; next;} /^>/{flag=0} //{if(flag==1){print}}' > Danio_rerio.GRCz10.rRNA.fa
