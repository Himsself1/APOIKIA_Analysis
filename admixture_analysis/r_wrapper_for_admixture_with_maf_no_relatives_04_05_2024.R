## install.packages("foreach")
## install.packages("doMC")

## R wrapper for running haploid admixture in parallel

library(foreach)
library(doMC)

cores <- 10
registerDoMC(cores)

## PATH_TO_INPUT="/home/aggeliki/apoikia/EIGENSTRAT/new_dataset_01_02_2024/APOIKIA_PLUS_PUBLIC_ANCIENT"
PATH_TO_TRIMMED="/home/aggeliki/apoikia/EIGENSTRAT/dataset_04_05_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/trimmed_data_maf_005_no_relatives"
PATH_TO_OUTPUT="/home/aggeliki/apoikia/admixture_logs/dataset_04_05_2024/haploid_with_maf_no_relatives"

GENO <- c("geno_08", "geno_06", "geno_04")

# * LD 08

PATH_TO_08 <- paste0(c(PATH_TO_OUTPUT, "LD_08"), collapse = '/')
dir.create(PATH_TO_08, showWarnings = FALSE, recursive = TRUE)
geno_dirs_08 <- as.vector(outer(PATH_TO_08, GENO, paste, sep="/"))
lapply( geno_dirs_08, dir.create )

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
  ),  collapse = "")
  admixture_input_names <- c(admixture_input_names, temp_input)
  admixture_output_names <- c(admixture_output_names, temp_output)
}

# *** Build names for different --geno parameters

admixture_input_names_geno_08 <- c()
admixture_output_names_geno_08 <- c()
for(i in 2:cores){
  temp_input <- paste0(c(
    PATH_TO_TRIMMED,
    "/apoikia.1240K.ANCIENT.LD_200_25_08.trimmed.geno_08.bed ",
    i
  ), collapse = "")
  temp_output <- paste0(c(
    PATH_TO_OUTPUT,
    "/apoikia.1240K.LD_200_25_08.admixture.",
    i, ".geno_08.haploid.out"
  ), collapse = "")
  admixture_input_names_geno_08 <- c(admixture_input_names_geno_08, temp_input)
  admixture_output_names_geno_08 <- c(admixture_output_names_geno_08, temp_output)
}

admixture_input_names_geno_06 <- c()
admixture_output_names_geno_06 <- c()
for(i in 2:cores){
  temp_input <- paste0(c(
    PATH_TO_TRIMMED,
    "/apoikia.1240K.ANCIENT.LD_200_25_08.trimmed.geno_06.bed ",
    i
  ), collapse = "")
  temp_output <- paste0(c(
    PATH_TO_OUTPUT,
    "/apoikia.1240K.LD_200_25_08.admixture.",
    i, ".geno_06.haploid.out"
  ), collapse = "")
  admixture_input_names_geno_06 <- c(admixture_input_names_geno_06, temp_input)
  admixture_output_names_geno_06 <- c(admixture_output_names_geno_06, temp_output)
}

admixture_input_names_geno_04 <- c()
admixture_output_names_geno_04 <- c()
for(i in 2:cores){
  temp_input <- paste0(c(
    PATH_TO_TRIMMED,
    "/apoikia.1240K.ANCIENT.LD_200_25_08.trimmed.geno_04.bed ",
    i
  ), collapse = "")
  temp_output <- paste0(c(
    PATH_TO_OUTPUT,
    "/apoikia.1240K.LD_200_25_08.admixture.",
    i, ".geno_04.haploid.out"
  ), collapse = "")
  admixture_input_names_geno_04 <- c(admixture_input_names_geno_04, temp_input)
  admixture_output_names_geno_04 <- c(admixture_output_names_geno_04, temp_output)
}

# ** Runs ADMIXTURE for specific trimmings and print CV Errors

setwd(PATH_TO_08)

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
  system(cmd)
  ## print(cmd)
}
## CV Errors
for (i in 1:length(admixture_output_names)) {
  cmd <- noquote(paste0(c(
    "grep -h CV ",
    admixture_output_names[i],
    " | awk '{print $3 $4}' | sed 's/(K=\\([0-9]*\\)):\\([0-9]\\.[0-9]*\\)/\\1,\\2/g'",
    ## R needs to escape the escape character ('\') in order ot print it
    " >> CV_errors_apoikia.1240K.ANCIENT.LD_200_25_08.trimmed_maf_005.csv"
  ), collapse = ""))
  system(cmd)
}

# *** Run for different --geno parameters

setwd(geno_dirs_08[1])

foreach(i = 2:cores) %dopar% {
  cmd <- noquote(paste0(c(
    "admixture32 --cv ",
    admixture_input_names_geno_08[i-1],
    ' --haploid="*" --seed time | tee ',
    ## PATH_TO_OUTPUT,
    ## "/apoikia.1240K.LD_200_25_08.admixture.", i,
    ## ".haploid.out;"
    admixture_output_names_geno_08[i-1]
  ), collapse = ""))
  system(cmd)
  ## print(cmd)
}

## CV Errors
for (i in 1:length(admixture_output_names_geno_08)) {
  cmd <- noquote(paste0(c(
    "grep -h CV ",
    admixture_output_names_geno_08[i],
    " | awk '{print $3 $4}' | sed 's/(K=\\([0-9]*\\)):\\([0-9]\\.[0-9]*\\)/\\1,\\2/g'",
    ## R needs to escape the escape character ('\') in order ot print it
    " >> CV_errors_apoikia.1240K.ANCIENT.LD_200_25_08.geno_08.trimmed_maf_005.csv"
  ), collapse = ""))
  system(cmd)
}

setwd(geno_dirs_08[2])

foreach(i = 2:cores) %dopar% {
  cmd <- noquote(paste0(c(
    "admixture32 --cv ",
    admixture_input_names_geno_06[i-1],
    ' --haploid="*" --seed time | tee ',
    ## PATH_TO_OUTPUT,
    ## "/apoikia.1240K.LD_200_25_08.admixture.", i,
    ## ".haploid.out;"
    admixture_output_names_geno_06[i-1]
  ), collapse = ""))
  system(cmd)
  ## print(cmd)
}

## CV Errors
for (i in 1:length(admixture_output_names_geno_06)) {
  cmd <- noquote(paste0(c(
    "grep -h CV ",
    admixture_output_names_geno_06[i],
    " | awk '{print $3 $4}' | sed 's/(K=\\([0-9]*\\)):\\([0-9]\\.[0-9]*\\)/\\1,\\2/g'",
    ## R needs to escape the escape character ('\') in order ot print it
    " >> CV_errors_apoikia.1240K.ANCIENT.LD_200_25_08.geno_06.trimmed_maf_005.csv"
  ), collapse = ""))
  system(cmd)
}

setwd(geno_dirs_08[3])

foreach(i = 2:cores) %dopar% {
  cmd <- noquote(paste0(c(
    "admixture32 --cv ",
    admixture_input_names_geno_04[i-1],
    ' --haploid="*" --seed time | tee ',
    ## PATH_TO_OUTPUT,
    ## "/apoikia.1240K.LD_200_25_08.admixture.", i,
    ## ".haploid.out;"
    admixture_output_names_geno_04[i-1]
  ), collapse = ""))
  system(cmd)
  ## print(cmd)
}

## CV Errors
for (i in 1:length(admixture_output_names_geno_04)) {
  cmd <- noquote(paste0(c(
    "grep -h CV ",
    admixture_output_names_geno_04[i],
    " | awk '{print $3 $4}' | sed 's/(K=\\([0-9]*\\)):\\([0-9]\\.[0-9]*\\)/\\1,\\2/g'",
    ## R needs to escape the escape character ('\') in order ot print it
    " >> CV_errors_apoikia.1240K.ANCIENT.LD_200_25_08.geno_04.trimmed_maf_005.csv"
  ), collapse = ""))
  system(cmd)
}

# * LD 06

PATH_TO_06 <- paste0(c(PATH_TO_OUTPUT, "LD_06"), collapse = "/")
dir.create(PATH_TO_06, showWarnings = FALSE, recursive = TRUE)
geno_dirs_06 <- as.vector(outer(PATH_TO_06, GENO, paste, sep="/"))
lapply( geno_dirs_06, dir.create )

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

# *** Build names for different --geno parameters

admixture_input_names_geno_08 <- c()
admixture_output_names_geno_08 <- c()
for(i in 2:cores){
  temp_input <- paste0(c(
    PATH_TO_TRIMMED,
    "/apoikia.1240K.ANCIENT.LD_200_25_06.trimmed.geno_08.bed ",
    i
  ), collapse = "")
  temp_output <- paste0(c(
    PATH_TO_OUTPUT,
    "/apoikia.1240K.LD_200_25_06.admixture.",
    i, ".geno_08.haploid.out"
  ), collapse = "")
  admixture_input_names_geno_08 <- c(admixture_input_names_geno_08, temp_input)
  admixture_output_names_geno_08 <- c(admixture_output_names_geno_08, temp_output)
}

admixture_input_names_geno_06 <- c()
admixture_output_names_geno_06 <- c()
for(i in 2:cores){
  temp_input <- paste0(c(
    PATH_TO_TRIMMED,
    "/apoikia.1240K.ANCIENT.LD_200_25_06.trimmed.geno_06.bed ",
    i
  ), collapse = "")
  temp_output <- paste0(c(
    PATH_TO_OUTPUT,
    "/apoikia.1240K.LD_200_25_06.admixture.",
    i, ".geno_06.haploid.out"
  ), collapse = "")
  admixture_input_names_geno_06 <- c(admixture_input_names_geno_06, temp_input)
  admixture_output_names_geno_06 <- c(admixture_output_names_geno_06, temp_output)
}

admixture_input_names_geno_04 <- c()
admixture_output_names_geno_04 <- c()
for(i in 2:cores){
  temp_input <- paste0(c(
    PATH_TO_TRIMMED,
    "/apoikia.1240K.ANCIENT.LD_200_25_06.trimmed.geno_04.bed ",
    i
  ), collapse = "")
  temp_output <- paste0(c(
    PATH_TO_OUTPUT,
    "/apoikia.1240K.LD_200_25_06.admixture.",
    i, ".geno_04.haploid.out"
  ), collapse = "")
  admixture_input_names_geno_04 <- c(admixture_input_names_geno_04, temp_input)
  admixture_output_names_geno_04 <- c(admixture_output_names_geno_04, temp_output)
}

# ** Runs ADMIXTURE for specific trimmings

setwd(PATH_TO_06)

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

# *** Run for different --geno parameters

setwd(geno_dirs_06[1])

foreach(i = 2:cores) %dopar% {
  cmd <- noquote(paste0(c(
    "admixture32 --cv ",
    admixture_input_names_geno_08[i-1],
    ' --haploid="*" --seed time | tee ',
    ## PATH_TO_OUTPUT,
    ## "/apoikia.1240K.LD_200_25_08.admixture.", i,
    ## ".haploid.out;"
    admixture_output_names_geno_08[i-1]
  ), collapse = ""))
  system(cmd)
  ## print(cmd)
}

## CV Errors
for (i in 1:length(admixture_output_names_geno_08)) {
  cmd <- noquote(paste0(c(
    "grep -h CV ",
    admixture_output_names_geno_08[i],
    " | awk '{print $3 $4}' | sed 's/(K=\\([0-9]*\\)):\\([0-9]\\.[0-9]*\\)/\\1,\\2/g'",
    ## R needs to escape the escape character ('\') in order ot print it
    " >> CV_errors_apoikia.1240K.ANCIENT.LD_200_25_06.geno_08.trimmed_maf_005.csv"
  ), collapse = ""))
  system(cmd)
}

setwd(geno_dirs_06[2])

foreach(i = 2:cores) %dopar% {
  cmd <- noquote(paste0(c(
    "admixture32 --cv ",
    admixture_input_names_geno_06[i-1],
    ' --haploid="*" --seed time | tee ',
    ## PATH_TO_OUTPUT,
    ## "/apoikia.1240K.LD_200_25_08.admixture.", i,
    ## ".haploid.out;"
    admixture_output_names_geno_06[i-1]
  ), collapse = ""))
  system(cmd)
  ## print(cmd)
}

## CV Errors
for (i in 1:length(admixture_output_names_geno_06)) {
  cmd <- noquote(paste0(c(
    "grep -h CV ",
    admixture_output_names_geno_06[i],
    " | awk '{print $3 $4}' | sed 's/(K=\\([0-9]*\\)):\\([0-9]\\.[0-9]*\\)/\\1,\\2/g'",
    ## R needs to escape the escape character ('\') in order ot print it
    " >> CV_errors_apoikia.1240K.ANCIENT.LD_200_25_06.geno_06.trimmed_maf_005.csv"
  ), collapse = ""))
  system(cmd)
}

setwd(geno_dirs_06[3])

foreach(i = 2:cores) %dopar% {
  cmd <- noquote(paste0(c(
    "admixture32 --cv ",
    admixture_input_names_geno_04[i-1],
    ' --haploid="*" --seed time | tee ',
    ## PATH_TO_OUTPUT,
    ## "/apoikia.1240K.LD_200_25_08.admixture.", i,
    ## ".haploid.out;"
    admixture_output_names_geno_04[i-1]
  ), collapse = ""))
  system(cmd)
  ## print(cmd)
}

## CV Errors
for (i in 1:length(admixture_output_names_geno_04)) {
  cmd <- noquote(paste0(c(
    "grep -h CV ",
    admixture_output_names_geno_04[i],
    " | awk '{print $3 $4}' | sed 's/(K=\\([0-9]*\\)):\\([0-9]\\.[0-9]*\\)/\\1,\\2/g'",
    ## R needs to escape the escape character ('\') in order ot print it
    " >> CV_errors_apoikia.1240K.ANCIENT.LD_200_25_08.geno_04.trimmed_maf_005.csv"
  ), collapse = ""))
  system(cmd)
}

# * LD 04

PATH_TO_04 <- paste0(c(PATH_TO_OUTPUT, "LD_04"), collapse = "/")
dir.create(PATH_TO_04, showWarnings = FALSE, recursive = TRUE)
geno_dirs_04 <- as.vector(outer(PATH_TO_04, GENO, paste, sep="/"))
lapply( geno_dirs_04, dir.create )

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

# *** Build names for different --geno parameters

admixture_input_names_geno_08 <- c()
admixture_output_names_geno_08 <- c()
for(i in 2:cores){
  temp_input <- paste0(c(
    PATH_TO_TRIMMED,
    "/apoikia.1240K.ANCIENT.LD_200_25_04.trimmed.geno_08.bed ",
    i
  ), collapse = "")
  temp_output <- paste0(c(
    PATH_TO_OUTPUT,
    "/apoikia.1240K.LD_200_25_04.admixture.",
    i, ".geno_08.haploid.out"
  ), collapse = "")
  admixture_input_names_geno_08 <- c(admixture_input_names_geno_08, temp_input)
  admixture_output_names_geno_08 <- c(admixture_output_names_geno_08, temp_output)
}

admixture_input_names_geno_06 <- c()
admixture_output_names_geno_06 <- c()
for(i in 2:cores){
  temp_input <- paste0(c(
    PATH_TO_TRIMMED,
    "/apoikia.1240K.ANCIENT.LD_200_25_04.trimmed.geno_06.bed ",
    i
  ), collapse = "")
  temp_output <- paste0(c(
    PATH_TO_OUTPUT,
    "/apoikia.1240K.LD_200_25_04.admixture.",
    i, ".geno_06.haploid.out"
  ), collapse = "")
  admixture_input_names_geno_06 <- c(admixture_input_names_geno_06, temp_input)
  admixture_output_names_geno_06 <- c(admixture_output_names_geno_06, temp_output)
}

admixture_input_names_geno_04 <- c()
admixture_output_names_geno_04 <- c()
for(i in 2:cores){
  temp_input <- paste0(c(
    PATH_TO_TRIMMED,
    "/apoikia.1240K.ANCIENT.LD_200_25_04.trimmed.geno_04.bed ",
    i
  ), collapse = "")
  temp_output <- paste0(c(
    PATH_TO_OUTPUT,
    "/apoikia.1240K.LD_200_25_04.admixture.",
    i, ".geno_04.haploid.out"
  ), collapse = "")
  admixture_input_names_geno_04 <- c(admixture_input_names_geno_04, temp_input)
  admixture_output_names_geno_04 <- c(admixture_output_names_geno_04, temp_output)
}

# ** Runs ADMIXTURE for specific trimmings

setwd(PATH_TO_04)

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

# *** Run for different --geno parameters

setwd(geno_dirs_04[1])

foreach(i = 2:cores) %dopar% {
  cmd <- noquote(paste0(c(
    "admixture32 --cv ",
    admixture_input_names_geno_08[i-1],
    ' --haploid="*" --seed time | tee ',
    ## PATH_TO_OUTPUT,
    ## "/apoikia.1240K.LD_200_25_08.admixture.", i,
    ## ".haploid.out;"
    admixture_output_names_geno_08[i-1]
  ), collapse = ""))
  system(cmd)
  ## print(cmd)
}

## CV Errors
for (i in 1:length(admixture_output_names_geno_08)) {
  cmd <- noquote(paste0(c(
    "grep -h CV ",
    admixture_output_names_geno_08[i],
    " | awk '{print $3 $4}' | sed 's/(K=\\([0-9]*\\)):\\([0-9]\\.[0-9]*\\)/\\1,\\2/g'",
    ## R needs to escape the escape character ('\') in order ot print it
    " >> CV_errors_apoikia.1240K.ANCIENT.LD_200_25_06.geno_08.trimmed_maf_005.csv"
  ), collapse = ""))
  system(cmd)
}

setwd(geno_dirs_04[2])

foreach(i = 2:cores) %dopar% {
  cmd <- noquote(paste0(c(
    "admixture32 --cv ",
    admixture_input_names_geno_06[i-1],
    ' --haploid="*" --seed time | tee ',
    ## PATH_TO_OUTPUT,
    ## "/apoikia.1240K.LD_200_25_08.admixture.", i,
    ## ".haploid.out;"
    admixture_output_names_geno_06[i-1]
  ), collapse = ""))
  system(cmd)
  ## print(cmd)
}

## CV Errors
for (i in 1:length(admixture_output_names_geno_06)) {
  cmd <- noquote(paste0(c(
    "grep -h CV ",
    admixture_output_names_geno_06[i],
    " | awk '{print $3 $4}' | sed 's/(K=\\([0-9]*\\)):\\([0-9]\\.[0-9]*\\)/\\1,\\2/g'",
    ## R needs to escape the escape character ('\') in order ot print it
    " >> CV_errors_apoikia.1240K.ANCIENT.LD_200_25_04.geno_06.trimmed_maf_005.csv"
  ), collapse = ""))
  system(cmd)
}

setwd(geno_dirs_04[3])

foreach(i = 2:cores) %dopar% {
  cmd <- noquote(paste0(c(
    "admixture32 --cv ",
    admixture_input_names_geno_04[i-1],
    ' --haploid="*" --seed time | tee ',
    ## PATH_TO_OUTPUT,
    ## "/apoikia.1240K.LD_200_25_08.admixture.", i,
    ## ".haploid.out;"
    admixture_output_names_geno_04[i-1]
  ), collapse = ""))
  system(cmd)
  ## print(cmd)
}

## CV Errors
for (i in 1:length(admixture_output_names_geno_04)) {
  cmd <- noquote(paste0(c(
    "grep -h CV ",
    admixture_output_names_geno_04[i],
    " | awk '{print $3 $4}' | sed 's/(K=\\([0-9]*\\)):\\([0-9]\\.[0-9]*\\)/\\1,\\2/g'",
    ## R needs to escape the escape character ('\') in order ot print it
    " >> CV_errors_apoikia.1240K.ANCIENT.LD_200_25_04.geno_04.trimmed_maf_005.csv"
  ), collapse = ""))
  system(cmd)
}
