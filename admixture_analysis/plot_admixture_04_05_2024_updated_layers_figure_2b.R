# * Description
# This script takes the output of admixture and returns the plots

# * Libraries

list_of_packages <- c(
  "ggplot2", "reshape2",
  "forcats", "ggthemes",
  "patchwork", "gridExtra",
  "grid", "ggh4x",
  "stringr", "ggforce",
  "argparse", "stringr",
  "Cairo"
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
library(Cairo)

# * Reading Command Line

## Check if plot folder exists

parser <- ArgumentParser()

parser$add_argument("-input_file",
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

## meta_file <- "/home/aggeliki/apoikia/EIGENSTRAT/dataset_04_05_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/no_moroccans/apoikia.1240K.ANCIENT.LD_200_25_04.trimmed.geno_08.fam"
## input_folder <- "/home/aggeliki/apoikia/admixture_logs/dataset_04_05_2024/haploid_no_paleo/LD_04/geno_04"
## plot_folder <- "~"
## label_file <- "~/apoikia/APOIKIA_Analysis/admixture_analysis/Layers_for_Admixture_04_05_2024_updated_labels.csv"

## # ** Names and handling of input files

## q.files <- grep("\\.Q", list.files(input_folder), value = TRUE)
## q.file.name <- q.files[1]

## temp_kappa_match <- regmatches(q.file.name, regexpr(pattern = "[0-9]+\\.Q", q.file.name))
## kappa <- as.numeric(strsplit(temp_kappa_match, "\\.")[[1]][1])
## prefix <- regmatches(q.file.name, regexpr(pattern = "[0-9]+\\.Q", q.file.name), invert = TRUE)[[1]][1]

## admix_data <- read.table(paste0(c(input_folder, q.file.name), collapse = "/"), header = FALSE)
## colnames(admix_data) <- paste0(rep("comp_", kappa), 1:kappa)

## labels <- read.csv(label_file, header = TRUE)
## colnames(labels) <- c("ID", "Date", "Include_1", "Include_2", "Location", "Layer_1", "Layer_2", "Layer_3")
## temp_str_1 <- str_extract( labels$Include_1, "\\d+\\w*(\\-|_)\\d+" )
## temp_letters <- str_extract( temp_str_1, "[A-Z]+" )
## old_estimate <- as.numeric(str_extract( temp_str_1, "^\\d+" ))
## young_estimate <- as.numeric(str_extract( temp_str_1, "\\d+$" ))
## temp_sign_left <- ifelse((old_estimate > young_estimate),-1,1 )
## temp_sign_right <- ifelse(is.na(temp_letters), -1,1 )
## date_midpoint <- (old_estimate*temp_sign_left + young_estimate*temp_sign_right)/2
## labels$midpoint <- date_midpoint
## labels$Layer_3 <- reorder(labels$Layer_3, labels$midpoint, FUN = mean)

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
##   Layer_2 = labels$Layer_2,
##   Layer_3 = labels$Layer_3,
##   Midpoint = labels$midpoint
## )
## to_melt <- cbind(to_melt, admix_data)

## melted_data <- melt(to_melt, measure.vars = paste0(rep("comp_", kappa), 1:kappa))

## ## Write the function that will make the plot

## # *** facet_nested_wrap

## melted_to_plot <- melted_data %>%
##   dplyr::group_by(Location) %>%
##   dplyr::arrange(Midpoint)

## colnames(melted_to_plot)

## k2plot <-
##   ggplot(melted_data, aes(value, ID, fill = as.factor(variable))) +
##   geom_col(color = "white", width = 2, linewidth = 0.001) +
##   facet_nested(
##     Location + Layer_3 + Layer_2 ~ .,
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
##     panel.spacing.y = unit(0.0001, "lines"),
##     strip.text.y = element_text( margin = margin() ),
##     axis.text.x = element_blank(),
##     axis.text.y = element_blank(),
##     panel.grid = element_blank(),
##     axis.ticks = element_blank(),
##     ## strip.text.y = element_text( angle = 180 ),
##     ggh4x.facet.nestline = element_line(colour = "blue")
##   ) +
##   scale_y_discrete( expand = expansion( add = c(-0.3,-0.3) ) ) +
##   scale_x_continuous( expand = expansion( mult = c(0.01,0.01) ) ) +
##   ## scale_x_discrete(label=function(x) abbreviate(x, minlength=3, strict = TRUE)) +
##   scale_fill_gdocs(guide = "none")

## plot_file_name <- paste0(plot_folder, "/", prefix, kappa, ".png", collapse = "")
## dir.create(plot_folder, recursive = T)

## png("/home/aggeliki/test_10.png", height = 3072, width = 2160)
## k2plot
## dev.off()

# * Debug off

# * Loop that iterates over all Q files

meta_file <- arguments$meta
input_file <- arguments$input_file
plot_folder <- arguments$plot_folder
label_file <- arguments$label_file

print(paste0(c("Meta File: ", meta_file), collapse = ''))
print(paste0(c("Input Folder: ", input_file), collapse = ''))
print(paste0(c("Plot Folder: ", plot_folder), collapse = ''))
print(paste0(c("Labels: ", label_file), collapse = ''))

if (!dir.exists(plot_folder)) {
  dir.create(plot_folder, recursive = T)
  print("Created plot folder and parents")
}

## q.files <- grep("\\.Q", list.files(input_folder), value = TRUE)

for (q.file.name in input_file) {
  
  temp_kappa_match <- regmatches(q.file.name, regexpr(pattern = "[0-9]+\\.Q", q.file.name))
  kappa <- as.numeric(strsplit(temp_kappa_match, "\\.")[[1]][1])
  ## prefix <- regmatches(q.file.name, regexpr(pattern = "[0-9]+\\.Q", q.file.name), invert = TRUE)[[1]][1]

  ## admix_data <- read.table(paste0(c(input_folder, q.file.name), collapse = "/"), header = FALSE)
  admix_data <- read.table( q.file.name, header = FALSE)
  colnames(admix_data) <- paste0(rep("comp_", kappa), 1:kappa)

  labels <- read.csv(label_file, header = TRUE)
  colnames(labels) <- c("ID", "Date", "Include_1", "Include_2", "Location", "Layer_1", "Layer_2", "Layer_3", "Figure_2b")
  labels <- labels[ labels$Figure_2b == "YES", ]
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
  labels$Layer_3 <- reorder(labels$Layer_3, labels$midpoint, FUN = mean)
  
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
    Layer_3 = labels$Layer_3,
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
    geom_col(position = "stack", width = 0.98, linewidth = 0.001) +
    facet_nested(
      Location + Layer_3 + Layer_2 ~ .,
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
      x = "Ancestry",
      title = paste0(c("K=", kappa), collapse = ""),
      y = "Individuals"
    ) +
    theme(
      ## panel.spacing = unit(2, "mm"),
      panel.spacing.y = unit(0.00001, "lines"),
      ## panel.grid.major = element_line(color = "black"),
      plot.title = element_text( size = 28 ),
      axis.title = element_text( size = 24 ),
      strip.text.y = element_text(margin = margin( 5,4,5,4, unit = "mm"), size = 13),
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      panel.grid = element_blank(),
      axis.ticks = element_blank(),
      ## strip.text.y = element_text( angle = 180 ),
      ggh4x.facet.nestline = element_line(colour = "blue")
    ) +
    ## scale_x_discrete(label=function(x) abbreviate(x, minlength=3, strict = TRUE)) +
    scale_y_discrete( expand = expansion( mult = c(-0.01,-0.01) ) ) +
    scale_x_continuous( expand = expansion( mult = c(0.01,0.01) ) ) +
    scale_fill_gdocs(guide = "none")

  plot_file_name <- paste0(plot_folder, "/", "apoikia.1240K.ANCIENT.LD_200_25_06.trimmed.geno_04.", kappa, ".Figure_2B.png", collapse = "")
  print(plot_file_name)
  png(plot_file_name, height = 2072, width = 1160)
  print(k2plot)
  dev.off()
q
  plot_file_name_pdf <- paste0(plot_folder, "/", "apoikia.1240K.ANCIENT.LD_200_25_06.trimmed.geno_04.", kappa, ".Figure_2B.pdf", collapse = "")
  Cairo(file = plot_file_name_pdf, type = "pdf", height = 2072,  dpi = 48, pointsize = 12)
  print(k2plot)
  dev.off()
}
