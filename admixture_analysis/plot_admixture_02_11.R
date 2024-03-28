# * Description
# This script takes the output of admixture and returns the plots

usage <- function() {
  print("Usage:")
  print("plot_admixture.R admixture.Q individuals.ind path/to/plot/")
}


# * Libraries
list_of_packages <- c(
  "ggplot2", "reshape2",
  "forcats", "ggthemes",
  "patchwork", "gridExtra",
  "grid", "ggh4x",
  "stringr", "ggforce"
)


for (i in list_of_packages) {
  if (!require(i, character.only = TRUE)) {
    install.packages(i)
  }
}

library(ggplot2)
library(reshape2)
library(forcats)
library(ggthemes)
library(patchwork)
library(grid)
library(gridExtra)
library(ggh4x)
library(stringr)
library(ggforce)

# * Input files. Change before Use

input_info <- "~/apoikia/EIGENSTRAT/new_dataset_28_07/apoikia.1240K.APOIKIA.ind"
plot_folder <- "~/apoikia/APOIKIA_Analysis/admixture_analysis/plots"

## Check if plot folder exists
if (dir.exists(plot_folder)) {
  dir.create(plot_folder, recursive = T)
  print("Created plot folder and parents")
}

vec_of_input_files <- c(
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.2.Q",
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.3.Q",
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.4.Q",
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.5.Q",
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.6.Q",
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.7.Q"
)

vec_of_input_files_08 <- c(
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.LD_200_25_08.trimmed.2.Q",
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.LD_200_25_08.trimmed.3.Q",
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.LD_200_25_08.trimmed.4.Q",
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.LD_200_25_08.trimmed.5.Q",
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.LD_200_25_08.trimmed.6.Q",
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.LD_200_25_08.trimmed.7.Q",
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.LD_200_25_08.trimmed.8.Q",
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.LD_200_25_08.trimmed.9.Q"
)

vec_of_input_files_06 <- c(
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.LD_200_25_06.trimmed.2.Q",
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.LD_200_25_06.trimmed.3.Q",
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.LD_200_25_06.trimmed.4.Q",
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.LD_200_25_06.trimmed.5.Q",
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.LD_200_25_06.trimmed.6.Q",
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.LD_200_25_06.trimmed.7.Q",
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.LD_200_25_06.trimmed.8.Q",
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.LD_200_25_06.trimmed.9.Q",
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.LD_200_25_06.trimmed.10.Q"
)

vec_of_input_files_04 <- c(
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.LD_200_25_04.trimmed.2.Q",
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.LD_200_25_04.trimmed.3.Q",
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.LD_200_25_04.trimmed.4.Q",
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.LD_200_25_04.trimmed.5.Q",
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.LD_200_25_04.trimmed.6.Q",
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.LD_200_25_04.trimmed.7.Q",
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.LD_200_25_04.trimmed.8.Q",
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.LD_200_25_04.trimmed.9.Q",
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.LD_200_25_04.trimmed.10.Q"
)

# * Read files and sculpt data

# ** Making a csv with concatenated names

onomata <- read.table(input_info)
colnames(onomata) <- c("id", "sex", "Population")

tenea <- grepl("Ten_Pel", onomata$Population, fixed = T)
amvrakia <- grepl("Amv_Epi", onomata$Population, fixed = T)
ammotopos <- grepl("Amm", onomata$Population, fixed = T)
italian_indexes <- grepl("Italy", onomata$Population, fixed = T)
sicilians_himera <- grepl("Himera", onomata$Population, fixed = T)
greek_non_minoan <- grepl("Greece", onomata$Population, fixed = T)
greek_minoan <- grepl("Minoan", onomata$Population, fixed = T)
n_macedonia <- grepl("Macedonia", onomata$Population, fixed = T)
turkey <- grepl("Turkey", onomata$Population, fixed = T)
croatia <- grepl("Croatia", onomata$Population, fixed = T)
montenegro <- grepl("Montenegro", onomata$Population, fixed = T)
bulgaria <- grepl("Bulgaria", onomata$Population, fixed = T)
albania <- grepl("Albania", onomata$Population, fixed = T)
serbia <- grepl("Serbia", onomata$Population, fixed = T)
romania_iron <- grepl("Romania", onomata$Population, fixed = T)
russia_yamnaya <- grepl("Russia", onomata$Population, fixed = T)
sicily_IA <- grepl("Sicily_IA", onomata$Population, fixed = T)
israel <- grepl("Israel", onomata$Population, fixed = T)

skourtanioti_samples <- c(
  "Aposelemis",
  "GlykaNera_LBA",
  "HgCharalambos_EMBA",
  "Krousonas_LBA",
  "Koukounaries_LBA",
  "Lazarides_EBA",
  "Lazarides_LBA",
  "Mygdalia_LBA",
  "NeaStyra_EBA",
  "Tiryns_LBA",
  "Tiryns_IA",
  "Chania_LBA"
)
skourtanioti_indexes <- unlist(
  sapply(skourtanioti_samples, function(x) {
    which(grepl(x, onomata$Population, fixed = T))
  })
)

poia_atoma <- c(
  which(tenea),
  which(amvrakia),
  which(ammotopos),
  which(italian_indexes),
  which(sicilians_himera),
  which(greek_non_minoan),
  which(greek_minoan),
  which(n_macedonia),
  which(turkey),
  which(croatia),
  which(montenegro),
  which(bulgaria),
  which(albania),
  which(serbia),
  which(romania_iron),
  which(russia_yamnaya),
  which(sicily_IA),
  which(israel),
  skourtanioti_indexes
)

poia_atoma_pops <- c(
  rep("Tenea", sum(tenea)),
  rep("Amvrakia", sum(amvrakia)),
  rep("Ammotopos", sum(ammotopos)),
  rep("Italy", sum(italian_indexes)),
  rep("Himera", sum(sicilians_himera)),
  rep("Greece_Non_Minoan", sum(greek_non_minoan)),
  rep("Minoan", sum(greek_minoan)),
  rep("N_Macedonia", sum(n_macedonia)),
  rep("Turkey_Conc", sum(turkey)),
  rep("Croatia_Conc", sum(croatia)),
  rep("Montenegro", sum(montenegro)),
  rep("Bulgaria", sum(bulgaria)),
  rep("Albania", sum(albania)),
  rep("Serbia", sum(serbia)),
  rep("Romania_Iron_Gates", sum(romania_iron)),
  rep("Russia", sum(russia_yamnaya)),
  rep("Sicily_IA", sum(sicily_IA)),
  rep("Israel", sum(israel)),
  rep("Greece", length(skourtanioti_indexes))
)

data <- read.table(vec_of_input_files_04[3])
colnames(data) <- c("comp_1", "comp_2", "comp_3", "comp_4")

dim(data)

concat_matrix <- data.frame(
  Ind_ID = onomata$id[poia_atoma],
  Population_Name = poia_atoma_pops,
  Original_name = onomata$Population[poia_atoma],
  Bigger_name = str_extract(
    onomata$Population[poia_atoma], "([A-Z|a-z]+)_([A-Z|a-z]+)_*",
    group = 1
  ),
  Smaller_name = str_extract(
    onomata$Population[poia_atoma], "([A-Z|a-z]+)_([A-Z|a-z]+)_*",
    group = 2
  ),
  Column = c(
    rep("col_1", floor(length(poia_atoma) / 2)),
    rep("col_2", ceiling(length(poia_atoma) / 2))
  )
)

to_plot <- cbind(
  data[poia_atoma, ],
  concat_matrix
)

melted_to_plot <- melt(to_plot, measure.vars = c("comp_1", "comp_2", "comp_3", "comp_4"))

colnames(melted_to_plot)

summary(melted_to_plot)

# *** facet_nested

k2plot <-
  ggplot(melted_to_plot, aes(value, Ind_ID, fill = as.factor(variable))) +
  geom_col(color = "gray", width = 2, linewidth = 0.001) +
  facet_nested(
    Bigger_name + Smaller_name ~ .,
    shrink = TRUE,
    scales = "free", switch = "y", space = "free_y",
    independent = "x", drop = TRUE, render_empty = FALSE,
    strip = strip_nested(text_y = elem_list_text(angle = 0),
                         by_layer_y = TRUE, size = "variable")
  ) +
  ## theme_minimal() +
  labs(
    x = "Individuals",
    title = paste0(c("K=", 4), collapse = ""),
    y = "Ancestry"
  ) +
  theme(
    ## panel.spacing = unit(2, "mm"),
    panel.spacing.y = unit(0.0001, "lines"),
    panel.grid.major = element_line( color = "black" ),
    ## strip.text.x = element_blank(),
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    panel.grid = element_blank(),
    ## strip.text.y = element_text( angle = 180 ),
    ggh4x.facet.nestline = element_line(colour = "blue")
  ) +
  ## scale_x_discrete(label=function(x) abbreviate(x, minlength=3, strict = TRUE)) +
  scale_fill_gdocs(guide = "none")


# *** facet_nested_wrap

k2plot <-
  ggplot(melted_to_plot, aes(value, Ind_ID, fill = as.factor(variable))) +
  geom_col(color = "white", width = 1, linewidth = 0.001) +
  facet_nested_wrap(
    Bigger_name + Smaller_name ~ Column,
    ncol = 2, shrink = FALSE,
    scales = "free", strip.position = "left",
    remove_labels = "all",
    strip = strip_nested(text_y = elem_list_text(angle = 0),
                         by_layer_y = TRUE, size = "variable")
  ) +
  ## theme_minimal() +
  labs(
    x = "Individuals",
    title = paste0(c("K=", 4), collapse = ""),
    y = "Ancestry"
  ) +
  ## scale_y_continuous(expand = c(0, 0)) +
  ## scale_x_discrete(expand = expand_scale(add = 1), ) +
  theme(
    panel.spacing = unit(0.0001, "lines"),
    ## panel.spacing.y = unit(0.01, "lines"),
    ## strip.text.x = element_blank(),
    axis.text.x = element_blank(), 
    axis.text.y = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    ggh4x.facet.nestline = element_line(colour = "blue")
  ) +
  scale_fill_gdocs(guide = "none")

# *** Save the plot

png("~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/test_adm_labs.png", height = 1240, width = 860 )
k2plot
dev.off()

write.table(
  concat_matrix,
  "/home/aggeliki/apoikia/APOIKIA_Analysis/admixture_analysis/Concatenation_Matrix.csv",
  col.names = T, row.names = F,
  sep = ',', quote = F
)

# *** Old Labels

## read_data_fix_labels <- function(input_file, input_info, K) {
##   dt <- read.table(input_file)
##   onomata <- read.table(input_info)
##   print("Input Files:")
##   print(input_file)
##   if (nrow(dt) != nrow(onomata)) {
##     part1 <- c("File: ", input_file, "has ", nrow(dt), " rows.")
##     part2 <- c("File: ", input_info, "has ", nrow(onomata), " rows.")
##     print(part1)
##     print(part2)
##     print("They should have the same number of rows")
##     return(0)
##   }
##   ## print("Input Check")
##   sthles <- rep("", K)
##   for (kappa in 1:K) {
##     sthles[kappa] <- paste0(c("comp_", kappa), collapse = '')
##   }
##   colnames(dt) <- sthles
##   colnames(onomata) <- c("id", "sex", "Population")
##   ## Need to build a data frame with the following format
##   ## sampleID | popGroup | prob | loc
##   melted_dt <- melt(dt)
##   melted_dt$sampleID <- rep(1:nrow(dt), K)
##   colnames(melted_dt) <- c("popGroup", "prob", "sampleID")
##   melted_dt$loc <- rep(onomata$Population, K)
##   # ** Concatenate various populations in order to avoid clutter
##   new_pops <- onomata$Population
##   tenea <- grepl("Ten_Pel", onomata$Population, fixed = T)
##   amvrakia <- grepl("Amv_Epi", onomata$Population, fixed = T)
##   ammotopos <- grepl("Amm", onomata$Population, fixed = T)
##   italian_indexes <- grepl("Italy", onomata$Population, fixed = T)
##   sicilians_himera <- grepl("Himera", onomata$Population, fixed = T)
##   greek_non_minoan <- grepl("Greece", onomata$Population, fixed = T)
##   greek_minoan <- grepl("Minoan", onomata$Population, fixed = T)
##   n_macedonia <- grepl("Macedonia", onomata$Population, fixed = T)
##   turkey <- grepl("Turkey", onomata$Population, fixed = T)
##   croatia <- grepl("Croatia", onomata$Population, fixed = T)
##   montenegro <- grepl("Montenegro", onomata$Population, fixed = T)
##   bulgaria <- grepl("Bulgaria", onomata$Population, fixed = T)
##   albania <- grepl("Albania", onomata$Population, fixed = T)
##   serbia <- grepl("Serbia", onomata$Population, fixed = T)
##   romania_iron <- grepl("Romania", onomata$Population, fixed = T)
##   russia_yamnaya <- grepl("Russia", onomata$Population, fixed = T)
##   sicily_IA <- grepl("Sicily_IA", onomata$Population, fixed = T)
##   israel <- grepl("Israel", onomata$Population, fixed = T)
##   ## Assign the new indexes
##   new_pops[tenea] <- paste("Tenea (", sum(tenea), ")", sep = "", collapse = "")
##   new_pops[amvrakia] <- paste("Amvrakia (", sum(amvrakia), ")", sep = "", collapse = "")
##   new_pops[ammotopos] <- paste("Ammotopos (", sum(ammotopos), ")", sep = "", collapse = "")
##   new_pops[italian_indexes] <- paste("Italy (", sum(italian_indexes), ")", sep = "", collapse = "")
##   new_pops[sicilians_himera] <- paste("Himera (", sum(sicilians_himera), ")", sep = "", collapse = "")
##   new_pops[greek_non_minoan] <- paste("Greece_Non_Minoan (", sum(greek_non_minoan), ")", sep = "", collapse = "") # nolint
##   new_pops[greek_minoan] <- paste("Minoan (", sum(greek_minoan), ")", sep = "", collapse = "")
##   new_pops[n_macedonia] <- paste("N_Macedonia (", sum(n_macedonia), ")", sep = "", collapse = "")
##   new_pops[turkey] <- paste("Turkey_Conc (", sum(turkey), ")", sep = "", collapse = "")
##   new_pops[croatia] <- paste("Croatia_Conc (", sum(croatia), ")", sep = "", collapse = "")
##   new_pops[montenegro] <- paste("Montenegro (", sum(montenegro), ")", sep = "", collapse = "")
##   new_pops[bulgaria] <- paste("Bulgaria (", sum(bulgaria), ")", sep = "", collapse = "")
##   new_pops[albania] <- paste("Albania (", sum(albania), ")", sep = "", collapse = "")
##   new_pops[serbia] <- paste("Serbia (", sum(serbia), ")", sep = "", collapse = "")
##   new_pops[romania_iron] <- paste("Romania_Iron_Gates (", sum(romania_iron), ")", sep = "", collapse = "")
##   new_pops[russia_yamnaya] <- paste("Russia (", sum(russia_yamnaya), ")", sep = "", collapse = "")
##   new_pops[sicily_IA] <- paste("Sicily_IA (", sum(sicily_IA), ")", sep = "", collapse = "")
##   new_pops[israel] <- paste("Israel (", sum(israel), ")", sep = "", collapse = "")
##   skourtanioti_samples <- c(
##     "Aposelemis",
##     "GlykaNera_LBA",
##     "HgCharalambos_EMBA",
##     "Krousonas_LBA",
##     "Koukounaries_LBA",
##     "Lazarides_EBA",
##     "Lazarides_LBA",
##     "Mygdalia_LBA",
##     "NeaStyra_EBA",
##     "Tiryns_LBA",
##     "Tiryns_IA",
##     "Chania_LBA"
##   )
##   skourtanioti_indexes <- unlist(
##     sapply(skourtanioti_samples, function(x) {
##       which(grepl(x, onomata$Population, fixed = T))
##     })
##   )
##   new_pops[skourtanioti_indexes] <- paste("Greece_Skourtanioti (", length(skourtanioti_indexes), ")", sep = "", collapse = "")
##   melted_dt$concat_loc <- rep(new_pops, K)
##   print(summary(melted_dt))
##   return(melted_dt)
## }

# * Make list of data for each K

all_melted <- list()
for (i in 1:length(vec_of_input_files)) {
  all_melted[[i]] <- read_data_fix_labels(
    vec_of_input_files[[i]],
    input_info,
    i+1
  )
}

names(all_melted) <- 2:(i + 1)

# * Prepare to plot

plot_admixture <- function(dedomena, K) {
  ## Plot idea was taken from Luis D. Verde Arregoitia's website
  ## https://luisdva.github.io/rstats/model-cluster-plots/
  k2plot <-
    ggplot(dedomena, aes(factor(sampleID), prob, fill = as.factor(popGroup))) +
    geom_col(color = "gray", width = 1, linewidth = 0.001) +
    facet_wrap(~concat_loc, nrow = 2, scales = "free_x", strip.position = "bottom") +
    theme_minimal() +
    labs(
      x = "Individuals",
      title = paste0(c("K=", K), collapse = ""),
      y = "Ancestry"
    ) +
    scale_y_continuous(expand = c(0, 0)) +
    ## scale_x_discrete(expand = expand_scale(add = 1)) +
    theme(
      panel.spacing.x = unit(0.5, "lines"),
      panel.spacing.y = unit(1, "lines"),
      ## strip.text.x = element_blank(),
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      panel.grid = element_blank()
    ) +
    scale_fill_gdocs(guide = "none")
  print(paste0("Plot Finished. K = ", K), collapse = "")
  return(k2plot)
}

all_plots <- lapply(1:length(all_melted), function(x) {
  plot_admixture(all_melted[[x]], x + 1)
})

for (i in 1:length(all_plots)) {
  plot_name <- paste0(
    c("~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/ADMIXTURE_no_prunning_", (i+1), ".png"),
    collapse = ""
  )
  print(plot_name)
  png(filename = plot_name, width = 1440, height = 720)
  print(all_plots[[i]])
  dev.off()
}

# * Same process for different prunnings

# ** 200 25 08

all_melted <- list()
for (i in 1:length(vec_of_input_files_08)) {
  all_melted[[i]] <- read_data_fix_labels(
    vec_of_input_files_08[[i]],
    input_info,
    i+1
  )
}

names(all_melted) <- 2:(i + 1)

all_plots <- lapply(1:length(all_melted), function(x) {
  plot_admixture(all_melted[[x]], x + 1)
})

for (i in 1:length(all_plots)) {
  plot_name <- paste0(
    c("~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/ADMIXTURE_LD_200_25_08_", (i + 1), ".png"),
    collapse = ""
  )
  print(plot_name)
  png(filename = plot_name, width = 1440, height = 720)
  print(all_plots[[i]])
  dev.off()
}

# ** 200 25 06

all_melted <- list()
for (i in 1:length(vec_of_input_files_06)) {
  all_melted[[i]] <- read_data_fix_labels(
    vec_of_input_files_06[[i]],
    input_info,
    i+1
  )
}

names(all_melted) <- 2:(i + 1)

all_plots <- lapply(1:length(all_melted), function(x) {
  plot_admixture(all_melted[[x]], x + 1)
})

for (i in 1:length(all_plots)) {
  plot_name <- paste0(
    c("~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/ADMIXTURE_LD_200_25_06_", (i + 1), ".png"),
    collapse = ""
  )
  print(plot_name)
  png(filename = plot_name, width = 1440, height = 720)
  print(all_plots[[i]])
  dev.off()
}

# ** 200 25 04

all_melted <- list()
for (i in 1:length(vec_of_input_files_04)) {
  all_melted[[i]] <- read_data_fix_labels(
    vec_of_input_files_04[[i]],
    input_info,
    i+1
  )
}

names(all_melted) <- 2:(i + 1)

all_plots <- lapply(1:length(all_melted), function(x) {
  plot_admixture(all_melted[[x]], x + 1)
})

for (i in 1:length(all_plots)) {
  plot_name <- paste0(
    c("~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/ADMIXTURE_LD_200_25_04_", (i+1), ".png"),
    collapse = ""
  )
  print(plot_name)
  png(filename = plot_name, width = 1440, height = 720)
  print(all_plots[[i]])
  dev.off()
}
