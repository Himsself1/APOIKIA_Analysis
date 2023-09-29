#!/usr/bin/bash

PATH_TO_INPUT="/home/aggeliki/apoikia/EIGENSTRAT/new_dataset_28_07"
PATH_TO_OUTPUT="/home/aggeliki/apoikia/admixture_logs"

## convertf does not print map file correctly
# mv $PATH_TO_INPUT/apoikia.1240K.APOIKIA.map $PATH_TO_INPUT/apoikia.1240K.APOIKIA.map.bak
# cat $PATH_TO_INPUT/apoikia.1240K.APOIKIA.map.bak | awk 'BEGIN {OFS="\t"}; { print  $1, $2, $3, $4 }' > $PATH_TO_INPUT/apoikia.1240K.APOIKIA.map

# admixture32 $PATH_TO_INPUT/apoikia.1240K.APOIKIA.ped 2 --seed time -j4 > test_file

## 64bit admixture reports segmentation fault
## 32 bit doesn't

# * Cross Validation for choosing the best K
for K in 2 3 4 5 6 7 8 9 10; do
    admixture32 --cv $PATH_TO_INPUT/apoikia.1240K.APOIKIA.bed $K --seed time -j10 | tee $PATH_TO_OUTPUT/apoikia.1240K.no_trim.admixture.${K}.out;
done

for K in 2 3 4 5 6 7 8 9 10; do
    admixture32 --cv $PATH_TO_INPUT/apoikia.1240K.APOIKIA.LD.bed $K --seed time -j10 | tee $PATH_TO_OUTPUT/apoikia.1240K.LD_200_25_08.admixture.${K}.out;
done
