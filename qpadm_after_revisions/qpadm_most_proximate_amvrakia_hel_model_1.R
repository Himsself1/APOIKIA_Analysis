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

ind_file <- "~/apoikia/EIGENSTRAT/dataset_25_27_2025/APOIKIA_PLUS_PUBLIC_ANCIENT_PLUS_OUTGROUPS/apoikia.1240K.ANCIENT_plus_Yoruba_Han.ind"
as_ind_file <- read.table( ind_file, header = F )

data_prefix <- "~/apoikia/EIGENSTRAT/dataset_25_27_2025/APOIKIA_PLUS_PUBLIC_ANCIENT_PLUS_OUTGROUPS/apoikia.1240K.ANCIENT_plus_Yoruba_Han"
metadata <- read.table(
  file = "~/apoikia/qpadm_after_revisions/metadata_qpadm/qpAdm_most_proximate_amv_helen_model1.tsv",
  header = T, sep = '\t', fill = T, na.strings = c("",NA), comment.char = ""
)
targets_of_analysis <- grep("TARGET",metadata[,6])
dir.create( "~/apoikia/qpadm_results/qpwave_results", recursive = T )

# Pairwise qpWave cannot be run with only 1 target as the corresponding matrix will be 1x1.
# I will use all apoikia samples in order to run qpWave.

metadata_all_targets <- read.table(
  file = "~/apoikia/qpadm_after_revisions/metadata_qpadm/qpAdm_ultimate_model_1.tsv",
  header = T, sep = '\t', fill = T, na.strings = c("",NA), comment.char = ""
)
all_apoikia_indexes <- grep("TARGET", metadata_all_targets[,6])
apoikia_non_targets <- setdiff(
  all_apoikia_indexes,
  targets_of_analysis
)
apoikia_sources <- intersect(apoikia_non_targets, grep("SOURCE", metadata[,6]))
apoikia_non_sources <- setdiff(apoikia_non_targets,apoikia_sources)

metadata[apoikia_non_sources,5] <- metadata_all_targets[apoikia_non_sources,5]
metadata[apoikia_non_sources,6] <- rep("APOIKIA", length(apoikia_non_sources))

metadata[apoikia_sources,6] <- rep("APOIKIA_SOURCE", length(apoikia_sources))
metadata[all_apoikia_indexes, c(1,5,6)]

additional_outgroups <- grep("IRN_GanjDareh_N_8300-7600BCE|SRB_M_HG_IronGates_9800-5700BCE", metadata_all_targets[,5])
metadata[additional_outgroups,c(5,6)] <- metadata_all_targets[additional_outgroups,c(5,6)]
metadata[additional_outgroups,6] <- rep("ADDITIONAL_RIGHT", length(additional_outgroups))

have_i_moved_ind = FALSE

# ** Filter individuals that belong to populations tested.

metadata_filtered <- metadata[grep("Ignore", metadata[,5], invert = T),]
all_target_names <- unique(grep("TARGET", metadata_filtered[,6], value = T))

indexes_of_outgroup <- grep("OUTGROUP", metadata_filtered[,6])
indexes_of_additional_right <- grep("ADDITIONAL_RIGHT", metadata_filtered[,6])
indexes_of_apoikia_non_target <- grep("APOIKIA", metadata_filtered[,6])
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

temp_ind_file <- paste0(c(ind_file, ".temp"), collapse = '')
write.table( as_ind_file, temp_ind_file, quote = F, col.names = F, row.names = F )

if( !file.exists(paste0(c(ind_file, ".bak"), collapse = '') ) ){
  system(paste0(c("mv ", ind_file, " ", ind_file, ".bak"),  collapse = ""))
  system(paste0(c("mv ", temp_ind_file, " ", ind_file),  collapse = ""))
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
) # 649959 polymorphic SNPs

qpwave_pairs_out <- qpwave_pairs(
  f2_data = f2_blocks_for_all,
  right = c(
    unique( metadata_filtered[indexes_of_outgroup,5] ),
    unique( metadata_filtered[indexes_of_apoikia_non_target,5] ),
    names(list_of_targets)
    ),
  left = setdiff(
    c(unique( metadata_filtered[indexes_of_sources,5] ),
      unique( metadata_filtered[indexes_of_additional_right,5] )),
    unique( metadata_filtered[indexes_of_apoikia_non_target,5] ))
  ## left = setdiff(setdiff(
  ##   c(unique( metadata_filtered[indexes_of_sources,5] ),
  ##     unique( metadata_filtered[indexes_of_additional_right,5] )),
  ##   unique( metadata_filtered[indexes_of_apoikia_non_target,5] )
  ## ),
  ## exclude_these_right)
) ## Use apoikia individuals with outgroup to distinguish the rest of the right.

qpwave_high_pvalues <- as.data.frame(qpwave_pairs_out %>% filter(p > 0.05))
qpwave_high_pvalues <- qpwave_high_pvalues[ !duplicated(apply(qpwave_high_pvalues, 1, sort), MARGIN = 2), ] ## Remove (a,b) pair if (b,a) exists.

qpwave_high_pvalues
sort(table( c(qpwave_high_pvalues[,1], qpwave_high_pvalues[,2]) ),decreasing = T)

## Too many populations are in the 

write.table(
  qpwave_pairs_out,
  "~/apoikia/qpadm_results/qpwave_results/qpwave_pairs_most_proximate_amvrakia_hel.tsv",
  quote = F, sep = '\t', row.names = F
)

write.table(
  qpwave_high_pvalues,
  "~/apoikia/qpadm_results/qpwave_results/qpwave_pairs_most_proximate_amvrakia_hel_high_pvalues.tsv",
  quote = F, sep = '\t', row.names = F
)

exclude_these_right <- c(
  "GRC_StereaEllada_IA_800-500BCE",
  "GRC_Cyclades_LBA_1175-1150BCE",
  "GRC_Peloponnese_IA_1070-830BCE",
  "ITA_Adriatic_IA_750-400BCE",
  "ALB_IA_650-400BCE",
  "SRB_LBA_1000_900BCE",
  "GRC_Crete_LBA_1350-1050BCE",
  "ITA_Sardinia_IA_800-400BCE"
  ## If i keep these populations in the "right",
  ## i don't get any good models.
  ## I remove populations that appear in more than one
  ## pair and THEN I remove those that are younger.
  ## Didn't automate removal of right.
)

# * Run qpAdm

## Temp structure tends to be very large se we need to allow for it.
options(future.globals.maxSize = 50 * 1024^3)

# ** Build all models

# *** Build left-right

only_left <- unique(c(
  unique(metadata_filtered[indexes_of_sources,5]),
  exclude_these_right
))

## sources_and_right <- c(
##   unique(metadata_filtered[indexes_of_base,5]),
##   unique(metadata_filtered[indexes_of_left,5])
## )

right_and_left_pops <- setdiff(
  unique( metadata_filtered[indexes_of_sources,5] ),
  c(exclude_these_right, unique(metadata_filtered[indexes_of_apoikia_non_target,5]))
  )

only_outgroups <- c(
  unique( metadata_filtered[indexes_of_outgroup,5] ),
  unique( metadata_filtered[indexes_of_additional_right,5] )
)

for( x in 1:4 ){
  for( deigma in names(list_of_targets[1]) ){
    print(sprintf( "Target: %s | %d way mix.", deigma, x ))
    automate_x_way_qpadm_semi_rotation(
      all_left_pops = only_left,
      right_and_left_pops = right_and_left_pops,
      outgroup = only_outgroups,
      target = deigma,
      x_way = x,
      output_dir = file.path("~/apoikia/qpadm_results/statistics/most_proximate_sources", deigma),
      run_name = sprintf("most_proximate_%i_way_mix", x),
      data_prefix = data_prefix
    )
    print("Done")
  }
}

# * Move ind file back to the original

if(have_i_moved_ind){
  system(paste0(c("mv ", ind_file, " ", temp_ind_file), collapse = ""))
  system(paste0(c("mv ", ind_file, ".bak", " ", ind_file), collapse = ""))
  have_i_moved_ind = !have_i_moved_ind
}
