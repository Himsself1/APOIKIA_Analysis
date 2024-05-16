#!/usr/bin/bash

# PATH_TO_INPUT="/home/aggeliki/apoikia/EIGENSTRAT/new_dataset_01_02_2024/APOIKIA_PLUS_PUBLIC_ANCIENT"
# PATH_TO_TRIMMED="/home/aggeliki/apoikia/EIGENSTRAT/new_dataset_01_02_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/trimmed_data_maf_005_no_relatives"
# PATH_TO_FAMILY_FILE="/home/aggeliki/apoikia/APOIKIA_Analysis/admixture_analysis/family_to_remove.tsv"

PATH_TO_INPUT="/home/aggeliki/apoikia/EIGENSTRAT/dataset_04_05_2024/APOIKIA_PLUS_PUBLIC_ANCIENT"
PATH_TO_TRIMMED="/home/aggeliki/apoikia/EIGENSTRAT/dataset_04_05_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/trimmed_data_maf_005_no_relatives"
PATH_TO_FAMILY_FILE="/home/aggeliki/apoikia/APOIKIA_Analysis/admixture_analysis/family_to_remove.tsv"

mkdir -p $PATH_TO_TRIMMED
# * Converts eigenstrat to .ped

/usr/bin/convertf -p ~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia_04_05_2024_to_plink.parfile
# /usr/bin/convertf -p ~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia_01_02_2024_to_plink.parfile
## ADMIXTURE doesn't like something about convertf output
## PLINK doesn't seem to mind. Will convert to bed

# * Call to PLINK for the conversion to bed and filtering

# Doesn't filter for LD

plink1.9 --ped $PATH_TO_INPUT/apoikia.1240K.ANCIENT.ped \
	 --map $PATH_TO_INPUT/apoikia.1240K.ANCIENT.pedsnp \
	 --make-bed --geno 0.99 --maf 0.05 \
	 --remove $PATH_TO_FAMILY_FILE \
	 --out $PATH_TO_INPUT/apoikia.1240K.ANCIENT_maf_005_no_relatives

## Filters for LD
## --indep-pairwise creates a list of accepted SNPs
## --extract takes previous list as input and makes new files 

# ** 08

plink1.9 --bfile $PATH_TO_INPUT/apoikia.1240K.ANCIENT_maf_005_no_relatives \
	 --indep-pairwise 200 25 0.8 \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_08 \
	 --allow-no-sex --keep-allele-order --no-pheno

plink1.9 --bfile $PATH_TO_INPUT/apoikia.1240K.ANCIENT_maf_005_no_relatives \
	 --extract $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_08.prune.in \
	 --make-bed --allow-no-sex --keep-allele-order \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_08.trimmed --no-pheno

# ** 06

plink1.9 --bfile $PATH_TO_INPUT/apoikia.1240K.ANCIENT_maf_005_no_relatives \
	 --indep-pairwise 200 25 0.6 \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_06 \
	 --allow-no-sex --keep-allele-order --no-pheno

plink1.9 --bfile $PATH_TO_INPUT/apoikia.1240K.ANCIENT_maf_005_no_relatives \
	 --extract $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_06.prune.in \
	 --make-bed --allow-no-sex --keep-allele-order \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_06.trimmed --no-pheno

# ** 04

plink1.9 --bfile $PATH_TO_INPUT/apoikia.1240K.ANCIENT_maf_005_no_relatives \
	 --indep-pairwise 200 25 0.4 \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_04 \
	 --allow-no-sex --keep-allele-order --no-pheno

plink1.9 --bfile $PATH_TO_INPUT/apoikia.1240K.ANCIENT_maf_005_no_relatives \
	 --extract $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_04.prune.in \
	 --make-bed --allow-no-sex --keep-allele-order \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_04.trimmed --no-pheno

# * Make stricter filtering based on missingness

# ** Geno 0.8

# *** 08

plink1.9 --bfile $PATH_TO_INPUT/apoikia.1240K.ANCIENT_maf_005_no_relatives \
	 --indep-pairwise 200 25 0.8 \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_08.geno_08 \
	 --allow-no-sex --keep-allele-order --no-pheno --geno 0.8

plink1.9 --bfile $PATH_TO_INPUT/apoikia.1240K.ANCIENT_maf_005_no_relatives \
	 --extract $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_08.geno_08.prune.in \
	 --make-bed --allow-no-sex --keep-allele-order \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_08.trimmed.geno_08 --no-pheno

# *** 06

plink1.9 --bfile $PATH_TO_INPUT/apoikia.1240K.ANCIENT_maf_005_no_relatives \
	 --indep-pairwise 200 25 0.6 \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_06.geno_08 \
	 --allow-no-sex --keep-allele-order --no-pheno --geno 0.8

plink1.9 --bfile $PATH_TO_INPUT/apoikia.1240K.ANCIENT_maf_005_no_relatives \
	 --extract $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_06.geno_08.prune.in \
	 --make-bed --allow-no-sex --keep-allele-order \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_06.trimmed.geno_08 --no-pheno

# *** 04

plink1.9 --bfile $PATH_TO_INPUT/apoikia.1240K.ANCIENT_maf_005_no_relatives \
	 --indep-pairwise 200 25 0.4 \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_04.geno_08 \
	 --allow-no-sex --keep-allele-order --no-pheno --geno 0.8

plink1.9 --bfile $PATH_TO_INPUT/apoikia.1240K.ANCIENT_maf_005_no_relatives \
	 --extract $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_04.geno_08.prune.in \
	 --make-bed --allow-no-sex --keep-allele-order \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_04.trimmed.geno_08 --no-pheno

# ** Geno 0.6

# *** 08

plink1.9 --bfile $PATH_TO_INPUT/apoikia.1240K.ANCIENT_maf_005_no_relatives \
	 --indep-pairwise 200 25 0.8 \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_08.geno_06 \
	 --allow-no-sex --keep-allele-order --no-pheno --geno 0.6

plink1.9 --bfile $PATH_TO_INPUT/apoikia.1240K.ANCIENT_maf_005_no_relatives \
	 --extract $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_08.geno_06.prune.in \
	 --make-bed --allow-no-sex --keep-allele-order \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_08.trimmed.geno_06 --no-pheno

# *** 06

plink1.9 --bfile $PATH_TO_INPUT/apoikia.1240K.ANCIENT_maf_005_no_relatives \
	 --indep-pairwise 200 25 0.6 \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_06.geno_06 \
	 --allow-no-sex --keep-allele-order --no-pheno --geno 0.6

plink1.9 --bfile $PATH_TO_INPUT/apoikia.1240K.ANCIENT_maf_005_no_relatives \
	 --extract $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_06.geno_06.prune.in \
	 --make-bed --allow-no-sex --keep-allele-order \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_06.trimmed.geno_06 --no-pheno

# *** 04

plink1.9 --bfile $PATH_TO_INPUT/apoikia.1240K.ANCIENT_maf_005_no_relatives \
	 --indep-pairwise 200 25 0.4 \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_04.geno_06 \
	 --allow-no-sex --keep-allele-order --no-pheno --geno 0.6

plink1.9 --bfile $PATH_TO_INPUT/apoikia.1240K.ANCIENT_maf_005_no_relatives \
	 --extract $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_04.geno_06.prune.in \
	 --make-bed --allow-no-sex --keep-allele-order \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_04.trimmed.geno_06 --no-pheno

# ** Geno 0.4

# *** 08

plink1.9 --bfile $PATH_TO_INPUT/apoikia.1240K.ANCIENT_maf_005_no_relatives \
	 --indep-pairwise 200 25 0.8 \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_08.geno_04 \
	 --allow-no-sex --keep-allele-order --no-pheno --geno 0.4

plink1.9 --bfile $PATH_TO_INPUT/apoikia.1240K.ANCIENT_maf_005_no_relatives \
	 --extract $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_08.geno_04.prune.in \
	 --make-bed --allow-no-sex --keep-allele-order \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_08.trimmed.geno_04 --no-pheno

# *** 06

plink1.9 --bfile $PATH_TO_INPUT/apoikia.1240K.ANCIENT_maf_005_no_relatives \
	 --indep-pairwise 200 25 0.6 \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_06.geno_04 \
	 --allow-no-sex --keep-allele-order --no-pheno --geno 0.4

plink1.9 --bfile $PATH_TO_INPUT/apoikia.1240K.ANCIENT_maf_005_no_relatives \
	 --extract $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_06.geno_04.prune.in \
	 --make-bed --allow-no-sex --keep-allele-order \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_06.trimmed.geno_04 --no-pheno

# *** 04

plink1.9 --bfile $PATH_TO_INPUT/apoikia.1240K.ANCIENT_maf_005_no_relatives \
	 --indep-pairwise 200 25 0.4 \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_04.geno_04 \
	 --allow-no-sex --keep-allele-order --no-pheno --geno 0.4

plink1.9 --bfile $PATH_TO_INPUT/apoikia.1240K.ANCIENT_maf_005_no_relatives \
	 --extract $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_04.geno_04.prune.in \
	 --make-bed --allow-no-sex --keep-allele-order \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_04.trimmed.geno_04 --no-pheno

