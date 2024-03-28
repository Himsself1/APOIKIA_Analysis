# * Description
# This script takes the output of admixture and returns the plots

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

## Check if plot folder exists
if (dir.exists(plot_folder)) {
  dir.create(plot_folder, recursive = T)
  print("Created plot folder and parents")

}
parser <- ArgumentParser()

parset$add_argument("-input_folder",
  default = T, action = "store", type = "character",
  help = "Folder of Q files"
)
parset$add_argument("-plot_folder",
  default = T, action = "store", type = "character",
  help = "Folder of output plots"
)

parset$add_argument("-label_file",
  default = T, action = "store", type = "character",
  help = "File that contains the Individuals' labels that are to be plotted"
)

parset$add_argument("-meta",
  default = T, action = "store", type = "character",
  help = "File that contains Individuals' meta information (.ind or .fam file)"
)

# * Variables for debugging purposes

meta_file <- "~/apoikia/EIGENSTRAT/new_dataset_01_02_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/apoikia.1240K.ANCIENT.ind"
input_folder <- "~/apoikia/admixture_logs/dataset_01_02_2024/haploid/LD_04"
plot_folder <- "~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_01_02_24"
label_file <- "~/apoikia/APOIKIA_Analysis/admixture_analysis/Layers_for_Admixture.csv"

# * Names and handling of input files

q.files <- grep("\\.Q", list.files(input_folder), value = TRUE)
q.file.name <- q.files[2]

# * Debug

temp_kappa_match <- regmatches(q.file.name, regexpr(pattern = "[0-9]+\\.Q", q.file.name))
kappa <- as.numeric(strsplit(temp_kappa_match, "\\.")[[1]][1])
prefix <- regmatches(q.file.name, regexpr(pattern = "[0-9]+\\.Q", q.file.name), invert = TRUE)[[1]][1]

admix_data <- read.table(paste0(c(input_folder, q.file.name), collapse = "/"), header = FALSE)
colnames(admix_data) <- paste0(rep("comp_", kappa), 1:kappa)

labels <- read.csv(label_file, header = TRUE)
colnames(labels) <- c("ID", "Date", "Include_1", "Include_2", "Location", "Layer_1", "Layer_2")
meta_data <- read.table(meta_file) ## We need this to fix the order of samples in the labels file
colnames(meta_data) <- c("id", "sex", "Population")

## Labels file isn't in the same order as meta file.
correct_order_of_labels <- unlist(lapply(meta_data[, 1], function(x) {
  which(labels[, 1] %in% x)
}))

## Not all individuals might be represented in labels file.
names_in_labels <- unlist(lapply(labels[, 1], function(x) {
  which(meta_data[, 1] %in% x)
}))

labels <- labels[sort(correct_order_of_labels, decreasing = FALSE), ]
admix_data <- admix_data[names_in_labels, ]
meta_data <- meta_data[names_in_labels, ]

to_melt <- data.frame(
  ID = labels$ID,
  Date = labels$Date,
  Location = labels$Location,
  Layer_1 = labels$Layer_1,
  Layer_2 = labels$Layer_2
)
to_melt <- cbind(to_melt, admix_data)

melted_data <- melt(to_melt, measure.vars = paste0(rep("comp_", kappa), 1:kappa))

## Write the function that will make the plot

# *** facet_nested_wrap

melted_to_plot <- melted_data %>%
  dplyr::group_by(Location) %>%
  dplyr::arrange(Date)

colnames(melted_to_plot)

k2plot <-
  ggplot(melted_data, aes(value, ID, fill = as.factor(variable))) +
  geom_col(color = "white", width = 2, linewidth = 0.001) +
  facet_nested(
    Location + Layer_1 + Layer_2 ~ .,
    shrink = TRUE, solo_line = T,
    scales = "free", switch = "y", space = "free_y",
    independent = "x", drop = TRUE, render_empty = FALSE,
    strip = strip_nested(
      text_y = elem_list_text(angle = 0),
      by_layer_y = TRUE, size = "variable"
    )
  ) +
  ## theme_minimal() +
  labs(
    x = "Individuals",
    title = paste0(c("K=", kappa), collapse = ""),
    y = "Ancestry"
  ) +
  theme(
    ## panel.spacing = unit(2, "mm"),
    panel.spacing.y = unit(0.0001, "lines"),
    ## panel.grid.major = element_line(color = "black"),
    strip.text.y = element_text( margin = margin() ),
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    panel.grid = element_blank(),
    axis.ticks = element_blank(),
    ## strip.text.y = element_text( angle = 180 ),
    ggh4x.facet.nestline = element_line(colour = "blue")
  ) +
  ## scale_x_discrete(label=function(x) abbreviate(x, minlength=3, strict = TRUE)) +
  scale_fill_gdocs(guide = "none")

plot_file_name <- paste0(plot_folder, "/", prefix, kappa, ".png", collapse = "")

png(plot_file_name, height = 2048, width = 1440)
k2plot
dev.off()

## Debug off

# * Loop that iterates over all Q files

for (q.file.name in q.files) {
  
  temp_kappa_match <- regmatches(q.file.name, regexpr(pattern = "[0-9]+\\.Q", q.file.name))
  kappa <- as.numeric(strsplit(temp_kappa_match, "\\.")[[1]][1])
  prefix <- regmatches(q.file.name, regexpr(pattern = "[0-9]+\\.Q", q.file.name), invert = TRUE)[[1]][1]

  admix_data <- read.table(paste0(c(input_folder, q.file.name), collapse = "/"), header = FALSE)
  colnames(admix_data) <- paste0(rep("comp_", kappa), 1:kappa)

  labels <- read.csv(label_file, header = TRUE)
  colnames(labels) <- c("ID", "Date", "Include_1", "Include_2", "Location", "Layer_1", "Layer_2")
  meta_data <- read.table(meta_file) ## We need this to fix the order of samples in the labels file
  colnames(meta_data) <- c("id", "sex", "Population")

  ## Labels file isn't in the same order as meta file.
  correct_order_of_labels <- unlist(lapply(meta_data[, 1], function(x) {
    which(labels[, 1] %in% x)
  }))

  ## Not all individuals might be represented in labels file.
  names_in_labels <- unlist(lapply(labels[, 1], function(x) {
    which(meta_data[, 1] %in% x)
  }))

  labels <- labels[sort(correct_order_of_labels, decreasing = FALSE), ]
  admix_data <- admix_data[names_in_labels, ]
  meta_data <- meta_data[names_in_labels, ]

  to_melt <- data.frame(
    ID = labels$ID,
    Date = labels$Date,
    Location = labels$Location,
    Layer_1 = labels$Layer_1,
    Layer_2 = labels$Layer_2
  )
  to_melt <- cbind(to_melt, admix_data)

  melted_data <- melt(to_melt, measure.vars = paste0(rep("comp_", kappa), 1:kappa))

  ## Write the function that will make the plot

  melted_to_plot <- melted_data %>%
    dplyr::group_by(Location) %>%
    dplyr::arrange(Date)
  colnames(melted_to_plot)

  k2plot <-
    ggplot(melted_data, aes(value, ID, fill = as.factor(variable))) +
    geom_col(color = "white", width = 2, linewidth = 0.001) +
    facet_nested(
      Location + Layer_1 + Layer_2 ~ .,
      shrink = TRUE, solo_line = T,
      scales = "free", switch = "y", space = "free_y",
      independent = "x", drop = TRUE, render_empty = FALSE,
      strip = strip_nested(
        text_y = elem_list_text(angle = 0),
        by_layer_y = TRUE, size = "variable"
      )
    ) +
    ## theme_minimal() +
    labs(
      x = "Individuals",
      title = paste0(c("K=", kappa), collapse = ""),
      y = "Ancestry"
    ) +
    theme(
      ## panel.spacing = unit(2, "mm"),
      panel.spacing.y = unit(0.0001, "lines"),
      ## panel.grid.major = element_line(color = "black"),
      strip.text.y = element_text(margin = margin()),
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      panel.grid = element_blank(),
      axis.ticks = element_blank(),
      ## strip.text.y = element_text( angle = 180 ),
      ggh4x.facet.nestline = element_line(colour = "blue")
    ) +
    ## scale_x_discrete(label=function(x) abbreviate(x, minlength=3, strict = TRUE)) +
    scale_fill_gdocs(guide = "none")

  plot_file_name <- paste0(plot_folder, "/", prefix, kappa, ".png", collapse = "")
  print(plot_file_name)
  png(plot_file_name, height = 2048, width = 1440)
  print(k2plot)
  dev.off()
}


