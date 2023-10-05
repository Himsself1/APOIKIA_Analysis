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
  "patchwork"
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


# * Reading the command line

args = commandArgs(trailingOnly=TRUE)
if (length(args) != 3) {
  print("Incorrect number of arguments")
  usage()
  return(0)
} else {
  input_file <- args[1]
  input_info <- args[2]
  plot_folder <- args[3]
}

## Check if plot folder exists
if (dir.exists(plot_folder)) {
  dir.create(plot_folder, recursive = T)
  print("Created plot folder and parents")
}

# debugging
input_file <- "~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.1240K.APOIKIA.3.Q"
input_info <- "~/apoikia/EIGENSTRAT/new_dataset_28_07/apoikia.1240K.APOIKIA.ind"
plot_folder <- "~/apoikia/APOIKIA_Analysis/admixture_analysis/plots"
##

# ** "Smart" plot naming
splitted <- unlist(strsplit(input_file, "/"))
split_1 <- splitted[length(splitted)]
split_2 <- strsplit(split_1[[1]], ".", fixed = TRUE)[[1]]

plot_prefix <- paste0(split_2[1:(length(split_2)-1)], collapse = '_')
plot_full_name <- paste0(c(plot_folder,"/", plot_prefix, ".png"), collapse = "")

# * Read files and sculpt data
dt <- read.table(input_file)
onomata <- read.table(input_info)

if (nrow(dt) != nrow(onomata)) {
  part1 <- c("File: ", input_file, "has ", nrow(dt), " rows.")
  part2 <- c("File: ", input_info, "has ", nrow(onomata), " rows.")
  print(part1)
  print(part2)
  print("They should have the same number of rows")
  return(0)
}

colnames(dt) <- c("comp_1", "comp_2", "comp_3")
colnames(onomata) <- c("id", "sex", "Population")

## Need to build a data frame with the following format
## sampleID | popGroup | prob | loc
## head(onomata)
## head(dt)

concat_groupID <- c(
  rep("Tenea", 9),
  rep("Amvrakia", 15),
  rep("Ammotopos", 2),
  onomata$Population[27:nrow(onomata)]
)

melted_dt <- melt(dt)
melted_dt$sampleID <- rep(1:nrow(dt), 3)
colnames(melted_dt) <- c("popGroup", "prob", "sampleID")
melted_dt$loc <- rep(onomata$Population, 3)

# ** Concatenate various populations in order to avoid clutter
unique(melted_dt$loc)
new_pops <- onomata$Population

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

new_pops[tenea] <- "Tenea"
new_pops[amvrakia] <- "Amvrakia"
new_pops[ammotopos] <- "Ammotopos"
new_pops[italian_indexes] <- "Italians_Conc"
new_pops[sicilians_himera] <- "Himera"
new_pops[greek_non_minoan] <- "Greece_Non_Minoan"
new_pops[greek_minoan] <- "Minoan"
new_pops[n_macedonia] <- "N_Macedonia"
new_pops[turkey] <- "Turkey_Conc"
new_pops[croatia] <- "Croatia_Conc"
new_pops[montenegro] <- "Montenegro"
new_pops[bulgaria] <- "Bulgaria"
new_pops[albania] <- "Albania"
new_pops[serbia] <- "Serbia"
new_pops[romania_iron] <- "Romania_Iron_Gates"
new_pops[russia_yamnaya] <- "Russia"

skourtanioti_samples <- c(
  "Aposelemis_LBA",
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
  }))
new_pops[skourtanioti_indexes] <- "Greece_Skourtanioti"
melted_dt$concat_loc <- rep(new_pops, 3)


# * Prepare to plot
head(melted_dt)

## Plot idea was taken from Luis D. Verde Arregoitia's website
## https://luisdva.github.io/rstats/model-cluster-plots/
## facet_grid(~concat_loc, scales = "free", switch = "x") +


k2plot <-
  ggplot(melted_dt, aes(factor(sampleID), prob, fill = factor(popGroup))) +
  geom_col(color = "gray", width = 1, linewidth = 0.01) +
  facet_wrap(~concat_loc, nrow = 2, scales = "free_x", switch = "x") +
  theme_minimal() + labs(x = "Individuals", title = "K=3", y = "Ancestry") +
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
  scale_fill_gdocs(guide = FALSE)

png(plot_full_name, width = 1440)
k2plot
dev.off()
