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

PATH_TO_INPUT="/home/aggeliki/apoikia/EIGENSTRAT/new_dataset_01_02_2024/APOIKIA_PLUS_PUBLIC_ANCIENT"
PATH_TO_TRIMMED="/home/aggeliki/apoikia/EIGENSTRAT/new_dataset_01_02_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/trimmed_data_maf_005"
## PATH_TO_OUTPUT="/home/aggeliki/apoikia/admixture_logs/dataset_01_02_2024/haploid"
PATH_TO_OUTPUT="/home/aggeliki/apoikia/admixture_logs_rerun/dataset_01_02_2024/haploid"

# * LD 08

PATH_TO_08 <- paste0(c(PATH_TO_OUTPUT, "LD_08"), collapse = '/')
dir.create(PATH_TO_08, showWarnings = FALSE, recursive = TRUE)
setwd(PATH_TO_08)

# ** Make file names

admixture_input_names <- c()
admixture_output_names <- c()
for(i in 2:cores){
  temp_input <- paste0(c(
    PATH_TO_TRIMMED,
    "/apoikia.1240K.ANCIENT.LD_200_25_08.trimmed.bed ",
    i
  ), collapse = "")
  temp_output <- paste0(c(
    PATH_TO_OUTPUT,
    "/apoikia.1240K.LD_200_25_08.admixture.",
    i, ".haploid.out"
  ), collapse = "")
  admixture_input_names <- c(admixture_input_names, temp_input)
  admixture_output_names <- c(admixture_output_names, temp_output)
}

# ** Runs ADMIXTURE for specific trimmings

foreach(i = 2:cores) %dopar% {
  cmd <- noquote(paste0(c(
    "admixture32 --cv ",
    ## PATH_TO_TRIMMED,
    ## "/apoikia.1240K.ANCIENT.LD_200_25_08.trimmed.bed ",
    ## i,
    admixture_input_names[i-1],
    ' --haploid="*" --seed time | tee ',
    ## PATH_TO_OUTPUT,
    ## "/apoikia.1240K.LD_200_25_08.admixture.", i,
    ## ".haploid.out;"
    admixture_output_names[i-1]
  ), collapse = ""))
  ## system(cmd)
  print(cmd)
}

# ** Print CV Errors

for (i in 1:length(admixture_output_names)) {
  cmd <- noquote(paste0(c(
    "grep -h CV ",
    admixture_output_names[i],
    " | awk '{print $3 $4}' | sed 's/(K=\\([0-9]*\\)):\\([0-9]\\.[0-9]*\\)/\\1,\\2/g'",
    ## R needs to escape the escape character ('\') in order ot print it
    " >> CV_errors_apoikia.1240K.ANCIENT.LD_200_25_08.trimmed.csv"
  ), collapse = ""))
  system(cmd)
}

# * LD 06

PATH_TO_06 <- paste0(c(PATH_TO_OUTPUT, "LD_06"), collapse = "/")
dir.create(PATH_TO_06, showWarnings = FALSE, recursive = TRUE)
setwd(PATH_TO_06)

# ** Make file names

admixture_input_names <- c()
admixture_output_names <- c()
for(i in 2:cores){
  temp_input <- paste0(c(
    PATH_TO_TRIMMED,
    "/apoikia.1240K.ANCIENT.LD_200_25_06.trimmed.bed ",
    i
  ), collapse = '')
  temp_output <- paste0(c(
    PATH_TO_OUTPUT,
    "/apoikia.1240K.LD_200_25_06.admixture.",
    i, ".haploid.out"
  ), collapse = '')
  admixture_input_names <- c(admixture_input_names, temp_input)
  admixture_output_names <- c(admixture_output_names, temp_output)
}

# ** Runs ADMIXTURE for specific trimmings

foreach(i = 2:cores) %dopar% {
  cmd <- noquote(paste0(c(
    "admixture32 --cv ",
    ## PATH_TO_TRIMMED,
    ## "/apoikia.1240K.ANCIENT.LD_200_25_06.trimmed.bed ",
    ## i,
    admixture_input_names[i-1],
    ' --haploid="*" --seed time | tee ',
    ## PATH_TO_OUTPUT,
    ## "/apoikia.1240K.LD_200_25_06.admixture.", i,
    ## ".haploid.out;"
    admixture_output_names[i-1]
  ), collapse = ""))
  system(cmd)
  ## print(cmd)
}

# ** Print CV Errors

for (i in 1:length(admixture_output_names)) {
  cmd <- noquote(paste0(c(
    "grep -h CV ",
    admixture_output_names[i],
    " | awk '{print $3 $4}' | sed 's/(K=\\([0-9]*\\)):\\([0-9]\\.[0-9]*\\)/\\1,\\2/g'",
    ## R needs to escape the escape character ('\') in order ot print it
    " >> CV_errors_apoikia.1240K.ANCIENT.LD_200_25_06.trimmed.csv"
  ), collapse = ""))
  system(cmd)
}

# * LD 04

PATH_TO_04 <- paste0(c(PATH_TO_OUTPUT, "LD_04"), collapse = "/")
dir.create(PATH_TO_04, showWarnings = FALSE, recursive = TRUE)
setwd(PATH_TO_04)

# ** Make file names

admixture_input_names <- c()
admixture_output_names <- c()
for(i in 2:cores){
  temp_input <- paste0(c(
    PATH_TO_TRIMMED,
    "/apoikia.1240K.ANCIENT.LD_200_25_04.trimmed.bed ",
    i
  ), collapse = '')
  temp_output <- paste0(c(
    PATH_TO_OUTPUT,
    "/apoikia.1240K.LD_200_25_04.admixture.",
    i, ".haploid.out"
  ), collapse = '')
  admixture_input_names <- c(admixture_input_names, temp_input)
  admixture_output_names <- c(admixture_output_names, temp_output)
}

# ** Runs ADMIXTURE for specific trimmings

foreach(i = 2:cores) %dopar% {
  cmd <- noquote(paste0(c(
    "admixture32 --cv ",
    ## PATH_TO_TRIMMED,
    ## "/apoikia.1240K.ANCIENT.LD_200_25_06.trimmed.bed ",
    ## i,
    admixture_input_names[i-1],
    ' --haploid="*" --seed time | tee ',
    ## PATH_TO_OUTPUT,
    ## "/apoikia.1240K.LD_200_25_04.admixture.", i,
    ## ".haploid.out;"
    admixture_output_names[i-1]
  ), collapse = ""))
  system(cmd)
  ## print(cmd)
}

# ** Print CV Errors

for(i in 1:length(admixture_output_names)) {
  cmd <- noquote(paste0(c(
    "grep -h CV ",
    admixture_output_names[i],
    " | awk '{print $3 $4}' | sed 's/(K=\\([0-9]*\\)):\\([0-9]\\.[0-9]*\\)/\\1,\\2/g'",
    ## R needs to escape the escape character ('\') in order ot print it
    " >> CV_errors_apoikia.1240K.ANCIENT.LD_200_25_04.trimmed.csv"
  ), collapse = ""))
  system(cmd)
}

  ## print(cmd)
  ## admixture32 --cv $PATH_TO_TRIMMED/apoikia.1240K.APOIKIA.LD_200_25_08.trimmed.bed $K --seed time -j10 | tee $PATH_TO_OUTPUT/apoikia.1240K.LD_200_25_08.admixture.${K}.out;
