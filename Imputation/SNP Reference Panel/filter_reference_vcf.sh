#Script to filter vcf files, 
#removing singletons and keeping only biallelic SNPs

bcftools view -m 2 -M 2 -c 2 -v snps -Ob -o ./out/$1 --threads 2 $1 
