#Script to creates alleles list for
#Genotype Likelihood estimation and Phasing/Imputation
#to run to

zgrep -v '#' $1 | cut -f1,2,4,5 > ./alleles/${1/.vcf.gz/.alleles}

