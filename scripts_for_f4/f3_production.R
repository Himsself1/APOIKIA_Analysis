# * Libraries

## install.packages("stringr")

library(admixr)
## install.packages("Hmisc")
library(Hmisc)
library(admixtools)
library(ggplot2)
library("stringr")

# * Reading Data and preprocessing

yor = read_packedancestrymap("~/apoikia/EIGENSTRAT/HumanOriginsPublic2068", pops = "Yoruba")
apoikia_dataset = read_packedancestrymap("~/apoikia/EIGENSTRAT/new_dataset_01_02_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/apoikia_with_yoruba")

individuals_to_ignore <- read.table("~/apoikia/APOIKIA_Analysis/admixture_analysis/remove_these_IDS_from_eigenstrat.txt",
                                    sep = '\t', header = F, colClasses = 'character')
indexes_to_ignore <- which(apoikia_dataset$ind[[1]] %in% individuals_to_ignore)

flags <- read.table("~/apoikia/APOIKIA_Analysis/scripts_for_f4/Labels_for_f3.tsv",
  sep = "\t", header = T, na.strings = c("NA", "")
)

# * Function for calculation f3 scores

score_3 <- function( combination, vector_of_pops, vector_of_inds, prefix ){
  ## "combination" is a vector of 3 populations. F3 will be calculated as
  ## (combination[1]-combination[2])*(combination[1]-combination[3])
  ## "vector_of_pops" is a vector with size = sample_size that corresponds to
  ## which population each sample belongs to.
  ## "vector_of_inds" is a vector that contains the name of each sample.
  ## "prefix" should countain the prefic to an EIGESTRAT dataset
  colnames(combination) <- c( "pop1", "pop2", "pop3" )
  temp_pops <- vector_of_pops[vector_of_pops %in% combination]
  temp_inds <- vector_of_inds[vector_of_pops %in% combination]
  temp_f2 <- f2_from_geno(
    prefix, inds = temp_inds, pops = temp_pops,
    maxmiss = 0.1, adjust_pseudohaploid = TRUE
  )
  temp_snps <- count_snps(temp_f2)
  temp_f3_initial <- as.data.frame(
    f3(
      temp_f2,
      combination[1], combination[2], combination[3]
    )
  )
  all_snp_f3 <- cbind( temp_f3_initial, temp_snps, "Population" )
  colnames(all_snp_f3) <- c(colnames(temp_f3_initial),"SNPs", "ID")
  ## print(all_snp_f3)
  ## print("End")
  return( all_snp_f3 )
}

individual_score_3 <- function(combination, vector_of_pops, vector_of_inds, prefix) {
  colnames(combination) <- c( "pop1", "pop2", "pop3" )
  temp_pops <- vector_of_pops[vector_of_pops %in% combination]
  temp_inds <- vector_of_inds[vector_of_pops %in% combination]
  target_indexes <- which(temp_pops %in% combination$pop2)
  individual_f3 <- lapply(1:length(target_indexes), function(x) {
    temp_f2 <- f2_from_geno(
      prefix,
      inds = temp_inds[-target_indexes[-x]], pops = temp_pops[-target_indexes[-x]],
      maxmiss = 0.1, adjust_pseudohaploid = TRUE
    )
    ## print("F2")
    temp_snps <- count_snps(temp_f2)
    temp_f3_initial <- as.data.frame(
      f3(
        temp_f2,
        combination[1], combination[2], combination[3]
      )
    )
    ## print("F3")
    all_snp_f3 <- cbind(temp_f3_initial, temp_snps, temp_inds[target_indexes[x]])
    colnames(all_snp_f3) <- c(colnames(temp_f3_initial), "SNPs", "ID")
    return(all_snp_f3)
  })
  return(do.call(rbind, individual_f3))}


# * Calculate f3s

# ** Ammotopos

pop1 <- "Yoruba"
pop2 <- "GRC_Ammotopos_LBA_1275-1125BCE"
## pop3 needs to not include ammotopos and NO populations
pop3 <- grep("NO|Ammotopos*", unique(flags$Ammotopos.1275.1125BCE.), value = TRUE, invert = TRUE)
all_combinations <- expand.grid( "pop1" = pop1, "pop2" = pop2, "pop3" = pop3,
                                stringsAsFactors = F )

new_pops_ammotopos <- c() ## Population Names need to be corrected
for (i in 1:length(apoikia_dataset$ind[[1]])) {
  if (apoikia_dataset$ind[[1]][i] %in% flags$Genetic_ID) {
    temp_index <- which( flags$Genetic_ID %in% apoikia_dataset$ind[[1]][i] )
    new_pops_ammotopos <- c(new_pops_ammotopos, flags$Ammotopos.1275.1125BCE.[temp_index])
  } else {
    new_pops_ammotopos <- c(new_pops_ammotopos, apoikia_dataset$ind[[3]][i])
  }
}

f3_ammotopos <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    score_3(
      all_combinations[x, ],
      new_pops_ammotopos[-indexes_to_ignore],
      apoikia_dataset$ind[[1]][-indexes_to_ignore],
      "~/apoikia/EIGENSTRAT/new_dataset_01_02_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/apoikia_with_yoruba"
    )
  }
))

ind_f3_ammotopos <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    individual_score_3(
      all_combinations[x, ],
      new_pops_ammotopos[-indexes_to_ignore],
      apoikia_dataset$ind[[1]][-indexes_to_ignore],
      "~/apoikia/EIGENSTRAT/new_dataset_01_02_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/apoikia_with_yoruba"
    )
  }
))
all_ammotopos <- rbind(f3_ammotopos, ind_f3_ammotopos)

# ** Archaic Amvrakia

pop1 <- "Yoruba"
pop2 <- "GRC_Amvrakia_Archaic_550-480BCE"
## pop3 needs to not include ammotopos and NO populations
pop3 <- grep("NO|Avrakia_Archaic*", unique(flags$Archaic.550.480BCE.), value = TRUE, invert = TRUE)
all_combinations <- expand.grid( "pop1" = pop1, "pop2" = pop2, "pop3" = pop3,
                                stringsAsFactors = F )

new_pops_arch <- c() ## Population Names need to be corrected
for (i in 1:length(apoikia_dataset$ind[[1]])) {
  if (apoikia_dataset$ind[[1]][i] %in% flags$Genetic_ID) {
    temp_index <- which( flags$Genetic_ID %in% apoikia_dataset$ind[[1]][i] )
    new_pops_arch <- c(new_pops_arch, flags$Archaic.550.480BCE.[temp_index])
  } else {
    new_pops_arch <- c(new_pops_arch, apoikia_dataset$ind[[3]][i])
  }
}

f3_amv_archaic <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    score_3(
      all_combinations[x, ],
      new_pops_arch[-indexes_to_ignore],
      apoikia_dataset$ind[[1]][-indexes_to_ignore],
      "~/apoikia/EIGENSTRAT/new_dataset_01_02_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/apoikia_with_yoruba"
    )
  }
))

ind_f3_amv_archaic <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    individual_score_3(
      all_combinations[x, ],
      new_pops_arch[-indexes_to_ignore],
      apoikia_dataset$ind[[1]][-indexes_to_ignore],
      "~/apoikia/EIGENSTRAT/new_dataset_01_02_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/apoikia_with_yoruba"
    )
  }
))
all_amv_archaic <- rbind(f3_amv_archaic, ind_f3_amv_archaic)

# ** Archaic Tenea

pop1 <- "Yoruba"
pop2 <- "GRC_Tenea_Archaic_550-480BCE"
## pop3 needs to not include ammotopos and NO populations
pop3 <- grep("NO|Tenea_Archaic*", unique(flags$Archaic.550.480BCE.), value = TRUE, invert = TRUE)
all_combinations <- expand.grid( "pop1" = pop1, "pop2" = pop2, "pop3" = pop3,
                                stringsAsFactors = F )

f3_tenea_archaic <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    score_3(
      all_combinations[x, ],
      new_pops_arch[-indexes_to_ignore],
      apoikia_dataset$ind[[1]][-indexes_to_ignore],
      "~/apoikia/EIGENSTRAT/new_dataset_01_02_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/apoikia_with_yoruba"
    )
  }
))

## Only one individual is labeled as Tenea Archaic
## ind_f3_tenea_archaic <- do.call(rbind, lapply(
##   1:nrow(all_combinations),
##   function(x) {
##     individual_score_3(
##       all_combinations[x, ],
##       new_pops_arch[-indexes_to_ignore],
##       apoikia_dataset$ind[[1]][-indexes_to_ignore],
##       "~/apoikia/EIGENSTRAT/new_dataset_01_02_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/apoikia_with_yoruba"
##     )
##   }
## ))



# ** Classical Amvrakia

pop1 <- "Yoruba"
pop2 <- "GRC_Amvrakia_Classical_475-325BCE"
## pop3 needs to not include ammotopos and NO populations
pop3 <- grep("NO|Amvrakia_Classical*", unique(flags$Classical.475.325BCE.), value = TRUE, invert = TRUE)
all_combinations <- expand.grid( "pop1" = pop1, "pop2" = pop2, "pop3" = pop3,
                                stringsAsFactors = F )

new_pops_class <- c() ## Population Names need to be corrected
for (i in 1:length(apoikia_dataset$ind[[1]])) {
  if (apoikia_dataset$ind[[1]][i] %in% flags$Genetic_ID) {
    temp_index <- which( flags$Genetic_ID %in% apoikia_dataset$ind[[1]][i] )
    new_pops_class <- c(new_pops_class, flags$Classical.475.325BCE.[temp_index])
  } else {
    new_pops_class <- c(new_pops_class, apoikia_dataset$ind[[3]][i])
  }
}

f3_amvrakia_classical <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    score_3(
      all_combinations[x, ],
      new_pops_class[-indexes_to_ignore],
      apoikia_dataset$ind[[1]][-indexes_to_ignore],
      "~/apoikia/EIGENSTRAT/new_dataset_01_02_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/apoikia_with_yoruba"
    )
  }
))

ind_f3_amvrakia_classical <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    individual_score_3(
      all_combinations[x, ],
      new_pops_class[-indexes_to_ignore],
      apoikia_dataset$ind[[1]][-indexes_to_ignore],
      "~/apoikia/EIGENSTRAT/new_dataset_01_02_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/apoikia_with_yoruba"
    )
  }
))
all_amvrakia_classical <- rbind(f3_amvrakia_classical, ind_f3_amvrakia_classical)

# ** Hellenistic 

pop1 <- "Yoruba"
pop2 <- "GRC_Amvrakia_Hellenistic_325-100BCE"
## pop3 needs to not include ammotopos and NO populations
pop3 <- grep("NO|Amvrakia_Hellenistic*", unique(flags$Hellenistic.325.100BCE.), value = TRUE, invert = TRUE)
all_combinations <- expand.grid( "pop1" = pop1, "pop2" = pop2, "pop3" = pop3,
                                stringsAsFactors = F )

new_pops_hel <- c() ## Population Names need to be corrected
for (i in 1:length(apoikia_dataset$ind[[1]])) {
  if (apoikia_dataset$ind[[1]][i] %in% flags$Genetic_ID) {
    temp_index <- which( flags$Genetic_ID %in% apoikia_dataset$ind[[1]][i] )
    new_pops_hel <- c(new_pops_hel, flags$Hellenistic.325.100BCE.[temp_index])
  } else {
    new_pops_hel <- c(new_pops_hel, apoikia_dataset$ind[[3]][i])
  }
}

f3_amvrakia_hellenistic <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    score_3(
      all_combinations[x, ],
      new_pops_hel[-indexes_to_ignore],
      apoikia_dataset$ind[[1]][-indexes_to_ignore],
      "~/apoikia/EIGENSTRAT/new_dataset_01_02_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/apoikia_with_yoruba"
    )
  }
))

ind_f3_amvrakia_hellenistic <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    individual_score_3(
      all_combinations[x, ],
      new_pops_hel[-indexes_to_ignore],
      apoikia_dataset$ind[[1]][-indexes_to_ignore],
      "~/apoikia/EIGENSTRAT/new_dataset_01_02_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/apoikia_with_yoruba"
    )
  }
))
all_amvrakia_hellenistic <- rbind(f3_amvrakia_hellenistic, ind_f3_amvrakia_hellenistic)

# ** Tenea Early Roman

## This individual's name was changed in labels file
flags[203, 1] <- "Ten_Pel_EarlyRom"

pop1 <- "Yoruba"
pop2 <- "GRC_Tenea_LHellenistic_ERoman_100BCE-100CE"
## pop3 needs to not include ammotopos and NO populations
pop3 <- grep("NO|Tenea_LHellenistic*", unique(flags$Roman.31BCE.330CE.), value = TRUE, invert = TRUE)
all_combinations <- expand.grid( "pop1" = pop1, "pop2" = pop2, "pop3" = pop3,
                                stringsAsFactors = F )

new_pops_rom <- c() ## Population Names need to be corrected
for (i in 1:length(apoikia_dataset$ind[[1]])) {
  if (apoikia_dataset$ind[[1]][i] %in% flags$Genetic_ID) {
    temp_index <- which( flags$Genetic_ID %in% apoikia_dataset$ind[[1]][i] )
    new_pops_rom <- c(new_pops_rom, flags$Roman.31BCE.330CE.[temp_index])
  } else {
    new_pops_rom <- c(new_pops_rom, apoikia_dataset$ind[[3]][i])
  }
}

f3_tenea_early_roman <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    temp <- score_3(
      all_combinations[x, ],
      new_pops_rom[-indexes_to_ignore],
      apoikia_dataset$ind[[1]][-indexes_to_ignore],
      "~/apoikia/EIGENSTRAT/new_dataset_01_02_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/apoikia_with_yoruba"
    )    
  }
))

## Only one individual is labeled as tenea early roman
## ind_f3_tenea_early_roman <- do.call(rbind, lapply(
##   1:nrow(all_combinations),
##   function(x) {
##     temp <- individual_score_3(
##       all_combinations[x, ],
##       new_pops_rom[-indexes_to_ignore],
##       apoikia_dataset$ind[[1]][-indexes_to_ignore],
##       "~/apoikia/EIGENSTRAT/new_dataset_01_02_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/apoikia_with_yoruba"
##     )    
##   }
## ))

# ** Tenea Roman

pop1 <- "Yoruba"
pop2 <- "GRC_Tenea_Roman_31BCE-330CE"
## pop3 needs to not include ammotopos and NO populations
pop3 <- grep("NO|Tenea_Roman*", unique(flags$Roman.31BCE.330CE.), value = TRUE, invert = TRUE)
all_combinations <- expand.grid( "pop1" = pop1, "pop2" = pop2, "pop3" = pop3,
                                stringsAsFactors = F )

f3_tenea_roman <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    score_3(
      all_combinations[x, ],
      new_pops_rom[-indexes_to_ignore],
      apoikia_dataset$ind[[1]][-indexes_to_ignore],
      "~/apoikia/EIGENSTRAT/new_dataset_01_02_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/apoikia_with_yoruba"
    )
  }
))

ind_f3_tenea_roman <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    individual_score_3(
      all_combinations[x, ],
      new_pops_rom[-indexes_to_ignore],
      apoikia_dataset$ind[[1]][-indexes_to_ignore],
      "~/apoikia/EIGENSTRAT/new_dataset_01_02_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/apoikia_with_yoruba"
    )
  }
))
all_tenea_roman <- rbind(f3_tenea_roman, ind_f3_tenea_roman)

# ** Saving data

save_statistics <- function(f3_output, file_name) {
  ## Somehow sapply saves lists in a matrix format. Need to make it a data.frame
  ## f3_output_2 <- data.frame(
  ##   pop1 = unlist(f3_output[, 1]),
  ##   pop2 = unlist(f3_output[, 2]),
  ##   pop3 = factor(unlist(f3_output[, 3]),
  ##                 levels = unlist(f3_output[, 3])[order(unlist(f3_output[, 4]))]
  ##                 ),
  ##   est = unlist(f3_output[, 4]),
  ##   se = unlist(f3_output[, 5]),
  ##   z = unlist(f3_output[, 6]),
  ##   p = unlist(f3_output[, 7]),
  ##   SNPs = unlist(f3_output[, 8])
  ## )
  write.table(f3_output, file_name, quote = FALSE, sep = '\t', row.names = FALSE)
}

save_statistics(f3_ammotopos, "~/apoikia/f3_outputs/f3_results/f3_ammotopos.tsv")
save_statistics(f3_amv_archaic, "~/apoikia/f3_outputs/f3_results/f3_amv_archaic.tsv")
save_statistics(f3_tenea_roman, "~/apoikia/f3_outputs/f3_results/f3_tenea_roman.tsv")
save_statistics(f3_tenea_archaic, "~/apoikia/f3_outputs/f3_results/f3_tenea_archaic.tsv")
save_statistics(f3_tenea_early_roman, "~/apoikia/f3_outputs/f3_results/f3_tenea_early_roman.tsv")
save_statistics(f3_amvrakia_classical, "~/apoikia/f3_outputs/f3_results/f3_amv_classical.tsv")
save_statistics(f3_amvrakia_hellenistic, "~/apoikia/f3_outputs/f3_results/f3_amv_hellenistic.tsv")

save_statistics(ind_f3_ammotopos, "~/apoikia/f3_outputs/f3_results/ind_f3_ammotopos.tsv")
save_statistics(ind_f3_amv_archaic, "~/apoikia/f3_outputs/f3_results/ind_f3_amv_archaic.tsv")
save_statistics(ind_f3_tenea_roman, "~/apoikia/f3_outputs/f3_results/ind_f3_tenea_roman.tsv")
save_statistics(ind_f3_amvrakia_classical, "~/apoikia/f3_outputs/f3_results/ind_f3_amv_classical.tsv")
save_statistics(ind_f3_amvrakia_hellenistic, "~/apoikia/f3_outputs/f3_results/ind_f3_amv_hellenistic.tsv")

# * Plots

# ** Function for plotting

plot_general <- function(f3_output) {
  f3_output_2 <- f3_output[!(f3_output$pop2 == f3_output$pop3), ]
  f3_output_2$pop3 <- reorder(f3_output_2$pop3, f3_output_2$est, mean)
  to_plot <- ggplot(f3_output_2, aes(x = est, y = pop3)) +
    geom_point() +
    geom_errorbar(aes(xmin = est - se, xmax = est + se), size = 0.4, width = 0.4) +
    labs(title = paste0(f3_output_2$pop2[1])) +
    theme(
      legend.position = "none",
      title = element_text(size = 20, hjust = 0.5),
      axis.text.y = element_text(size = 16)
    ) +
    scale_y_discrete(
      labels = function(x) {
        sub("_([0-9]+[a-z|A-Z]*[-|_][0-9]+)", "\n\\1", x, fixed = FALSE)
      }
    )
  return(to_plot)
}

plot_general_with_inds <- function(f3_output) {
  f3_output_2 <- f3_output[!(f3_output$pop2 == f3_output$pop3), ]
  ## reorder factor levels in order to be plotted nicely
  temp_reordered <- reorder(f3_output_2$pop3[f3_output_2$ID == "Population"],
    f3_output_2$est[f3_output_2$ID == "Population"],
    mean,
    decreasing = FALSE
  )
  f3_output_2$pop3 <- factor(f3_output_2$pop3,
    levels = levels(temp_reordered), ordered = TRUE
  )
  ## Make population point have different alpha and color
  pop_indexes <- f3_output_2$ID == "Population"
  alpha <- rep(3, nrow(f3_output_2))
  alpha[!pop_indexes] <- 0.4
  col_and_fill <- rep("black", nrow(f3_output_2))
  col_and_fill[pop_indexes] <- "red"
  point_size <- rep(2.4, nrow(f3_output_2))
  point_size[!pop_indexes] <- 1
  f3_output_2$col_and_fill <- col_and_fill
  f3_output_2$point_size <- point_size
  ########################################################
  to_plot <- ggplot(f3_output_2, aes(
    x = est, y = pop3, group = ID,
    color = col_and_fill, fill = col_and_fill
  )) +
    geom_point(size = point_size, position = position_dodge(width = 0.3)) +
    geom_errorbar(aes(xmin = est - se, xmax = est + se),
      position = position_dodge(width = 0.3),
      size = 0.4, width = 0.4, alpha = alpha
    ) +
    labs(title = paste0(f3_output_2$pop2[1])) +
    theme(
      legend.position = "none",
      title = element_text(size = 20, hjust = 0.5),
      axis.text.y = element_text(size = 16)
    ) +
    scale_y_discrete(
      labels = function(x) {
        sub("_([0-9]+[a-z|A-Z]*[-|_][0-9]+)", "\n\\1", x, fixed = FALSE)
      }
    ) +
    scale_fill_manual(values = c("black" = "black", "red" = "red")) +
    scale_color_manual(values = c("black" = "black", "red" = "red"))
  return(to_plot)
}

# ** All plots

plot_ammotopos <- plot_general(f3_ammotopos)
plot_amv_archaic <- plot_general(f3_amv_archaic)
plot_tenea_archaic <- plot_general(f3_tenea_archaic)
plot_amv_classical <- plot_general(f3_amvrakia_classical)
plot_amv_hellenistic <- plot_general(f3_amvrakia_hellenistic)
plot_tenea_early_roman <- plot_general(f3_tenea_early_roman)
plot_tenea_roman <- plot_general(f3_tenea_roman)

inds_plot_ammotopos <- plot_general_with_inds(all_ammotopos)
inds_plot_amv_archaic <- plot_general_with_inds(all_amv_archaic)
inds_plot_amv_classical <- plot_general_with_inds(all_amvrakia_classical)
inds_plot_amv_hellenistic <- plot_general_with_inds(all_amvrakia_hellenistic)
inds_plot_tenea_roman <- plot_general_with_inds(all_tenea_roman)

# ** Save plots to files

# *** Population Plots

png("~/apoikia/f3_outputs/plots/f3_ammotopos.png", height = 1024, width = 860)
plot_ammotopos
dev.off()

png("~/apoikia/f3_outputs/plots/f3_amv_arch.png", height = 1024, width = 860)
plot_amv_archaic
dev.off()

png("~/apoikia/f3_outputs/plots/f3_tenea_arch.png", height = 1024, width = 860)
plot_tenea_archaic
dev.off()

png("~/apoikia/f3_outputs/plots/f3_amv_class.png", height = 1024, width = 860)
plot_amv_classical
dev.off()

png("~/apoikia/f3_outputs/plots/f3_amv_hel.png", height = 1024, width = 860)
plot_amv_hellenistic
dev.off()

png("~/apoikia/f3_outputs/plots/f3_tenea_early_roman.png", height = 1024, width = 860)
plot_tenea_early_roman
dev.off()

png("~/apoikia/f3_outputs/plots/f3_tenea_roman.png", height = 1024, width = 860)
plot_tenea_roman
dev.off()

# *** Individual + Population Plots

png("~/apoikia/f3_outputs/plots/f3_ammotopos_with_indiduals.png", height = 1024, width = 1080)
inds_plot_ammotopos
dev.off()

png("~/apoikia/f3_outputs/plots/f3_amv_arch_with_indiduals.png", height = 1024, width = 1080)
inds_plot_amv_archaic
dev.off()

png("~/apoikia/f3_outputs/plots/f3_amv_class_with_indiduals.png", height = 1024, width = 1080)
inds_plot_amv_classical
dev.off()

png("~/apoikia/f3_outputs/plots/f3_amv_hel_with_indiduals.png", height = 1024, width = 1080)
inds_plot_amv_hellenistic
dev.off()

png("~/apoikia/f3_outputs/plots/f3_tenea_roman_with_indiduals.png", height = 1024, width = 1080)
inds_plot_tenea_roman
dev.off()
