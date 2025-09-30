# * Libraries

list_of_packages <- c(
  "Hmisc", "devtools",
  "ggplot2", "stringr",
  "dplyr"
)

for (i in list_of_packages) {
  if (!require(i, character.only = TRUE)) {
    install.packages(i, dependencies = T)
  }
}

devtools::install_github("uqrmaie1/admixtools")
library(admixtools)

# * Reading Inputs
source("~/apoikia/qpadm_after_revisions/qpadm_wrapper_function.R")

ind_file <- "/home/aggeliki/apoikia/EIGENSTRAT/dataset_25_27_2025/APOIKIA_PLUS_PUBLIC_ANCIENT_PLUS_OUTGROUPS/apoikia.1240K.ANCIENT_plus_Yoruba_Han.ind"
as_ind_file <- read.table( ind_file, header = F )

data_prefix <- "/home/aggeliki/apoikia/EIGENSTRAT/dataset_25_27_2025/APOIKIA_PLUS_PUBLIC_ANCIENT_PLUS_OUTGROUPS/apoikia.1240K.ANCIENT_plus_Yoruba_Han"
metadata <- read.table(
  file = "~/apoikia/APOIKIA_Analysis/qpadm_after_revisions/metadata_qpadm/qpAdm_ultimate_model_1.tsv",
  header = T, sep = '\t', fill = T, na.strings = c("",NA), comment.char = ""
)

dir.create( "~/apoikia/qpadm_results/qpwave_results", recursive = T )

have_i_moved_ind = FALSE

# ** Filter individuals that belong to populations tested.

metadata_filtered <- metadata[grep("Ignore", metadata[,5], invert = T),]
all_target_names <- unique(grep("TARGET", metadata_filtered[,6], value = T))

indexes_of_outgroup <- grep("OUTGROUP", metadata_filtered[,6])
indexes_of_base <- grep("BASE", metadata_filtered[,6])
indexes_of_left <- grep("ADDITIONAL", metadata_filtered[,6])

list_of_targets <- list()
for( i in 1:length(all_target_names) ){
  temp_target_indexes <- grep( all_target_names[i], metadata_filtered[,6] )
  list_of_targets[[unique(metadata_filtered[temp_target_indexes,5])]] <- temp_target_indexes
}

# ** Write new .ind file so that we can use qpadm with allsnps flag.

for( i in 1:nrow(metadata_filtered) ){
  if( sum( as_ind_file[,1] %in% metadata_filtered[i,1] ) < 1 ) {next}
  else{
    index_ind_file <- which(as_ind_file[,1] %in% metadata_filtered[i,1])
    as_ind_file[index_ind_file,3] <- metadata_filtered[i,5]
  }
}

more_prox_ind_file <- paste0(c(ind_file, ".more_proximate"), collapse = '')
write.table( as_ind_file, more_prox_ind_file, quote = F, col.names = F, row.names = F )

if( !file.exists(paste0(c(ind_file, ".bak"), collapse = '') ) ){
  system(paste0(c("mv ", ind_file, " ", ind_file, ".bak"),  collapse = ""))
  system(paste0(c("mv ", more_prox_ind_file, " ", ind_file),  collapse = ""))
  have_i_moved_ind = !have_i_moved_ind
}

# * Running qpWave

# ** Using f2_from_geno

f2_blocks_for_all <- f2_from_geno(
  pref = data_prefix,
  pops = metadata_filtered[,5],
  inds = metadata_filtered[,1],
  adjust_pseudohaploid = T,
  maxmiss = 0.2, afprod = TRUE
)

## Apparently the qpwave function is a wrapper of the qpadm function in R

qpwave_pairs_out <- qpwave_pairs(
  f2_data = f2_blocks_for_all,
  right = c(
    unique( metadata_filtered[indexes_of_outgroup,5] ),
    ## unique( metadata_filtered[indexes_of_left,5] )
    names(list_of_targets)
    ),
  left = c(
    unique( metadata_filtered[indexes_of_base,5] ),
    unique( metadata_filtered[indexes_of_left,5] )
  )
)

qpwave_high_pvalues <- as.data.frame(qpwave_pairs_out %>% filter(p > 0.05))

qpwave_high_pvalues <- qpwave_high_pvalues[ !duplicated(apply(qpwave_high_pvalues, 1, sort), MARGIN = 2), ] ## Remove (a,b) pair if (b,a) exists.

exclude_these_right <- c(
  "ISR-JOR_PPN_Levant_8400-6200BCE",
  "RUS_M_EHG_7050-5500BCE",
  "TUR_SWC_Pinarbasi_Epipaleolithic_HG_13650-13300BCE",
  "IRQ_TUR_PPNA-like_Mesopotamia_9500-1200BCE",
  "TUR_NW_Barcin_N_6500-5900BCE",
  "RUS_S_AfontovaGora_UP_HG_16250-15900BCE",
  "ISR_RaqefetCave_EpiP_Natufian_12000_9500BCE"
  ## If i keep these populations in the "right",
  ## i don't get any good models.
  ## I remove populations that appear in more than one
  ## pair and THEN I remove those that are younger.
  ## Didn't automate removal of right.
)

write.table(
  qpwave_pairs_out,
  "~/apoikia/qpadm_results/qpwave_results/qpwave_pairs_ultimate_sources.tsv",
  quote = F, sep = '\t', row.names = F
)

write.table(
  qpwave_high_pvalues,
  "~/apoikia/qpadm_results/qpwave_results/qpwave_pairs_ultimate_sources_high_pvalues.tsv",
  quote = F, sep = '\t', row.names = F
)

# * Run qpAdm

## Temp structure tends to be very large se we need to allow for it.
options(future.globals.maxSize = 10 * 1024^3)

# ** Build all models

# *** Build left-right

only_left <- unique(c(
  unique(metadata_filtered[indexes_of_left,5]),
  exclude_these_right
))

## sources_and_right <- c(
##   unique(metadata_filtered[indexes_of_base,5]),
##   unique(metadata_filtered[indexes_of_left,5])
## )

always_right <- setdiff(
  c(
    unique( metadata_filtered[indexes_of_outgroup,5] ),
    unique( metadata_filtered[indexes_of_base,5] )
  ),
  exclude_these_right
)

# * Automating running qpadm and reporting results.

automate_x_way_qpadm_semi_rotation <- function(
 only_left_pops,      # Populations that are only going to be sources.
 right_and_left_pops, # Populations that are going to be right when not in sources.
 outgroup,            # Populations that are only right. The 1st one is going to be the "1st right" population for qpadm.
 target,              # Target of qpAdm. Needs to be ONLY one.
 x_way,               # Number of sources for qpAdm.
 output_dir,          # Directory where output statistics will be put. It will be created if it doesn't exist.
 run_name,            # Name prefix of the output statistics.
 data_prefix          # Full path that leads to the prefix of EIGENSTRAT.
 ){
  if( length(target) > 1 ){
    stop( "More than one target specified" )
  }
  x_way_left <- as.list(as.data.frame(combn(
    unique(c(only_left_pops, right_and_left_pops)), x_way
  ))) # Get all unique combinations of potetnial sources.
  x_way_right <- lapply(
    x_way_left, function(x){
      c(outgroup, setdiff(right_and_left_pops, x))
    }) # Filter source populations out of "right" for each model.
  list_of_all_models <- list(
    left = x_way_left,
    right = x_way_right,
    target = as.list(rep(target, length(x_way_left)))
    ) # Each "row" of this list is a model.
  results_of_qpadm <- qpadm_multi(
    data_prefix,
    list_of_all_models,
    allsnps = T,
    full_results = T
  )
  ## Extract [target, left1...x, weights1...x, pvalue, feasible]
  relevant_summary_of_qpadm <- type.convert(as.data.frame(
    do.call(
      "rbind", lapply( results_of_qpadm, function(x){
        c(x$weights$target[1],
          x$weights$left,
          x$weights$weight,
          x$popdrop$p[1],
          x$popdrop$p_nested[1],
          x$popdrop$feasible[1])
      }))
  ), as.is = TRUE)
  colnames(relevant_summary_of_qpadm) <- c(
    "target",
    paste("left", 1:x_way, sep = "_"),
    paste("weight", 1:x_way, sep = "_"),
    "p_value", "p_nested", "feasible"
  )
  ## Filter acceptable
  good_and_feasible_models <- relevant_summary_of_qpadm %>%
    filter( p_value > 0.05, feasible == TRUE )
  ## Create names for the output
  dir.create(output_dir, recursive = TRUE)
  name_of_full_stats <- file.path(
    output_dir,
    paste0(c(run_name,target,"full_results.tsv"), collapse='_')
  )
  name_of_good_stats <- file.path(
    output_dir,
    paste0(c(run_name,target,"accepted_and_feasible.tsv"), collapse='_')
  )
  ## Write the tables
  write.table(
    relevant_summary_of_qpadm, name_of_full_stats,
    quote = F, sep = '\t', row.names = F
  )
  write.table(
    good_and_feasible_models, name_of_good_stats,
    quote = F, sep = '\t', row.names = F
  )
}

# * Run qpadm for all targets

for( x in 1:4 ){
  for( deigma in names(list_of_targets) ){
    print(sprintf( "Target: %s | %d way mix.", deigma, x ))
    automate_x_way_qpadm_semi_rotation(
      only_left_pops = only_left,
      right_and_left_pops = always_right[-1],
      outgroup = always_right[1],
      target = deigma,
      x_way = x,
      output_dir = "~/apoikia/qpadm_results/statistics/ultimate_sources",
      run_name = sprintf("ultimate_sources_%i_way_mix", x),
      data_prefix = data_prefix
    )
    print("Done")
  }
}

# * Move ind file back to the original

if(have_i_moved_ind){
  system(paste0(c("mv ", ind_file, " ", more_prox_ind_file), collapse = ""))
  system(paste0(c("mv ", ind_file, ".bak", " ", ind_file), collapse = ""))
  have_i_moved_ind = !have_i_moved_ind
}
