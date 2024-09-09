# * Libraries

## install.packages("stringr")

## library(admixr)
## install.packages("Hmisc")
library(Hmisc)
library(admixtools)
library(ggplot2)
library(stringr)
library(forcats)

# * Reading Data and preprocessing

prefix_of_data <- "/home/aggeliki/apoikia/EIGENSTRAT/dataset_04_05_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/apoikia.1240K.ANCIENT"
## yor = read_packedancestrymap("~/apoikia/EIGENSTRAT/HumanOriginsPublic2068", pops = "Yoruba")
## apoikia_dataset = read_packedancestrymap("~/apoikia/EIGENSTRAT/dataset_04_05_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/apoikia.1240K.ANCIENT")

flags <- read.table("~/apoikia/APOIKIA_Analysis/scripts_for_f4/Labels_for_f3.csv",
  sep = ",", header = T, na.strings = c("NA", "")
)

plot_folder <- "/home/aggeliki/apoikia/f3_outputs/plots/dataset_04_05_2024/non_outgroup"
results_folder <- "/home/aggeliki/apoikia/f3_outputs/f3_results/dataset_04_05_2024/non_outgroup_f3"

## Create the output directory
## dir.create("~/apoikia/f3_outputs/plots/dataset_04_05_2024/", recursive = F)


# * Function for calculation f3 scores

score_3 <- function(combination, vector_of_pops, vector_of_inds, prefix) {
  ## "combination" is a vector of 3 populations. F3 will be calculated as
  ## (combination[1]-combination[2])*(combination[1]-combination[3])
  ## "vector_of_pops" is a vector with size = sample_size that corresponds to
  ## which population each sample belongs to.
  ## "vector_of_inds" is a vector that contains the name of each sample.
  ## "prefix" should countain the prefic to an EIGESTRAT dataset
  colnames(combination) <- c("pop1", "pop2", "pop3")
  temp_pops <- vector_of_pops[vector_of_pops %in% combination]
  temp_inds <- vector_of_inds[vector_of_pops %in% combination]
  temp_f2 <- f2_from_geno(
    prefix,
    inds = temp_inds, pops = temp_pops,
    maxmiss = 0.1, adjust_pseudohaploid = TRUE
  )
  temp_snps <- count_snps(temp_f2)
  temp_f3_initial <- as.data.frame(
    f3(
      temp_f2,
      combination[1,1], combination[1,2], combination[1,3]
    )
  )
  all_snp_f3 <- cbind(temp_f3_initial, temp_snps, "Population")
  colnames(all_snp_f3) <- c(colnames(temp_f3_initial), "SNPs", "ID")
  ## print(all_snp_f3)
  ## print("End")
  return(all_snp_f3)
}

## individual_score_3 <- function(combination, vector_of_pops, vector_of_inds, prefix) {
##   colnames(combination) <- c("pop1", "pop2", "pop3")
##   temp_pops <- vector_of_pops[vector_of_pops %in% combination]
##   temp_inds <- vector_of_inds[vector_of_pops %in% combination]
##   target_indexes <- which(temp_pops %in% combination$pop2)
##   individual_f3 <- lapply(1:length(target_indexes), function(x) {
##     temp_f2 <- f2_from_geno(
##       prefix,
##       inds = temp_inds[-target_indexes[-x]], pops = temp_pops[-target_indexes[-x]],
##       maxmiss = 0.1, adjust_pseudohaploid = TRUE
##     )
##     ## print("F2")
##     temp_snps <- count_snps(temp_f2)
##     temp_f3_initial <- as.data.frame(
##       f3(
##         temp_f2,
##         combination[1,1], combination[1,2], combination[1,3]
##       )
##     )
##     ## print("F3")
##     all_snp_f3 <- cbind(temp_f3_initial, temp_snps, temp_inds[target_indexes[x]])
##     colnames(all_snp_f3) <- c(colnames(temp_f3_initial), "SNPs", "ID")
##     return(all_snp_f3)
##   })
##   return(do.call(rbind, individual_f3))
## }


# * Calculate f3s

# ** Ammotopos

target_pop <- "GRC_Ammotopos_LBA_1275-1125BCE"
other_pops <- unique(flags$Ammotopos.1275.1125BCE.)[!unique(flags$Ammotopos.1275.1125BCE.) %in% c("NO",  target_pop)]

## Take all pairwise unique combinations
temp_expand <- c()
for( i in 1:(length(other_pops)-1)){
  temp_expand <- rbind(
    temp_expand,
    expand.grid(other_pops[i], other_pops[(i+1):length(other_pops)],
                stringsAsFactors = FALSE)
  )
}

all_combinations <- cbind( rep(target_pop, nrow(temp_expand)), temp_expand)
colnames(all_combinations) <- c("Target", "Population_1", "Population_2")

f3_ammotopos <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    score_3(
      all_combinations[x, ],
      flags$Ammotopos.1275.1125BCE.,
      flags$Genetic_ID,
      prefix_of_data
    )
  }
))

# ** Archaic Amvrakia

target_pop <- "GRC_Amvrakia_Archaic_550-480BCE"
other_pops <- unique(flags$Archaic.550.480BCE.)[!unique(flags$Archaic.550.480BCE.) %in% c("NO",  target_pop)]

## Take all pairwise unique combinations
temp_expand <- c()
for( i in 1:(length(other_pops)-1)){
  temp_expand <- rbind(
    temp_expand,
    expand.grid(other_pops[i], other_pops[(i+1):length(other_pops)],
                stringsAsFactors = FALSE)
  )
}

all_combinations <- cbind( rep(target_pop, nrow(temp_expand)), temp_expand)
colnames(all_combinations) <- c("Target", "Population_1", "Population_2")

f3_amvrakia_archaic <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    score_3(
      all_combinations[x, ],
      flags$Archaic.550.480BCE.,
      flags$Genetic_ID,
      prefix_of_data
    )
  }
))

# ** Archaic Tenea

target_pop <- "GRC_Tenea_Archaic_550-480BCE"
other_pops <- unique(flags$Archaic.550.480BCE.)[!unique(flags$Archaic.550.480BCE.) %in% c("NO",  target_pop)]

## Take all pairwise unique combinations
temp_expand <- c()
for( i in 1:(length(other_pops)-1)){
  temp_expand <- rbind(
    temp_expand,
    expand.grid(other_pops[i], other_pops[(i+1):length(other_pops)],
                stringsAsFactors = FALSE)
  )
}

all_combinations <- cbind( rep(target_pop, nrow(temp_expand)), temp_expand)
colnames(all_combinations) <- c("Target", "Population_1", "Population_2")

f3_tenea_archaic <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    score_3(
      all_combinations[x, ],
      flags$Archaic.550.480BCE.,
      flags$Genetic_ID,
      prefix_of_data
    )
  }
))

# ** Classical Amvrakia

target_pop <- "GRC_Amvrakia_Classical_475-325BCE"
other_pops <- unique(flags$Classical.475.325BCE.)[!unique(flags$Classical.475.325BCE.) %in% c("NO",  target_pop)]

## Take all pairwise unique combinations
temp_expand <- c()
for( i in 1:(length(other_pops)-1)){
  temp_expand <- rbind(
    temp_expand,
    expand.grid(other_pops[i], other_pops[(i+1):length(other_pops)],
                stringsAsFactors = FALSE)
  )
}

all_combinations <- cbind( rep(target_pop, nrow(temp_expand)), temp_expand)
colnames(all_combinations) <- c("Target", "Population_1", "Population_2")

f3_amvrakia_classical <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    score_3(
      all_combinations[x, ],
      flags$Classical.475.325BCE.,
      flags$Genetic_ID,
      prefix_of_data
    )
  }
))

# ** Hellenistic Amvrakia

target_pop <- "GRC_Amvrakia_Hellenistic_325-100BCE"
other_pops <- unique(flags$Hellenistic.325.100BCE.)[!unique(flags$Hellenistic.325.100BCE.) %in% c("NO",  target_pop)]

## Take all pairwise unique combinations
temp_expand <- c()
for( i in 1:(length(other_pops)-1)){
  temp_expand <- rbind(
    temp_expand,
    expand.grid(other_pops[i], other_pops[(i+1):length(other_pops)],
                stringsAsFactors = FALSE)
  )
}

all_combinations <- cbind( rep(target_pop, nrow(temp_expand)), temp_expand)
colnames(all_combinations) <- c("Target", "Population_1", "Population_2")

f3_amvrakia_hellenistic <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    score_3(
      all_combinations[x, ],
      flags$Hellenistic.325.100BCE.,
      flags$Genetic_ID,
      prefix_of_data
    )
  }
))

# ** Hellenistic Tenea

target_pop <- "GRC_Tenea_Hellenistic_150-100BCE"
other_pops <- unique(flags$Hellenistic.325.100BCE.)[!unique(flags$Hellenistic.325.100BCE.) %in% c("NO",  target_pop)]

## Take all pairwise unique combinations
temp_expand <- c()
for( i in 1:(length(other_pops)-1)){
  temp_expand <- rbind(
    temp_expand,
    expand.grid(other_pops[i], other_pops[(i+1):length(other_pops)],
                stringsAsFactors = FALSE)
  )
}

all_combinations <- cbind( rep(target_pop, nrow(temp_expand)), temp_expand)
colnames(all_combinations) <- c("Target", "Population_1", "Population_2")

f3_tenea_hellenistic <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    score_3(
      all_combinations[x, ],
      flags$Hellenistic.325.100BCE.,
      flags$Genetic_ID,
      prefix_of_data
    )
  }
))

# ** Tenea Early Roman

target_pop <- "GRC_Tenea_LHellenistic_ERoman_100BCE-100CE"
other_pops <- unique(flags$Roman.31BCE.330CE.)[!unique(flags$Roman.31BCE.330CE.) %in% c("NO",  target_pop)]

## Take all pairwise unique combinations
temp_expand <- c()
for( i in 1:(length(other_pops)-1)){
  temp_expand <- rbind(
    temp_expand,
    expand.grid(other_pops[i], other_pops[(i+1):length(other_pops)],
                stringsAsFactors = FALSE)
  )
}

all_combinations <- cbind( rep(target_pop, nrow(temp_expand)), temp_expand)
colnames(all_combinations) <- c("Target", "Population_1", "Population_2")

f3_tenea_early_roman <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    score_3(
      all_combinations[x, ],
      flags$Roman.31BCE.330CE.,
      flags$Genetic_ID,
      prefix_of_data
    )
  }
))

# ** Tenea Roman

target_pop <- "GRC_Tenea_Roman_31BCE-330CE"
other_pops <- unique(flags$Roman.31BCE.330CE.)[!unique(flags$Roman.31BCE.330CE.) %in% c("NO",  target_pop)]

## Take all pairwise unique combinations
temp_expand <- c()
for( i in 1:(length(other_pops)-1)){
  temp_expand <- rbind(
    temp_expand,
    expand.grid(other_pops[i], other_pops[(i+1):length(other_pops)],
                stringsAsFactors = FALSE)
  )
}

all_combinations <- cbind( rep(target_pop, nrow(temp_expand)), temp_expand)
colnames(all_combinations) <- c("Target", "Population_1", "Population_2")

f3_tenea_roman <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    score_3(
      all_combinations[x, ],
      flags$Roman.31BCE.330CE.,
      flags$Genetic_ID,
      prefix_of_data
    )
  }
))

# ** Saving data

save_statistics <- function(f3_output, file_name) {
  write.table(f3_output, file_name, quote = FALSE, sep = '\t', row.names = FALSE)
}q

save_statistics(
  f3_ammotopos,
  paste0( c(results_folder, "f3_ammotopos.tsv"), collapse = '/' )
)
save_statistics(
  f3_amvrakia_archaic,
  paste0( c( results_folder, "f3_amv_archaic.tsv"), collapse = '/')
)
save_statistics(
  f3_tenea_roman,
  paste0( c( results_folder, "f3_tenea_roman.tsv"), collapse = '/' )
)
save_statistics(
  f3_tenea_archaic,
  paste0( c( results_folder, "f3_tenea_archaic.tsv"), collapse = '/' )
)
save_statistics(
  f3_tenea_early_roman,
  paste0( c( results_folder, "f3_tenea_early_roman.tsv"), collapse = '/' )
)
save_statistics(
  f3_amvrakia_classical,
  paste0( c( results_folder, "f3_amv_classical.tsv"), collapse = '/' )
)
save_statistics(
  f3_amvrakia_hellenistic,
  paste0( c( results_folder, "f3_amv_hellenistic.tsv"), collapse = '/' )
)
save_statistics(
  f3_tenea_hellenistic,
  paste0( c( results_folder, "f3_tenea_hellenistic.tsv"), collapse = '/' )
)

# * Plots

# ** Function for plotting

heatmap_for_f3 <- function(f3_results){

  f3_results$pop2 <- fct_infreq(f3_results$pop2)
  f3_results$pop3 <- fct_rev(fct_infreq(f3_results$pop3))
  heat_plot <- ggplot(data = f3_results, aes(x = pop2, y = pop3, fill = est))
  heat_plot <- heat_plot + geom_tile()
  heat_plot <- heat_plot + labs(
    title = "F3 test for Most Proximate Sources",
    subtitle = f3_results[1,1],
    fill = "F3"
  )
  heat_plot <- heat_plot + theme(
    axis.title = element_blank(),
    axis.text = element_text( size = 16 ),
    title = element_text( size = 22 ),
    legend.title = element_text( size = 18 )
  )
  heat_plot <- heat_plot + guides(x = guide_axis(angle = 60))
  heat_plot <- heat_plot + scale_y_discrete(
    name = element_blank(),
    labels = function(x) {
      sub("_([0-9]+[a-z|A-Z]*[-|_][0-9]+)", "\n\\1", x, fixed = FALSE)
    }
  )
  heat_plot <- heat_plot + scale_x_discrete(
    name = element_blank(),
    labels = function(x) {
      sub("_([0-9]+[a-z|A-Z]*[-|_][0-9]+)", "\n\\1", x, fixed = FALSE)
    }
  )
  heat_plot <- heat_plot + scale_fill_gradient2(
    low = 'lightslategrey',
    mid = 'white',
    high = 'dodgerblue3',
    midpoint = 0)
  return(heat_plot)
}

# ** All plots

## f3_ammotopos <- read.table(
##   paste0( c(results_folder, "f3_ammotopos.tsv"), collapse = '/' ),
##   sep = '\t', header = T
## )

## f3_amv_archaic <- read.table(
##   paste0( c(results_folder, "f3_amv_archaic.tsv"), collapse = '/' ),
##   sep = '\t', header = T
## )

## f3_amvrakia_classical <- read.table(
##   paste0( c(results_folder, "f3_amv_classical.tsv"), collapse = '/' ),
##   sep = '\t', header = T
## )

## f3_amvrakia_hellenistic <- read.table(
##   paste0( c(results_folder, "f3_amv_hellenistic.tsv"), collapse = '/' ),
##   sep = '\t', header = T
## )

## f3_tenea_archaic <- read.table(
##   paste0( c(results_folder, "f3_tenea_archaic.tsv"), collapse = '/' ),
##   sep = '\t', header = T
## )

## f3_tenea_hellenistic <- read.table(
##   paste0( c(results_folder, "f3_tenea_hellenistic.tsv"), collapse = '/' ),
##   sep = '\t', header = T
## )

## f3_tenea_early_roman <- read.table(
##   paste0( c(results_folder, "f3_tenea_early_roman.tsv"), collapse = '/' ),
##   sep = '\t', header = T
## )

## f3_tenea_roman <- read.table(
##   paste0( c(results_folder, "f3_tenea_roman.tsv"), collapse = '/' ),
##   sep = '\t', header = T
## )

plot_ammotopos <- heatmap_for_f3(f3_ammotopos)
plot_amv_archaic <- heatmap_for_f3(f3_amvrakia_archaic)
plot_tenea_archaic <- heatmap_for_f3(f3_tenea_archaic)
plot_amv_classical <- heatmap_for_f3(f3_amvrakia_classical)
plot_amv_hellenistic <- heatmap_for_f3(f3_amvrakia_hellenistic)
plot_tenea_hellenistic <- heatmap_for_f3(f3_tenea_hellenistic)
plot_tenea_early_roman <- heatmap_for_f3(f3_tenea_early_roman)
plot_tenea_roman <- heatmap_for_f3(f3_tenea_roman)

# ** Save plots to files

png(paste0( c( plot_folder, "f3_ammotopos_non_outgroup.png" ), collapse = '/'), height = 1240, width = 1240)
plot_ammotopos
dev.off()

png(paste0( c( plot_folder, "f3_amv_arch_non_outgroup.png" ), collapse = '/'), height = 1240, width = 1240)
plot_amv_archaic
dev.off()

png(paste0( c( plot_folder, "f3_tenea_arch_non_outgroup.png" ), collapse = '/'), height = 1240, width = 1240)
plot_tenea_archaic
dev.off()

png(paste0( c( plot_folder, "f3_amv_class_non_outgroup.png" ), collapse = '/'), height = 1240, width = 1240)
plot_amv_classical
dev.off()

png(paste0( c( plot_folder, "f3_amv_hel_non_outgroup.png" ), collapse = '/'), height = 1240, width = 1240)
plot_amv_hellenistic
dev.off()

png(paste0( c( plot_folder, "f3_tenea_hel_non_outgroup.png" ), collapse = '/'), height = 1240, width = 1240)
plot_tenea_hellenistic
dev.off()

png(paste0( c( plot_folder, "f3_tenea_early_roman_non_outgroup.png" ), collapse = '/'), height = 1240, width = 1240)
plot_tenea_early_roman
dev.off()

png(paste0( c( plot_folder, "f3_tenea_roman_non_outgroup.png" ), collapse = '/'), height = 1240, width = 1240)
plot_tenea_roman
dev.off()

