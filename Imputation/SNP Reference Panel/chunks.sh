#Script to create genomic chunks for
#GLIMPSE to run to

chr=/PROVIDE/CHROMOSOME/NUMBER/

GLIMPSE_chunk --input $1 --region $chr --window-size 2000000 --buffer-size 200000 --output ./chunks/chunks.chr$1.txt --thread 4
