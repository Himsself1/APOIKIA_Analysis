# * Description
# This script takes the output of admixture and returns the plots

# * Libraries

list_of_packages <- c(
  "ggplot2", "reshape2",
  "forcats", "ggthemes",
  "patchwork", "gridExtra",
  "grid", "ggh4x",
  "stringr", "ggforce",
  "argparse", "stringr"
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
library(stringr)

# * Reading Command Line

## Check if plot folder exists

parser <- ArgumentParser()

parser$add_argument("-input_folder",
  default = T, action = "store", type = "character",
  help = "Folder of Q files"
)
parser$add_argument("-plot_folder",
  default = T, action = "store", type = "character",
  help = "Folder of output plots"
)

parser$add_argument("-label_file",
  default = T, action = "store", type = "character",
  help = "File that contains the Individuals' labels that are to be plotted in csv format"
)

parser$add_argument("-meta",
  default = T, action = "store", type = "character",
  help = "File that contains Individuals' meta information (.fam file)"
)

arguments <- parser$parse_args()

# * Debug

## # ** Variables for debugging purposes

## meta_file <- "~/apoikia/EIGENSTRAT/dataset_04_05_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/apoikia.1240K.ANCIENT_maf_005_no_relatives.fam"
## input_folder <- "~/apoikia/admixture_logs/dataset_01_02_2024/haploid_with_maf_no_relatives/LD_04"
## plot_folder <- "~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_04_05_2024"
## label_file <- "~/apoikia/APOIKIA_Analysis/admixture_analysis/Layers_for_Admixture_04_05_2024.csv"

## # ** Names and handling of input files

## q.files <- grep("\\.Q", list.files(input_folder), value = TRUE)
## q.file.name <- q.files[1]

## temp_kappa_match <- regmatches(q.file.name, regexpr(pattern = "[0-9]+\\.Q", q.file.name))
## kappa <- as.numeric(strsplit(temp_kappa_match, "\\.")[[1]][1])
## prefix <- regmatches(q.file.name, regexpr(pattern = "[0-9]+\\.Q", q.file.name), invert = TRUE)[[1]][1]

## admix_data <- read.table(paste0(c(input_folder, q.file.name), collapse = "/"), header = FALSE)
## colnames(admix_data) <- paste0(rep("comp_", kappa), 1:kappa)

## labels <- read.csv(label_file, header = TRUE)
## colnames(labels) <- c("ID", "Date", "Include_1", "Include_2", "Location", "Layer_1", "Layer_2")
## temp_str_1 <- str_extract( labels$Include_1, "\\d+\\w*(\\-|_)\\d+" )
## temp_letters <- str_extract( temp_str_1, "[A-Z]+" )
## old_estimate <- as.numeric(str_extract( temp_str_1, "^\\d+" ))
## young_estimate <- as.numeric(str_extract( temp_str_1, "\\d+$" ))
## temp_sign_left <- ifelse((old_estimate > young_estimate),-1,1 )
## temp_sign_right <- ifelse(is.na(temp_letters), -1,1 )
## date_midpoint <- (old_estimate*temp_sign_left + young_estimate*temp_sign_right)/2
## labels$midpoint <- date_midpoint
## labels$Layer_1 <- reorder(labels$Layer_1, labels$midpoint, FUN = mean)

## meta_data <- read.table(meta_file) ## .fam file
## ## We need this to fix the order of samples in the labels file
## ## colnames(meta_data) <- c("id", "sex", "Population")

## ## Labels file isn't in the same order as meta file.
## correct_order_of_labels <- unlist(lapply(meta_data[, 2], function(x) {
##   which(labels[, 1] %in% x)
## }))

## ## Not all individuals might be represented in labels file.
## names_in_labels <- unlist(lapply(labels[, 1], function(x) {
##   which(meta_data[, 2] %in% x)
## }))

## labels <- labels[sort(correct_order_of_labels, decreasing = FALSE), ]
## admix_data <- admix_data[names_in_labels, ]
## meta_data <- meta_data[names_in_labels, ]

## ## Check if labels are correct (They are correct)
## ## cbind(meta_data$id[names_in_labels], labels$ID[sort(correct_order_of_labels, decreasing = FALSE)])

## to_melt <- data.frame(
##   ID = labels$ID,
##   Date = labels$Date,
##   Location = labels$Location,
##   Layer_1 = labels$Layer_1,
##   Layer_2 = labels$Layer_2
## )
## to_melt <- cbind(to_melt, admix_data)

## melted_data <- melt(to_melt, measure.vars = paste0(rep("comp_", kappa), 1:kappa))

## Write the function that will make the plot

## # *** facet_nested_wrap

## melted_to_plot <- melted_data %>%
##   dplyr::group_by(Location) %>%
##   dplyr::arrange(Date)

## colnames(melted_to_plot)

## k2plot <-
##   ggplot(melted_data, aes(value, ID, fill = as.factor(variable))) +
##   geom_col(color = "white", width = 2, linewidth = 0.001) +
##   facet_nested(
##     Location + Layer_1 + Layer_2 ~ .,
##     shrink = TRUE, solo_line = T,
##     scales = "free", switch = "y", space = "free_y",
##     independent = "x", drop = TRUE, render_empty = FALSE,
##     strip = strip_nested(
##       text_y = elem_list_text(angle = 0),
##       by_layer_y = TRUE, size = "variable"
##     )
##   ) +
##   ## theme_minimal() +
##   labs(
##     x = "Individuals",
##     title = paste0(c("K=", kappa), collapse = ""),
##     y = "Ancestry"
##   ) +
##   theme(
##     ## panel.spacing = unit(2, "mm"),
##     panel.spacing.y = unit(0.0001, "lines"),
##     ## panel.grid.major = element_line(color = "black"),
##     strip.text.y = element_text( margin = margin() ),
##     axis.text.x = element_blank(),
##     axis.text.y = element_blank(),
##     panel.grid = element_blank(),
##     axis.ticks = element_blank(),
##     ## strip.text.y = element_text( angle = 180 ),
##     ggh4x.facet.nestline = element_line(colour = "blue")
##   ) +
##   ## scale_x_discrete(label=function(x) abbreviate(x, minlength=3, strict = TRUE)) +
##   scale_fill_gdocs(guide = "none")

## plot_file_name <- paste0(plot_folder, "/", prefix, kappa, ".png", collapse = "")
## dir.create(plot_folder, recursive = T)

## png(plot_file_name, height = 2048, width = 1440)
## k2plot
## dev.off()

## Debug off

# * Loop that iterates over all Q files

meta_file <- arguments$meta
input_folder <- arguments$input_folder
plot_folder <- arguments$plot_folder
label_file <- arguments$label_file

print(paste0(c("Meta File: ", meta_file), collapse = ''))
print(paste0(c("Input Folder: ", input_folder), collapse = ''))
print(paste0(c("Plot Folder: ", plot_folder), collapse = ''))
print(paste0(c("Labels: ", label_file), collapse = ''))

if (!dir.exists(plot_folder)) {
  dir.create(plot_folder, recursive = T)
  print("Created plot folder and parents")
}

q.files <- grep("\\.Q", list.files(input_folder), value = TRUE)

for (q.file.name in q.files) {
  
  temp_kappa_match <- regmatches(q.file.name, regexpr(pattern = "[0-9]+\\.Q", q.file.name))
  kappa <- as.numeric(strsplit(temp_kappa_match, "\\.")[[1]][1])
  prefix <- regmatches(q.file.name, regexpr(pattern = "[0-9]+\\.Q", q.file.name), invert = TRUE)[[1]][1]

  admix_data <- read.table(paste0(c(input_folder, q.file.name), collapse = "/"), header = FALSE)
  colnames(admix_data) <- paste0(rep("comp_", kappa), 1:kappa)

  labels <- read.csv(label_file, header = TRUE)
  colnames(labels) <- c("ID", "Date", "Include_1", "Include_2", "Location", "Layer_1", "Layer_2")
  meta_data <- read.table(meta_file) ## We need this to fix the order of samples in the labels file
  ## colnames(meta_data) <- c("id", "sex", "Population")

  ## The following lines text mine names individual names for the date estimates
  temp_str_1 <- str_extract( labels$Include_1, "\\d+\\w*(\\-|_)\\d+" )
  temp_letters <- str_extract( temp_str_1, "[A-Z]+" )
  old_estimate <- as.numeric(str_extract( temp_str_1, "^\\d+" ))
  young_estimate <- as.numeric(str_extract( temp_str_1, "\\d+$" ))
  temp_sign_left <- ifelse((old_estimate > young_estimate),-1,1 )
  temp_sign_right <- ifelse(is.na(temp_letters), -1,1 )
  date_midpoint <- (old_estimate*temp_sign_left + young_estimate*temp_sign_right)/2
  labels$midpoint <- date_midpoint
  labels$Layer_1 <- reorder(labels$Layer_1, labels$midpoint, FUN = mean)
  
  ## Labels file isn't in the same order as meta file.
  correct_order_of_labels <- unlist(lapply(meta_data[, 2], function(x) {
    which(labels[, 1] %in% x)
  }))

  ## Not all individuals might be represented in labels file.
  names_in_labels <- unlist(lapply(labels[, 1], function(x) {
    which(meta_data[, 2] %in% x)
  }))

  labels <- labels[sort(correct_order_of_labels, decreasing = FALSE), ]
  admix_data <- admix_data[names_in_labels, ]
  meta_data <- meta_data[names_in_labels, ]

  to_melt <- data.frame(
    ID = labels$ID,
    Date = labels$Date,
    Location = labels$Location,
    Layer_1 = labels$Layer_1,
    Layer_2 = labels$Layer_2,
    Midpoint = labels$midpoint
  )
  to_melt <- cbind(to_melt, admix_data)

  melted_data <- melt(to_melt, measure.vars = paste0(rep("comp_", kappa), 1:kappa))

  ## Write the function that will make the plot

  melted_to_plot <- melted_data %>%
    dplyr::group_by(Location) %>%
    dplyr::arrange(Midpoint)
  ## colnames(melted_to_plot)

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
  png(plot_file_name, height = 3072, width = 1440)
  print(k2plot)
  dev.off()
}
