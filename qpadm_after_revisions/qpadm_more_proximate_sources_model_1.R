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
  file = "~/apoikia/APOIKIA_Analysis/qpadm_after_revisions/metadata_qpadm/qpAdm_more_proximate_model1.tsv",
  header = T, sep = '\t', fill = T, na.strings = c("",NA), comment.char = ""
)

dir.create( "~/apoikia/qpadm_results/qpwave_results", recursive = T )

# Pairwise qpWave cannot be run with only 1 target as the corresponding matrix will be 1x1.
# I will use all apoikia samples in order to run qpWave.
metadata_all_targets <- read.table(
  file = "~/apoikia/APOIKIA_Analysis/qpadm_after_revisions/metadata_qpadm/qpAdm_ultimate_model_1.tsv",
  header = T, sep = '\t', fill = T, na.strings = c("",NA), comment.char = ""
)

additional_outgroups <- grep("IRN_GanjDareh_N_8300-7600BCE|SRB_M_HG_IronGates_9800-5700BCE", metadata_all_targets[,5])
metadata[additional_outgroups,c(5,6)] <- metadata_all_targets[additional_outgroups,c(5,6)]
metadata[additional_outgroups,6] <- rep("ADDITIONAL_RIGHT", length(additional_outgroups))

have_i_moved_ind = FALSE

# ** Filter individuals that belong to populations tested.

metadata_filtered <- metadata[grep("Ignore", metadata[,5], invert = T),]
all_target_names <- unique(grep("TARGET", metadata_filtered[,6], value = T))

indexes_of_outgroup <- grep("OUTGROUP", metadata_filtered[,6])
indexes_of_additional_right <- grep("ADDITIONAL_RIGHT", metadata_filtered[,6])
indexes_of_sources <- grep("SOURCE", metadata_filtered[,6])

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
) # 924550 polymorphic SNPs

## Apparently the qpwave function is a wrapper of the qpadm function in R

qpwave_pairs_out <- qpwave_pairs(
  f2_data = f2_blocks_for_all,
  right = c(
    unique( metadata_filtered[indexes_of_outgroup,5] ),
    ## unique( metadata_filtered[indexes_of_left,5] )
    names(list_of_targets)[9]
    ),
  left = c(
    unique( metadata_filtered[indexes_of_sources,5] ),
    unique( metadata_filtered[indexes_of_additional_right,5] )
  )
  ## left = setdiff(
  ##   c(unique( metadata_filtered[indexes_of_sources,5] ),
  ##     unique( metadata_filtered[indexes_of_additional_right,5] )),
  ##   exclude_these_right)
)

qpwave_high_pvalues <- as.data.frame(qpwave_pairs_out %>% filter(p > 0.05))
qpwave_high_pvalues <- qpwave_high_pvalues[ !duplicated(apply(qpwave_high_pvalues, 1, sort), MARGIN = 2), ] ## Remove (a,b) pair if (b,a) exists.

qpwave_high_pvalues
sort(table( c(qpwave_high_pvalues[,1], qpwave_high_pvalues[,2]) ),decreasing = T)

exclude_these_right <- c(
  "GRC_StereaEllada_LBA_1600-1300BCE",
  "GRC_EBA_2900-2000BCE",
  "GRC_Mainland_North_MBA_2100-1600BCE",
  "ALB_MBA_1900-1700BCE",
  "ITA_Sardinia_MBA_1550-1300BCE",
  "BGR-SER_EBA-to-EMBA_Yamnaya-like_2900-2000BCE",
  "GRC_Crete_LBA_1700-1250BCE",
  "NW_Balkans_EBA-to-MLBA_2150-1250BCE",
  "GRC_Peloponnese_LBA_1600_1280BCE",
  ## If i keep these populations in the "right",
  ## i don't get any good models.
  ## I remove populations that appear in more than one
  ## pair and THEN I remove those that are younger.
  ## Didn't automate removal of right.
)

write.table(
  qpwave_pairs_out,
  "~/apoikia/qpadm_results/qpwave_results/qpwave_pairs_more_proximate_sources.tsv",
  quote = F, sep = '\t', row.names = F
)

write.table(
  qpwave_high_pvalues,
  "~/apoikia/qpadm_results/qpwave_results/qpwave_pairs_more_proximate_sources_high_pvalues.tsv",
  quote = F, sep = '\t', row.names = F
)

# * Run qpAdm

## Temp structure tends to be very large se we need to allow for it.
options(future.globals.maxSize = 50 * 1024^3) # 50 GB

# ** Build all models

# *** Build left-right

all_left <- unique(c(
  unique(metadata_filtered[indexes_of_sources,5]),
  exclude_these_right
))

right_and_left_pops <- setdiff(
  unique( metadata_filtered[indexes_of_sources,5] ),
  exclude_these_right
)

only_outgroups <- c(
  unique( metadata_filtered[indexes_of_outgroup,5] ),
  unique( metadata_filtered[indexes_of_additional_right,5] )
)

# * Run qpadm for all targets

for( x in 1:4 ){
  for( deigma in names(list_of_targets) ){
    print(sprintf( "Target: %s | %d way mix.", deigma, x ))
    automate_x_way_qpadm_semi_rotation(
      all_left_pops = all_left,
      right_and_left_pops = right_and_left_pops,
      outgroup = only_outgroups,
      target = deigma,
      x_way = x,
      output_dir = file.path("~/apoikia/qpadm_results/statistics/more_proximate_sources", deigma),
      run_name = sprintf("more_proximate_%i_way_mix", x),
      data_prefix = data_prefix
    )
    print("Done")
  }
}

# * Move ind file back to the original

if(file.exists(more_prox_ind_file)){
  system(paste0(c("mv ", ind_file, " ", more_prox_ind_file), collapse = ""))
  system(paste0(c("mv ", ind_file, ".bak", " ", ind_file), collapse = ""))
  have_i_moved_ind = !have_i_moved_ind
}
