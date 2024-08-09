# * Libraries

## install.packages("stringr")
## library(admixr)
## install.packages("Hmisc")
library(Hmisc)
library(admixtools)
library(ggplot2)
library(stringr)
 
# * Reading Data and preprocessing

data_prefix <- "~/apoikia/EIGENSTRAT/dataset_04_05_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/apoikia_with_yoruba"

yor = read_packedancestrymap(
  "~/apoikia/EIGENSTRAT/dataset_04_05_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/apoikia_with_yoruba",
  pops = "Yoruba")

han = read_packedancestrymap(
  "~/apoikia/EIGENSTRAT/dataset_04_05_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/apoikia_with_yoruba",
  pops = "Han")
## apoikia_dataset = read_packedancestrymap("~/apoikia/EIGENSTRAT/dataset_04_05_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/apoikia_with_yoruba")

## individuals_to_ignore <- read.table("~/apoikia/APOIKIA_Analysis/admixture_analysis/remove_these_IDS_from_eigenstrat.txt",
##                                     sep = '\t', header = F, colClasses = 'character')
## indexes_to_ignore <- which(apoikia_dataset$ind[[1]] %in% individuals_to_ignore)

flags <- read.table("~/apoikia/APOIKIA_Analysis/scripts_for_f4/Updated_Labels_for_f3.csv",
  sep = ",", header = T, na.strings = c("NA", "")
)

## indexes_of_flags_to_ignore <- which(flags$Genetic_ID %in% individuals_to_ignore)

han_output <- "~/apoikia/f3_outputs/plots/dataset_04_05_2024/han_outgroup"
yoruba_output <- "~/apoikia/f3_outputs/plots/dataset_04_05_2024/yoruba_outgroup"

## Create the output directory
## dir.create("~/apoikia/f3_outputs/plots/dataset_04_05_2024/", recursive = F)
dir.create("~/apoikia/f3_outputs/plots/dataset_04_05_2024/han_outgroup", recursive = F)
dir.create("~/apoikia/f3_outputs/plots/dataset_04_05_2024/yoruba_outgroup", recursive = F)

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
  print("score_3")
  print(combination)
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
  return(all_snp_f3)
}

individual_score_3 <- function(combination, vector_of_pops, vector_of_inds, prefix, additional_pops = NULL) {
  colnames(combination) <- c("pop1", "pop2", "pop3")
  print("individual_score_3")
  print(combination)
  if( is.null(additional_pops) ){
    temp_pops <- vector_of_pops[vector_of_pops %in% combination]
    temp_inds <- vector_of_inds[vector_of_pops %in% combination]
    target_indexes <- which(temp_pops %in% combination$pop2)
  }else{
    ## Several individuals are removed from population f3 because of kinship
    ## Need to fish these out of `additional_pops`
    ## print( "Assigning pops" )
    ## additional_indexes <- which((additional_pops %in% combination$pop2) & (vector_of_pops != combination$pop2))
    additional_indexes <- which((vector_of_pops == "NO") & (additional_pops == combination$pop2))
    ## print(additional_indexes)
    ## print( additional_pops[additional_indexes] )
    ## print( vector_of_pops[additional_indexes] )
    ## print( vector_of_inds[additional_indexes] )
    if( length(additional_indexes) > 0 ){
      ## print( "Enter 1" )
      ## print(length(additional_indexes))
      ## print( additional_pops[additional_indexes] )
      ## print( vector_of_pops[additional_indexes] )
      ## print( vector_of_inds[additional_indexes] )
      temp_pops <- c(
        vector_of_pops[vector_of_pops %in% combination],
        rep(combination$pop2, length(additional_indexes))
      )
      temp_inds <- c(
        vector_of_inds[vector_of_pops %in% combination],
        vector_of_inds[additional_indexes]
      )
      target_indexes <- which(temp_pops %in% combination$pop2)
                          ## (length(temp_pops)+1):(length(temp_pops)+length(additional_indexes)) )
    }else{
      ## print( "Enter 2" )
      temp_pops <- vector_of_pops[vector_of_pops %in% combination]
      temp_inds <- vector_of_inds[vector_of_pops %in% combination]
      target_indexes <- which(temp_pops %in% combination$pop2)
    }
  }
  ## print( "additional_indexes" )
  ## print( additional_indexes )
  ## print( "target_indexes" )
  ## print( target_indexes )
  ## print( temp_inds[target_indexes] )
  ## print( temp_pops[target_indexes] )
  ## if( !(length(target_indexes) > 0)){
  ##   print( "Error in:" )
  ##   print( combination[1,2] )
  ##   print( "Additional indexes" )
  ##   print( additional_indexes )
  ##   print( "Additional names" )
  ##   print( vector_of_inds[additional_indexes] )
  ##   stop("individual_score_3")
  ## }
  ## print( temp_inds[target_indexes] )
  individual_f3 <- lapply(1:length(target_indexes), function(x) {    
    print( temp_inds[target_indexes[x]] )
    print( temp_pops[target_indexes[x]] )
    temp_f2 <- f2_from_geno(
      prefix,
      inds = temp_inds[-target_indexes[-x]], pops = temp_pops[-target_indexes[-x]],
      ## Line above remove all individuals of pop2 except x
      maxmiss = 0.1, adjust_pseudohaploid = TRUE
    )
    ## print("F2")
    temp_snps <- count_snps(temp_f2)
    temp_f3_initial <- as.data.frame(
      f3(
        temp_f2,
        combination[1,1], combination[1,2], combination[1,3]
      )
    )
    ## print("F3")
    all_snp_f3 <- cbind(temp_f3_initial, temp_snps, temp_inds[target_indexes[x]])
    colnames(all_snp_f3) <- c(colnames(temp_f3_initial), "SNPs", "ID")
    return(all_snp_f3)
  })
  return(do.call(rbind, individual_f3))
}

# * Calculate f3s with Yoruba

# ** Ammotopos

pop1 <- "Yoruba"
pop2 <- "GRC_Ammotopos_LBA_1275-1125BCE"
pop3 <- grep("NO|Ammotopos*", unique(flags$Ammotopos.1275.1125BCE.), value = TRUE, invert = TRUE)
all_combinations <- expand.grid(
  "pop1" = pop1, "pop2" = pop2, "pop3" = pop3[!is.na(pop3)],
  stringsAsFactors = F
)

f3_ammotopos <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    score_3(
      all_combinations[x, ],
      c( flags$Ammotopos.1275.1125BCE., yor$ind[[3]] ),
      c( flags$Genetic_ID, yor$ind[[1]] ),
      data_prefix
    )
  }
))

ind_f3_ammotopos <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    individual_score_3(
      all_combinations[x, ],
      c( flags$Ammotopos.1275.1125BCE., yor$ind[[3]] ),
      c( flags$Genetic_ID, yor$ind[[1]] ),
      data_prefix,
      c( flags$APOIKIA_INDIVIDUALS, rep(NA, length(yor$ind[[3]])) )
    )
  }
))

all_ammotopos <- rbind(f3_ammotopos, ind_f3_ammotopos)

# ** Archaic Amvrakia

pop1 <- "Yoruba"
pop2 <- "GRC_Amvrakia_Archaic_550-480BCE"
pop3 <- grep("NO|Amvrakia_Archaic", unique(flags$Archaic.550.480BCE.), value = TRUE, invert = TRUE)
all_combinations <- expand.grid(
  "pop1" = pop1, "pop2" = pop2, "pop3" = pop3[!is.na(pop3)],
  stringsAsFactors = F
)

f3_amv_archaic <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    score_3(
      all_combinations[x, ],
      c( flags$Archaic.550.480BCE., yor$ind[[3]] ), 
      c( flags$Genetic_ID, yor$ind[[1]] ),
      data_prefix
    )
  }
))

ind_f3_amv_archaic <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    individual_score_3(
      all_combinations[x, ],
      c( flags$Archaic.550.480BCE., yor$ind[[3]] ),
      c( flags$Genetic_ID, yor$ind[[1]] ),
      data_prefix,
      c( flags$APOIKIA_INDIVIDUALS, rep(NA, length(yor$ind[[3]])) )
    )
  }
))

all_amv_archaic <- rbind(f3_amv_archaic, ind_f3_amv_archaic)

# ** Archaic Tenea

pop1 <- "Yoruba"
pop2 <- "GRC_Tenea_Archaic_550-480BCE"
pop3 <- grep("NO|Tenea_Archaic*", unique(flags$Archaic.550.480BCE.), value = TRUE, invert = TRUE)
all_combinations <- expand.grid(
  "pop1" = pop1, "pop2" = pop2, "pop3" = pop3[!is.na(pop3)],
  stringsAsFactors = F
)

f3_tenea_archaic <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    score_3(
      all_combinations[x, ],
      c( flags$Archaic.550.480BCE., yor$ind[[3]] ),
      c( flags$Genetic_ID, yor$ind[[1]] ),
      data_prefix
    )
  }
))

# ** Classical Amvrakia

pop1 <- "Yoruba"
pop2 <- "GRC_Amvrakia_Classical_475-325BCE"
pop3 <- grep("NO|Amvrakia_Classical*", unique(flags$Classical.475.325BCE.), value = TRUE, invert = TRUE)
all_combinations <- expand.grid(
  "pop1" = pop1, "pop2" = pop2, "pop3" = pop3[!is.na(pop3)],
  stringsAsFactors = F
)

f3_amvrakia_classical <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    score_3(
      all_combinations[x, ],
      c( flags$Classical.475.325BCE., yor$ind[[3]] ),
      c( flags$Genetic_ID, yor$ind[[1]] ),
      data_prefix
    )
  }
))

ind_f3_amvrakia_classical <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    individual_score_3(
      all_combinations[x, ],
      c( flags$Classical.475.325BCE., yor$ind[[3]] ),
      c( flags$Genetic_ID, yor$ind[[1]] ),
      data_prefix,
      c( flags$APOIKIA_INDIVIDUALS, rep(NA, length(yor$ind[[3]])) )
    )
  }
))
all_amvrakia_classical <- rbind(f3_amvrakia_classical, ind_f3_amvrakia_classical)

# ** Hellenistic Amvrakia

pop1 <- "Yoruba"
pop2 <- "GRC_Amvrakia_Hellenistic_325-100BCE"
pop3 <- grep("NO|Amvrakia_Hellenistic*", unique(flags$Hellenistic.325.100BCE.), value = TRUE, invert = TRUE)
all_combinations <- expand.grid(
  "pop1" = pop1, "pop2" = pop2, "pop3" = pop3[!is.na(pop3)],
  stringsAsFactors = F
)

f3_amvrakia_hellenistic <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    score_3(
      all_combinations[x, ],
      c( flags$Hellenistic.325.100BCE., yor$ind[[3]] ),
      c( flags$Genetic_ID, yor$ind[[1]] ),
      data_prefix
    )
  }
))

ind_f3_amvrakia_hellenistic <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    individual_score_3(
      all_combinations[x, ],
      c( flags$Hellenistic.325.100BCE., yor$ind[[3]] ),
      c( flags$Genetic_ID, yor$ind[[1]] ),
      data_prefix,
      c( flags$APOIKIA_INDIVIDUALS, rep(NA, length(yor$ind[[3]])) )
    )
  }
))
all_amvrakia_hellenistic <- rbind(f3_amvrakia_hellenistic, ind_f3_amvrakia_hellenistic)

# ** Hellenistic Tenea

pop1 <- "Yoruba"
pop2 <- "GRC_Tenea_Hellenistic_150-100BCE"
## pop3 needs to not include ammotopos and NO populations
pop3 <- grep("NO|Tenea_Hellenistic*", unique(flags$Hellenistic.325.100BCE.), value = TRUE, invert = TRUE)
all_combinations <- expand.grid(
  "pop1" = pop1, "pop2" = pop2, "pop3" = pop3[!is.na(pop3)],
  stringsAsFactors = F
)

f3_tenea_hellenistic <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    score_3(
      all_combinations[x, ],
      c( flags$Hellenistic.325.100BCE., yor$ind[[3]] ),
      c( flags$Genetic_ID, yor$ind[[1]] ),
      data_prefix
    )
  }
))

ind_f3_tenea_hellenistic <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    individual_score_3(
      all_combinations[x, ],
      c( flags$Hellenistic.325.100BCE., yor$ind[[3]] ),
      c( flags$Genetic_ID, yor$ind[[1]] ),
      data_prefix,
      c( flags$APOIKIA_INDIVIDUALS, rep(NA, length(yor$ind[[3]])) )
    )
  }
))
all_tenea_hellenistic <- rbind(f3_tenea_hellenistic, ind_f3_tenea_hellenistic)

# ** Tenea Early Roman

pop1 <- "Yoruba"
pop2 <- "GRC_Tenea_LHellenistic_ERoman_100BCE-100CE"
## pop3 needs to not include ammotopos and NO populations
pop3 <- grep("NO|Tenea_LHellenistic*", unique(flags$Roman.31BCE.330CE.), value = TRUE, invert = TRUE)
all_combinations <- expand.grid(
  "pop1" = pop1, "pop2" = pop2, "pop3" = pop3[!is.na(pop3)],
  stringsAsFactors = F
)

f3_tenea_early_roman <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    temp <- score_3(
      all_combinations[x, ],
      c( flags$Roman.31BCE.330CE., yor$ind[[3]] ),
      c( flags$Genetic_ID, yor$ind[[1]] ),
      data_prefix
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
##       data_prefix
##     )
##   }
## ))

# ** Tenea Roman

pop1 <- "Yoruba"
pop2 <- "GRC_Tenea_Roman_31BCE-330CE"
pop3 <- grep("NO|Tenea_Roman*", unique(flags$Roman.31BCE.330CE.), value = TRUE, invert = TRUE)
all_combinations <- expand.grid(
  "pop1" = pop1, "pop2" = pop2, "pop3" = pop3[!is.na(pop3)],
  stringsAsFactors = F
)

f3_tenea_roman <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    score_3(
      all_combinations[x, ],
      c( flags$Roman.31BCE.330CE., yor$ind[[3]] ),
      c( flags$Genetic_ID, yor$ind[[1]] ),
      data_prefix
    )
  }
))

ind_f3_tenea_roman <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    individual_score_3(
      all_combinations[x, ],
      c( flags$Roman.31BCE.330CE., yor$ind[[3]] ),
      c( flags$Genetic_ID, yor$ind[[1]] ),
      data_prefix,
      c( flags$APOIKIA_INDIVIDUALS, rep(NA, length(yor$ind[[3]])) )
    )
  }
))
all_tenea_roman <- rbind(f3_tenea_roman, ind_f3_tenea_roman)

# ** Saving data

save_statistics <- function(f3_output, file_name) {
  write.table(f3_output, file_name, quote = FALSE, sep = '\t', row.names = FALSE)
}

save_statistics(f3_ammotopos, "~/apoikia/f3_outputs/f3_results/dataset_04_05_2024/f3_ammotopos.tsv")
save_statistics(f3_amv_archaic, "~/apoikia/f3_outputs/f3_results/dataset_04_05_2024/f3_amv_archaic.tsv")
save_statistics(f3_tenea_roman, "~/apoikia/f3_outputs/f3_results/dataset_04_05_2024/f3_tenea_roman.tsv")
save_statistics(f3_tenea_archaic, "~/apoikia/f3_outputs/f3_results/dataset_04_05_2024/f3_tenea_archaic.tsv")
save_statistics(f3_tenea_early_roman, "~/apoikia/f3_outputs/f3_results/dataset_04_05_2024/f3_tenea_early_roman.tsv")
save_statistics(f3_amvrakia_classical, "~/apoikia/f3_outputs/f3_results/dataset_04_05_2024/f3_amv_classical.tsv")
save_statistics(f3_amvrakia_hellenistic, "~/apoikia/f3_outputs/f3_results/dataset_04_05_2024/f3_amv_hellenistic.tsv")

save_statistics(ind_f3_ammotopos, "~/apoikia/f3_outputs/f3_results/dataset_04_05_2024/ind_f3_ammotopos.tsv")
save_statistics(ind_f3_amv_archaic, "~/apoikia/f3_outputs/f3_results/dataset_04_05_2024/ind_f3_amv_archaic.tsv")
save_statistics(ind_f3_tenea_roman, "~/apoikia/f3_outputs/f3_results/dataset_04_05_2024/ind_f3_tenea_roman.tsv")
save_statistics(ind_f3_amvrakia_classical, "~/apoikia/f3_outputs/f3_results/dataset_04_05_2024/ind_f3_amv_classical.tsv")
save_statistics(ind_f3_amvrakia_hellenistic, "~/apoikia/f3_outputs/f3_results/dataset_04_05_2024/ind_f3_amv_hellenistic.tsv")

# * Plots

# ** Function for plotting

plot_general <- function(f3_output) {
  f3_output_2 <- f3_output[!(f3_output$pop2 == f3_output$pop3), ]
  f3_output_2$pop1 <- reorder(f3_output_2$pop3, f3_output_2$est, mean)
  to_plot <- ggplot(f3_output_2, aes(x = est, y = pop1)) +
    geom_point() +
    geom_errorbar(aes(xmin = est - se, xmax = est + se), size = 0.4, width = 0.4) +
    labs(title = paste0(f3_output_2$pop2[1]), x = "F3") +
    theme(
      legend.position = "none",
      title = element_text(size = 20, hjust = 0.5),
      axis.text.y = element_text(size = 16)
    ) +
    scale_y_discrete(
      name = element_blank(),
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
  f3_output_2$pop1 <- factor(f3_output_2$pop3,
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
    x = est, y = pop1, group = ID
  )) +
    geom_point(
      size = point_size,
      aes(color = col_and_fill, fill = col_and_fill),
      position = position_dodge(width = 0.3)
    ) +
    geom_errorbar(aes(xmin = est - se, xmax = est + se),
      position = position_dodge(width = 0.3),
      color = col_and_fill,
      size = 0.4, width = 0.4, alpha = alpha
    ) +
    labs(title = paste0(f3_output_2$pop2[1]), x = "F3") +
    theme(
      legend.position = "right",
      title = element_text(size = 20, hjust = 0.5),
      axis.text.y = element_text(size = 16)
    ) +
    scale_y_discrete(
      name = element_blank(),
      labels = function(x) {
        sub("_([0-9]+[a-z|A-Z]*[-|_][0-9]+)", "\n\\1", x, fixed = FALSE)
      }
    ) +
    ## scale_size_manual(values = point_size)
    scale_fill_manual(
      name = "Target", labels = c("black" = "Indiviudal", "red" = "Population"),
      values = c("black" = "black", "red" = "red")
    ) +
    scale_color_manual(
      name = "Target", labels = c("black" = "Indiviudal", "red" = "Population"),
      values = c("black" = "black", "red" = "red")
    )
  return(to_plot)
}

# ** All plots

plot_ammotopos <- plot_general(f3_ammotopos)
plot_amv_archaic <- plot_general(f3_amv_archaic)
plot_tenea_archaic <- plot_general(f3_tenea_archaic)
plot_amv_classical <- plot_general(f3_amvrakia_classical)
plot_amv_hellenistic <- plot_general(f3_amvrakia_hellenistic)
plot_tenea_hellenistic <- plot_general(f3_tenea_hellenistic)
plot_tenea_early_roman <- plot_general(f3_tenea_early_roman)
plot_tenea_roman <- plot_general(f3_tenea_roman)

inds_plot_ammotopos <- plot_general_with_inds(all_ammotopos)
inds_plot_amv_archaic <- plot_general_with_inds(all_amv_archaic)
inds_plot_amv_classical <- plot_general_with_inds(all_amvrakia_classical)
inds_plot_amv_hellenistic <- plot_general_with_inds(all_amvrakia_hellenistic)
inds_plot_tenea_hellenistic <- plot_general_with_inds(all_tenea_hellenistic)
inds_plot_tenea_roman <- plot_general_with_inds(all_tenea_roman)

# ** Save plots to files

# *** Population Plots

png(paste0( c( yoruba_output, "/f3_ammotopos.png"), collapse = ''), height = 1240, width = 1240)
plot_ammotopos
dev.off()

png(paste0( c( yoruba_output, "/f3_amv_arch.png"), collapse = ''), height = 1240, width = 1240)
plot_amv_archaic
dev.off()

png(paste0( c( yoruba_output, "/f3_tenea_arch.png"), collapse = ''), height = 1240, width = 1240)
plot_tenea_archaic
dev.off()

png(paste0( c( yoruba_output, "/f3_amv_class.png"), collapse = ''), height = 1240, width = 1240)
plot_amv_classical
dev.off()

png(paste0( c( yoruba_output, "/f3_amv_hel.png"), collapse = ''), height = 1240, width = 1240)
plot_amv_hellenistic
dev.off()

png(paste0( c( yoruba_output, "/f3_tenea_hel.png"), collapse = ''), height = 1240, width = 1240)
plot_tenea_hellenistic
dev.off()

png(paste0( c( yoruba_output, "/f3_tenea_early_roman.png"), collapse = ''), height = 1240, width = 1240)
plot_tenea_early_roman
dev.off()

png(paste0( c( yoruba_output, "/f3_tenea_roman.png"), collapse = ''), height = 1240, width = 1240)
plot_tenea_roman
dev.off()

# *** Individual + Population Plots

png(paste0( c( yoruba_output, "/f3_ammotopos_with_indiduals.png" ), collapse = '' ), height = 1240, width = 1240)
inds_plot_ammotopos
dev.off()

png(paste0( c( yoruba_output, "/f3_amv_arch_with_indiduals.png" ), collapse = '' ), height = 1240, width = 1240)
inds_plot_amv_archaic
dev.off()

png(paste0( c( yoruba_output, "/f3_amv_class_with_indiduals.png" ), collapse = '' ), height = 1240, width = 1240)
inds_plot_amv_classical
dev.off()

png(paste0( c( yoruba_output, "/f3_amv_hel_with_indiduals.png" ), collapse = '' ), height = 1240, width = 1240)
inds_plot_amv_hellenistic
dev.off()

png(paste0( c( yoruba_output, "/f3_tenea_hel_with_indiduals.png" ), collapse = '' ), height = 1240, width = 1240)
inds_plot_tenea_hellenistic
dev.off()

png(paste0( c( yoruba_output, "/f3_tenea_roman_with_indiduals.png" ), collapse = '' ), height = 1240, width = 1240)
inds_plot_tenea_roman
dev.off()


# * Calculate f3s with Han

# ** Ammotopos

pop1 <- "Han"
pop2 <- "GRC_Ammotopos_LBA_1275-1125BCE"
pop3 <- grep("NO|Ammotopos*", unique(flags$Ammotopos.1275.1125BCE.), value = TRUE, invert = TRUE)
all_combinations <- expand.grid(
  "pop1" = pop1, "pop2" = pop2, "pop3" = pop3[!is.na(pop3)],
  stringsAsFactors = F
)

f3_ammotopos <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    score_3(
      all_combinations[x, ],
      c( flags$Ammotopos.1275.1125BCE., han$ind[[3]] ),
      c( flags$Genetic_ID, han$ind[[1]] ),
      data_prefix
    )
  }
))

ind_f3_ammotopos <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    individual_score_3(
      all_combinations[x, ],
      c( flags$Ammotopos.1275.1125BCE., han$ind[[3]] ),
      c( flags$Genetic_ID, han$ind[[1]] ),
      data_prefix,
      c( flags$APOIKIA_INDIVIDUALS, rep(NA, length(han$ind[[3]])) )
    )
  }
))
all_ammotopos <- rbind(f3_ammotopos, ind_f3_ammotopos)

# ** Archaic Amvrakia

pop1 <- "Han"
pop2 <- "GRC_Amvrakia_Archaic_550-480BCE"
pop3 <- grep("NO|Amvrakia_Archaic*", unique(flags$Archaic.550.480BCE.), value = TRUE, invert = TRUE)
all_combinations <- expand.grid(
  "pop1" = pop1, "pop2" = pop2, "pop3" = pop3[!is.na(pop3)],
  stringsAsFactors = F
)

f3_amv_archaic <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    score_3(
      all_combinations[x, ],
      c( flags$Archaic.550.480BCE., han$ind[[3]] ),
      c( flags$Genetic_ID, han$ind[[1]] ),
      data_prefix
    )
  }
))

ind_f3_amv_archaic <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    individual_score_3(
      all_combinations[x, ],
      c( flags$Archaic.550.480BCE., han$ind[[3]] ),
      c( flags$Genetic_ID, han$ind[[1]] ),
      data_prefix,
      c( flags$APOIKIA_INDIVIDUALS, rep(NA, length(han$ind[[3]])) )
    )
  }
))
all_amv_archaic <- rbind(f3_amv_archaic, ind_f3_amv_archaic)

# ** Archaic Tenea

pop1 <- "Han"
pop2 <- "GRC_Tenea_Archaic_550-480BCE"
pop3 <- grep("NO|Tenea_Archaic*", unique(flags$Archaic.550.480BCE.), value = TRUE, invert = TRUE)
all_combinations <- expand.grid(
  "pop1" = pop1, "pop2" = pop2, "pop3" = pop3[!is.na(pop3)],
  stringsAsFactors = F
)

f3_tenea_archaic <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    score_3(
      all_combinations[x, ],
      c( flags$Archaic.550.480BCE., han$ind[[3]] ),
      c( flags$Genetic_ID, han$ind[[1]] ),
      data_prefix
    )
  }
))

# ** Classical Amvrakia

pop1 <- "Han"
pop2 <- "GRC_Amvrakia_Classical_475-325BCE"
pop3 <- grep("NO|Amvrakia_Classical*", unique(flags$Classical.475.325BCE.), value = TRUE, invert = TRUE)
all_combinations <- expand.grid(
  "pop1" = pop1, "pop2" = pop2, "pop3" = pop3[!is.na(pop3)],
  stringsAsFactors = F
)

f3_amvrakia_classical <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    score_3(
      all_combinations[x, ],
      c( flags$Classical.475.325BCE., han$ind[[3]] ),
      c( flags$Genetic_ID, han$ind[[1]] ),
      data_prefix
    )
  }
))

ind_f3_amvrakia_classical <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    individual_score_3(
      all_combinations[x, ],
      c( flags$Classical.475.325BCE., han$ind[[3]] ),
      c( flags$Genetic_ID, han$ind[[1]] ),
      data_prefix,
      c( flags$APOIKIA_INDIVIDUALS, rep(NA, length(han$ind[[3]])) )
    )
  }
))
all_amvrakia_classical <- rbind(f3_amvrakia_classical, ind_f3_amvrakia_classical)

# ** Hellenistic Amvrakia

pop1 <- "Han"
pop2 <- "GRC_Amvrakia_Hellenistic_325-100BCE"
pop3 <- grep("NO|Amvrakia_Hellenistic*", unique(flags$Hellenistic.325.100BCE.), value = TRUE, invert = TRUE)
all_combinations <- expand.grid(
  "pop1" = pop1, "pop2" = pop2, "pop3" = pop3[!is.na(pop3)],
  stringsAsFactors = F
)

f3_amvrakia_hellenistic <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    score_3(
      all_combinations[x, ],
      c( flags$Hellenistic.325.100BCE., han$ind[[3]] ),
      c( flags$Genetic_ID, han$ind[[1]] ),
      data_prefix
    )
  }
))

ind_f3_amvrakia_hellenistic <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    individual_score_3(
      all_combinations[x, ],
      c( flags$Hellenistic.325.100BCE., han$ind[[3]] ),
      c( flags$Genetic_ID, han$ind[[1]] ),
      data_prefix,
      c( flags$APOIKIA_INDIVIDUALS, rep(NA, length(han$ind[[3]])) )
    )
  }
))
all_amvrakia_hellenistic <- rbind(f3_amvrakia_hellenistic, ind_f3_amvrakia_hellenistic)

# ** Hellenistic Tenea

pop1 <- "Han"
pop2 <- "GRC_Tenea_Hellenistic_150-100BCE"
pop3 <- grep("NO|Tenea_Hellenistic*", unique(flags$Hellenistic.325.100BCE.), value = TRUE, invert = TRUE)
all_combinations <- expand.grid(
  "pop1" = pop1, "pop2" = pop2, "pop3" = pop3[!is.na(pop3)],
  stringsAsFactors = F
)

f3_tenea_hellenistic <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    score_3(
      all_combinations[x, ],
      c( flags$Hellenistic.325.100BCE., han$ind[[3]] ),
      c( flags$Genetic_ID, han$ind[[1]] ),
      data_prefix
    )
  }
))

ind_f3_tenea_hellenistic <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    individual_score_3(
      all_combinations[x, ],
      c( flags$Hellenistic.325.100BCE., han$ind[[3]] ),
      c( flags$Genetic_ID, han$ind[[1]] ),
      data_prefix,
      c( flags$APOIKIA_INDIVIDUALS, rep(NA, length(han$ind[[3]])) )
    )
  }
))
all_tenea_hellenistic <- rbind(f3_tenea_hellenistic, ind_f3_tenea_hellenistic)

# ** Tenea Early Roman

pop1 <- "Han"
pop2 <- "GRC_Tenea_LHellenistic_ERoman_100BCE-100CE"
pop3 <- grep("NO|Tenea_LHellenistic*", unique(flags$Roman.31BCE.330CE.), value = TRUE, invert = TRUE)
all_combinations <- expand.grid(
  "pop1" = pop1, "pop2" = pop2, "pop3" = pop3[!is.na(pop3)],
  stringsAsFactors = F
)

f3_tenea_early_roman <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    temp <- score_3(
      all_combinations[x, ],
      c( flags$Roman.31BCE.330CE., han$ind[[3]] ),
      c( flags$Genetic_ID, han$ind[[1]] ),
      data_prefix
    )
  }
))

# ** Tenea Roman

pop1 <- "Han"
pop2 <- "GRC_Tenea_Roman_31BCE-330CE"
## pop3 needs to not include ammotopos and NO populations
pop3 <- grep("NO|Tenea_Roman*", unique(flags$Roman.31BCE.330CE.), value = TRUE, invert = TRUE)
all_combinations <- expand.grid(
  "pop1" = pop1, "pop2" = pop2, "pop3" = pop3[!is.na(pop3)],
  stringsAsFactors = F
)

f3_tenea_roman <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    score_3(
      all_combinations[x, ],
      c( flags$Roman.31BCE.330CE., han$ind[[3]] ),
      c( flags$Genetic_ID, han$ind[[1]] ),
      data_prefix
    )
  }
))

ind_f3_tenea_roman <- do.call(rbind, lapply(
  1:nrow(all_combinations),
  function(x) {
    individual_score_3(
      all_combinations[x, ],
      c( flags$Roman.31BCE.330CE., han$ind[[3]] ),
      c( flags$Genetic_ID, han$ind[[1]] ),
      data_prefix,
      c( flags$APOIKIA_INDIVIDUALS, rep(NA, length(han$ind[[3]])) )
    )
  }
))
all_tenea_roman <- rbind(f3_tenea_roman, ind_f3_tenea_roman)

# ** Saving data

save_statistics(f3_ammotopos, "~/apoikia/f3_outputs/f3_results/dataset_04_05_2024/f3_ammotopos_han.tsv")
save_statistics(f3_amv_archaic, "~/apoikia/f3_outputs/f3_results/dataset_04_05_2024/f3_amv_archaic_han.tsv")
save_statistics(f3_tenea_roman, "~/apoikia/f3_outputs/f3_results/dataset_04_05_2024/f3_tenea_roman_han.tsv")
save_statistics(f3_tenea_archaic, "~/apoikia/f3_outputs/f3_results/dataset_04_05_2024/f3_tenea_archaic_han.tsv")
save_statistics(f3_tenea_early_roman, "~/apoikia/f3_outputs/f3_results/dataset_04_05_2024/f3_tenea_early_roman_han.tsv")
save_statistics(f3_amvrakia_classical, "~/apoikia/f3_outputs/f3_results/dataset_04_05_2024/f3_amv_classical_han.tsv")
save_statistics(f3_amvrakia_hellenistic, "~/apoikia/f3_outputs/f3_results/dataset_04_05_2024/f3_amv_hellenistic_han.tsv")

save_statistics(ind_f3_ammotopos, "~/apoikia/f3_outputs/f3_results/dataset_04_05_2024/ind_f3_ammotopos_han.tsv")
save_statistics(ind_f3_amv_archaic, "~/apoikia/f3_outputs/f3_results/dataset_04_05_2024/ind_f3_amv_archaic_han.tsv")
save_statistics(ind_f3_tenea_roman, "~/apoikia/f3_outputs/f3_results/dataset_04_05_2024/ind_f3_tenea_roman_han.tsv")
save_statistics(ind_f3_amvrakia_classical, "~/apoikia/f3_outputs/f3_results/dataset_04_05_2024/ind_f3_amv_classical_han.tsv")
save_statistics(ind_f3_amvrakia_hellenistic, "~/apoikia/f3_outputs/f3_results/dataset_04_05_2024/ind_f3_amv_hellenistic_han.tsv")

# * Plots

# ** All plots

plot_ammotopos <- plot_general(f3_ammotopos)
plot_amv_archaic <- plot_general(f3_amv_archaic)
plot_tenea_archaic <- plot_general(f3_tenea_archaic)
plot_amv_classical <- plot_general(f3_amvrakia_classical)
plot_amv_hellenistic <- plot_general(f3_amvrakia_hellenistic)
plot_tenea_hellenistic <- plot_general(f3_tenea_hellenistic)
plot_tenea_early_roman <- plot_general(f3_tenea_early_roman)
plot_tenea_roman <- plot_general(f3_tenea_roman)

inds_plot_ammotopos <- plot_general_with_inds(all_ammotopos)
inds_plot_amv_archaic <- plot_general_with_inds(all_amv_archaic)
inds_plot_amv_classical <- plot_general_with_inds(all_amvrakia_classical)
inds_plot_amv_hellenistic <- plot_general_with_inds(all_amvrakia_hellenistic)
inds_plot_tenea_hellenistic <- plot_general_with_inds(all_tenea_hellenistic)
inds_plot_tenea_roman <- plot_general_with_inds(all_tenea_roman)

# ** Save plots to files

# *** Population Plots

png(paste0( c( han_output, "/f3_ammotopos_han.png"), collapse = ''), height = 1240, width = 1240)
plot_ammotopos
dev.off()

png(paste0( c( han_output, "/f3_amv_arch_han.png"), collapse = ''), height = 1240, width = 1240)
plot_amv_archaic
dev.off()

png(paste0( c( han_output, "/f3_tenea_arch_han.png"), collapse = ''), height = 1240, width = 1240)
plot_tenea_archaic
dev.off()

png(paste0( c( han_output, "/f3_amv_class_han.png"), collapse = ''), height = 1240, width = 1240)
plot_amv_classical
dev.off()

png(paste0( c( han_output, "/f3_amv_hel_han.png"), collapse = ''), height = 1240, width = 1240)
plot_amv_hellenistic
dev.off()

png(paste0( c( han_output, "/f3_tenea_hel_han.png"), collapse = ''), height = 1240, width = 1240)
plot_tenea_hellenistic
dev.off()

png(paste0( c( han_output, "/f3_tenea_early_roman_han.png"), collapse = ''), height = 1240, width = 1240)
plot_tenea_early_roman
dev.off()

png(paste0( c( han_output, "/f3_tenea_roman_han.png"), collapse = ''), height = 1240, width = 1240)
plot_tenea_roman
dev.off()

# *** Individual + Population Plots

png(paste0( c( han_output, "/f3_ammotopos_with_indiduals_han.png"), collapse = ''), height = 1240, width = 1240)
inds_plot_ammotopos
dev.off()

png(paste0( c( han_output, "/f3_amv_arch_with_indiduals_han.png"), collapse = ''), height = 1240, width = 1240)
inds_plot_amv_archaic
dev.off()

png(paste0( c( han_output, "/f3_amv_class_with_indiduals_han.png"), collapse = ''), height = 1240, width = 1240)
inds_plot_amv_classical
dev.off()

png(paste0( c( han_output, "/f3_amv_hel_with_indiduals_han.png"), collapse = ''), height = 1240, width = 1240)
inds_plot_amv_hellenistic
dev.off()

png(paste0( c( han_output, "/f3_tenea_hel_with_indiduals_han.png"), collapse = ''), height = 1240, width = 1240)
inds_plot_tenea_hellenistic
dev.off()

png(paste0( c( han_output, "/f3_tenea_roman_with_indiduals_han.png"), collapse = ''), height = 1240, width = 1240)
inds_plot_tenea_roman
dev.off()
