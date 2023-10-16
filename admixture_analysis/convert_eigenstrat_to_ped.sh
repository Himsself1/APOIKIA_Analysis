#!/usr/bin/bash
PATH_TO_INPUT="/home/aggeliki/apoikia/EIGENSTRAT/new_dataset_28_07"
PATH_TO_TRIMMED="/home/aggeliki/apoikia/EIGENSTRAT/new_dataset_28_07/trimmed_data"
# * Converts eigenstrat to .ped
# /usr/bin/convertf -p ~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia_to_plink.parfile
## ADMIXTURE doesn't like something about convertf output
## PLINK doesn't seem to mind. Will convert to bed
# * Call to PLINK for the conversion to bed and filtering
# Doesn't filter for LD
# plink1.9 --ped $PATH_TO_INPUT/apoikia.1240K.APOIKIA.ped --map $PATH_TO_INPUT/apoikia.1240K.APOIKIA.pedsnp --make-bed --geno 0.99 --out $PATH_TO_INPUT/apoikia.1240K.APOIKIA 
## Filters for LD
## --indep-pairwise creates a list of accepted SNPs
## --extract takes previous list as input and makes new files 
## 08
plink1.9 --bfile $PATH_TO_INPUT/apoikia.1240K.APOIKIA --indep-pairwise 200 25 0.8 --out $PATH_TO_TRIMMED/apoikia.1240K.APOIKIA.LD_200_25_08 --allow-no-sex --keep-allele-order --no-pheno

plink1.9 --bfile $PATH_TO_INPUT/apoikia.1240K.APOIKIA --extract $PATH_TO_TRIMMED/apoikia.1240K.APOIKIA.LD_200_25_08.prune.in --make-bed --allow-no-sex --keep-allele-order --out $PATH_TO_TRIMMED/apoikia.1240K.APOIKIA.LD_200_25_08.trimmed --no-pheno
## 06
plink1.9 --bfile $PATH_TO_INPUT/apoikia.1240K.APOIKIA --indep-pairwise 200 25 0.6 --out $PATH_TO_TRIMMED/apoikia.1240K.APOIKIA.LD_200_25_06 --allow-no-sex --keep-allele-order --no-pheno

plink1.9 --bfile $PATH_TO_INPUT/apoikia.1240K.APOIKIA --extract $PATH_TO_TRIMMED/apoikia.1240K.APOIKIA.LD_200_25_06.prune.in --make-bed --allow-no-sex --keep-allele-order --out $PATH_TO_TRIMMED/apoikia.1240K.APOIKIA.LD_200_25_06.trimmed --no-pheno
## 04
plink1.9 --bfile $PATH_TO_INPUT/apoikia.1240K.APOIKIA  --indep-pairwise 200 25 0.4 --out $PATH_TO_TRIMMED/apoikia.1240K.APOIKIA.LD_200_25_04 --allow-no-sex --keep-allele-order --no-pheno

plink1.9 --bfile $PATH_TO_INPUT/apoikia.1240K.APOIKIA --extract $PATH_TO_TRIMMED/apoikia.1240K.APOIKIA.LD_200_25_04.prune.in --make-bed --allow-no-sex --keep-allele-order --out $PATH_TO_TRIMMED/apoikia.1240K.APOIKIA.LD_200_25_04.trimmed --no-pheno
