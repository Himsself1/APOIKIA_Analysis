#!/usr/bin/bash

PATH_TO_INPUT="/home/aggeliki/apoikia/EIGENSTRAT/new_dataset_28_07"

# * Converts eigenstrat to .ped
/usr/bin/convertf -p ~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia_to_plink.parfile

## ADMIXTURE doesn't like something about convertf output
## PLINK doesn't seem to mind. Will convert to bed

# * Call to PLINK for the conversion to bed and filtering
plink1.9 --ped $PATH_TO_INPUT/apoikia.1240K.APOIKIA.ped --map $PATH_TO_INPUT/apoikia.1240K.APOIKIA.pedsnp --make-bed --geno 0.99 --out $PATH_TO_INPUT/apoikia.1240K.APOIKIA
