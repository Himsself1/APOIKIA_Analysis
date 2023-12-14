## install.packages("foreach")
## install.packages("doMC")

## R wrapper for running haploid admixture in parallel

library(foreach)
library(doMC)

cores <- 10
registerDoMC(cores)

## PATH_TO_INPUT="/home/aggeliki/apoikia/EIGENSTRAT/new_dataset_28_07"
## PATH_TO_TRIMMED="/home/aggeliki/apoikia/EIGENSTRAT/new_dataset_28_07/trimmed_data"
## PATH_TO_OUTPUT="/home/aggeliki/apoikia/admixture_logs"

PATH_TO_INPUT="/home/aggeliki/apoikia/EIGENSTRAT/dataset_02_11"
PATH_TO_TRIMMED="/home/aggeliki/apoikia/EIGENSTRAT/dataset_02_11/trimmed_data"
PATH_TO_OUTPUT="/home/aggeliki/apoikia/admixture_logs/dataset_02_11/haploid"

# * LD 08

PATH_TO_08 <- paste0(c(PATH_TO_OUTPUT, "LD_08"), collapse = '/')
dir.create(PATH_TO_08, showWarnings = FALSE, recursive = TRUE)
setwd(PATH_TO_08)

foreach(i = 2:cores) %dopar% {
  cmd <- noquote(paste0(c(
    "admixture32 --cv ",
    PATH_TO_TRIMMED,
    "/apoikia.1240K.APOIKIA.LD_200_25_08.trimmed.bed ",
    i,
    ' --haploid="*" --seed time | tee ',
    PATH_TO_OUTPUT,
    "/apoikia.1240K.LD_200_25_08.admixture.", i,
    ".haploid.out;"
  ), collapse = ""))
  ## system(cmd)
  print(cmd)
}

# * LD 06

PATH_TO_06 <- paste0(c(PATH_TO_OUTPUT, "LD_06"), collapse = "/")
dir.create(PATH_TO_06, showWarnings = FALSE, recursive = TRUE)
setwd(PATH_TO_06)

foreach(i = 2:cores) %dopar% {
  cmd <- noquote(paste0(c(
    "admixture32 --cv ",
    PATH_TO_TRIMMED,
    "/apoikia.1240K.APOIKIA.LD_200_25_06.trimmed.bed ",
    i,
    ' --haploid="*" --seed time | tee ',
    PATH_TO_OUTPUT,
    "/apoikia.1240K.LD_200_25_06.admixture.", i,
    ".haploid.out;"
  ), collapse = ""))
  system(cmd)
  ## print(cmd)
}

# * LD 04

PATH_TO_04 <- paste0(c(PATH_TO_OUTPUT, "LD_04"), collapse = "/")
dir.create(PATH_TO_04, showWarnings = FALSE, recursive = TRUE)
setwd(PATH_TO_04)

foreach(i = 2:cores) %dopar% {
  cmd <- noquote(paste0(c(
    "admixture32 --cv ",
    PATH_TO_TRIMMED,
    "/apoikia.1240K.APOIKIA.LD_200_25_04.trimmed.bed ",
    i,
    ' --haploid="*" --seed time | tee ',
    PATH_TO_OUTPUT,
    "/apoikia.1240K.LD_200_25_04.admixture.", i,
    ".haploid.out;"
  ), collapse = ""))
  system(cmd)
  ## print(cmd)
}

  ## print(cmd)
  ## admixture32 --cv $PATH_TO_TRIMMED/apoikia.1240K.APOIKIA.LD_200_25_08.trimmed.bed $K --seed time -j10 | tee $PATH_TO_OUTPUT/apoikia.1240K.LD_200_25_08.admixture.${K}.out;
