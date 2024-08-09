#!/usr/bin/bash

## Script for removing paleolithic individuals and running ADMIXTURE 

# * File Names
PATH_TO_INPUT="/home/aggeliki/apoikia/EIGENSTRAT/dataset_04_05_2024/APOIKIA_PLUS_PUBLIC_ANCIENT"
PATH_TO_TRIMMED="/home/aggeliki/apoikia/EIGENSTRAT/dataset_04_05_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/no_moroccans"
PATH_TO_PALEO_FILE="/home/aggeliki/apoikia/APOIKIA_Analysis/admixture_analysis/upper_paleolithics.tsv"

# PATH_TO_OUTPUT="/home/aggeliki/apoikia/admixture_logs/dataset_04_05_2024/diploid_no_paleo"

mkdir -p $PATH_TO_TRIMMED
# mkdir -p $PATH_TO_OUTPUT

# * Remove relatives with PLINK

plink1.9 --bfile $PATH_TO_INPUT/apoikia.1240K.ANCIENT_no_relatives \
	 --make-bed --geno 0.99 \
	 --remove $PATH_TO_PALEO_FILE \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT_no_relatives_no_moroccans


# ** 08

plink1.9 --bfile $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT_no_relatives_no_moroccans \
	 --indep-pairwise 200 25 0.8 \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_08 \
	 --allow-no-sex --keep-allele-order --no-pheno

plink1.9 --bfile $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT_no_relatives_no_moroccans \
	 --extract $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_08.prune.in \
	 --make-bed --allow-no-sex --keep-allele-order \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_08.trimmed --no-pheno

# ** 06

plink1.9 --bfile $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT_no_relatives_no_moroccans \
	 --indep-pairwise 200 25 0.6 \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_06 \
	 --allow-no-sex --keep-allele-order --no-pheno

plink1.9 --bfile $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT_no_relatives_no_moroccans \
	 --extract $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_06.prune.in \
	 --make-bed --allow-no-sex --keep-allele-order \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_06.trimmed --no-pheno

# ** 04

plink1.9 --bfile $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT_no_relatives_no_moroccans \
	 --indep-pairwise 200 25 0.4 \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_04 \
	 --allow-no-sex --keep-allele-order --no-pheno

plink1.9 --bfile $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT_no_relatives_no_moroccans \
	 --extract $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_04.prune.in \
	 --make-bed --allow-no-sex --keep-allele-order \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_04.trimmed --no-pheno

# * Make stricter filtering based on missingness

# ** Geno 0.8

# *** 08

plink1.9 --bfile $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT_no_relatives_no_moroccans \
	 --indep-pairwise 200 25 0.8 \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_08.geno_08 \
	 --allow-no-sex --keep-allele-order --no-pheno --geno 0.8

plink1.9 --bfile $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT_no_relatives_no_moroccans \
	 --extract $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_08.geno_08.prune.in \
	 --make-bed --allow-no-sex --keep-allele-order \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_08.trimmed.geno_08 --no-pheno

# *** 06

plink1.9 --bfile $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT_no_relatives_no_moroccans \
	 --indep-pairwise 200 25 0.6 \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_06.geno_08 \
	 --allow-no-sex --keep-allele-order --no-pheno --geno 0.8

plink1.9 --bfile $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT_no_relatives_no_moroccans \
	 --extract $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_06.geno_08.prune.in \
	 --make-bed --allow-no-sex --keep-allele-order \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_06.trimmed.geno_08 --no-pheno

# *** 04

plink1.9 --bfile $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT_no_relatives_no_moroccans \
	 --indep-pairwise 200 25 0.4 \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_04.geno_08 \
	 --allow-no-sex --keep-allele-order --no-pheno --geno 0.8

plink1.9 --bfile $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT_no_relatives_no_moroccans \
	 --extract $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_04.geno_08.prune.in \
	 --make-bed --allow-no-sex --keep-allele-order \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_04.trimmed.geno_08 --no-pheno

# ** Geno 0.6

# *** 08

plink1.9 --bfile $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT_no_relatives_no_moroccans \
	 --indep-pairwise 200 25 0.8 \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_08.geno_06 \
	 --allow-no-sex --keep-allele-order --no-pheno --geno 0.6

plink1.9 --bfile $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT_no_relatives_no_moroccans \
	 --extract $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_08.geno_06.prune.in \
	 --make-bed --allow-no-sex --keep-allele-order \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_08.trimmed.geno_06 --no-pheno

# *** 06

plink1.9 --bfile $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT_no_relatives_no_moroccans \
	 --indep-pairwise 200 25 0.6 \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_06.geno_06 \
	 --allow-no-sex --keep-allele-order --no-pheno --geno 0.6

plink1.9 --bfile $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT_no_relatives_no_moroccans \
	 --extract $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_06.geno_06.prune.in \
	 --make-bed --allow-no-sex --keep-allele-order \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_06.trimmed.geno_06 --no-pheno

# *** 04

plink1.9 --bfile $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT_no_relatives_no_moroccans \
	 --indep-pairwise 200 25 0.4 \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_04.geno_06 \
	 --allow-no-sex --keep-allele-order --no-pheno --geno 0.6

plink1.9 --bfile $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT_no_relatives_no_moroccans \
	 --extract $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_04.geno_06.prune.in \
	 --make-bed --allow-no-sex --keep-allele-order \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_04.trimmed.geno_06 --no-pheno

# ** Geno 0.4

# *** 08

plink1.9 --bfile $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT_no_relatives_no_moroccans \
	 --indep-pairwise 200 25 0.8 \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_08.geno_04 \
	 --allow-no-sex --keep-allele-order --no-pheno --geno 0.4

plink1.9 --bfile $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT_no_relatives_no_moroccans \
	 --extract $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_08.geno_04.prune.in \
	 --make-bed --allow-no-sex --keep-allele-order \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_08.trimmed.geno_04 --no-pheno

# *** 06

plink1.9 --bfile $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT_no_relatives_no_moroccans \
	 --indep-pairwise 200 25 0.6 \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_06.geno_04 \
	 --allow-no-sex --keep-allele-order --no-pheno --geno 0.4

plink1.9 --bfile $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT_no_relatives_no_moroccans \
	 --extract $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_06.geno_04.prune.in \
	 --make-bed --allow-no-sex --keep-allele-order \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_06.trimmed.geno_04 --no-pheno

# *** 04

plink1.9 --bfile $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT_no_relatives_no_moroccans \
	 --indep-pairwise 200 25 0.4 \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_04.geno_04 \
	 --allow-no-sex --keep-allele-order --no-pheno --geno 0.4

plink1.9 --bfile $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT_no_relatives_no_moroccans \
	 --extract $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_04.geno_04.prune.in \
	 --make-bed --allow-no-sex --keep-allele-order \
	 --out $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT.LD_200_25_04.trimmed.geno_04 --no-pheno




# # * Run Admixture

# for K in 2 3 4 5 6 7 8 9 10; do
#     admixture32 --cv $PATH_TO_TRIMMED/apoikia.1240K.ANCIENT_no_relatives_no_moroccans.bed $K \
# 		--seed time -j10 | tee $PATH_TO_OUTPUT/apoikia.1240K.diploid.no_paleo.${K}.out;
# done

# * Make Plot

# Rscript plot_admixture_04_05_2024.R \
# 	-input_folder /home/aggeliki/apoikia/APOIKIA_Analysis/admixture_analysis \
# 	-plot_folder /home/aggeliki/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_no_morrocans/no_maf/geno_99 \
# 	-label_file /home/aggeliki/apoikia/APOIKIA_Analysis/admixture_analysis/Layers_for_Admixture_04_05_2024.csv \
# 	-meta /home/aggeliki/apoikia/EIGENSTRAT/dataset_04_05_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/no_moroccans/apoikia.1240K.ANCIENT_no_relatives_no_moroccans.fam
