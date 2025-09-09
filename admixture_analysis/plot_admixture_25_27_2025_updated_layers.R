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
  "Cairo", "dplyr"
)

for (i in list_of_packages) {
  if (!require(i, character.only = TRUE)) {
    install.packages(i)
  }
  library( i, character.only = T )
}

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

# * Functions for plotting

# ** Plot for png

func_for_plotting <- function( melted_data ){
  k2plot_1 <-
    ggplot(melted_data, aes(value, ID, fill = as.factor(variable))) +
    geom_col(position = "stack", width = 0.90, linewidth = 0.001) +
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
    theme(
      ## panel.spacing = unit(2, "mm"),
      panel.spacing.y = unit(0.00001, "lines"),
      ## panel.grid.major = element_line(color = "black"),
      plot.title = element_blank(),
      axis.title = element_blank(),
      strip.text.y = element_text(margin = margin( 5,4,5,4, unit = "mm"), size = 18),
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
  return(k2plot_1)
}

# ** Plot for pdf

func_for_plotting_pdf <- function( melted_data ){
  k2plot_1 <-
    ggplot(melted_data, aes(value, ID, fill = as.factor(variable))) +
    geom_col(position = "stack", width = 0.90, linewidth = 0.001) +
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
    theme(
      ## panel.spacing = unit(2, "mm"),
      panel.spacing.y = unit(0.00001, "lines"),
      ## panel.grid.major = element_line(color = "black"),
      plot.title = element_blank(),
      axis.title = element_blank(),
      strip.text.y = element_text(margin = margin( 5,4,5,4, unit = "mm"), size = 20),
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
  return(k2plot_1)
}

# * Debug

# ** Variables for debugging purposes

## meta_file <- "/home/aggeliki/apoikia/EIGENSTRAT/dataset_25_27_2025/APOIKIA_PLUS_PUBLIC_ANCIENT_PLUS_OUTGROUPS/trimmed_data_maf_005_no_relatives/apoikia.1240K.ANCIENT_plus_Yoruba_Han.LD_200_25_04.trimmed.geno_04.fam"
## input_folder <- "~/apoikia/admixture_logs/dataset_25_27_2025/haploid_no_paleo/LD_04/geno_08"
## plot_folder <- "~"
## label_file <- "/home/aggeliki/apoikia/APOIKIA_Analysis/admixture_analysis/Layers_for_Admixture_27_25_2025.csv"

## # ** Names and handling of input files

## q.files <- grep("\\.Q", list.files(input_folder), value = TRUE)
## q.file.name <- q.files[1]

## temp_kappa_match <- regmatches(q.file.name, regexpr(pattern = "[0-9]+\\.Q", q.file.name))
## kappa <- as.numeric(strsplit(temp_kappa_match, "\\.")[[1]][1])
## prefix <- regmatches(q.file.name, regexpr(pattern = "[0-9]+\\.Q", q.file.name), invert = TRUE)[[1]][1]

## admix_data <- read.table(paste0(c(input_folder, q.file.name), collapse = "/"), header = FALSE)
## colnames(admix_data) <- paste0(rep("comp_", kappa), 1:kappa)

## labels <- read.csv(label_file, header = TRUE)
## colnames(labels) <- c("ID", "Date", "Include_1", "Include_2", "Location", "Layer_1", "Layer_2", "Layer_3", "Fig_2b")

## labels <- labels[ labels$Include_1 != "NO", ]

## temp_str_1 <- str_extract( labels$Include_1, "\\d+\\w*(\\-|_)\\d+" )
## temp_letters <- str_extract( temp_str_1, "[A-Z]+" )

## # Finds the midpoint for each group
## old_estimate <- as.numeric(str_extract( temp_str_1, "^\\d+" ))
## young_estimate <- as.numeric(str_extract( temp_str_1, "\\d+$" ))
## temp_sign_left <- ifelse((old_estimate > young_estimate),-1,1 )
## temp_sign_right <- ifelse(is.na(temp_letters), -1,1 )
## date_midpoint <- (old_estimate*temp_sign_left + young_estimate*temp_sign_right)/2
## labels$midpoint <- date_midpoint
## labels$Layer_3 <- reorder(labels$Layer_3, labels$midpoint, FUN = mean) # Reorders only factor levels.

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

## grouped_unmelted <- to_melt %>%
##   group_by(Location, .add = F) %>%
##   group_by(Layer_3, .add = T) %>%
##   group_by(Layer_2, .add = T) %>%
##   arrange(Midpoint, .by_group = T)

## split_points <- floor(seq(0, nrow(to_melt), length.out = 4))

## grouped_unmelted$Sthlh <- unlist(lapply( 1:(length(split_points)-1), function(x){
##   rep( x, split_points[x+1] - split_points[x] )
## }))

## melted_data <- melt(ungroup(grouped_unmelted), measure.vars = paste0(rep("comp_", kappa), 1:kappa))

## # *** facet_nested_wrap

## melted_to_plot <- melted_data %>%
##   dplyr::group_by(Location) %>%
##   dplyr::arrange(Midpoint)

## plot_png <- list()
## plot_pdf <- list()
## for( i in unique(melted_to_plot$Sthlh) ){
##   plot_png[[i]] <- func_for_plotting( melted_to_plot[melted_to_plot$Sthlh == i,] )
##   plot_pdf[[i]] <- func_for_plotting_pdf( melted_to_plot[melted_to_plot$Sthlh == i,] )
## }

## Cairo( file = "/home/aggeliki/test_10.png", type = "png", height = 1920, width = 1440, dpi = 28, pointsize = 10, bg = "white" )
## grid.arrange( grobs=plot_png,
##              nrow = 1, top = textGrob(
##   paste0(c("K = ", kappa), collapse = ''),
##   gp = gpar( fontsize = 50 )
## ))
## dev.off()

## Cairo(file = "/home/aggeliki/test_10.pdf", type = "pdf", height = 1440, width = 1240,  dpi = 35, pointsize = 12)
## grid.arrange( grobs=plot_pdf,
##              nrow = 1, top = textGrob(
##   paste0(c("K = ", kappa), collapse = ''),
##   gp = gpar( fontsize = 50 )
## ))
## dev.off()


# * Debug off

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
  colnames(labels) <- c("ID", "Date", "Include_1", "Include_2", "Location", "Layer_1", "Layer_2", "Layer_3")
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

  grouped_unmelted <- to_melt %>%
    group_by(Location, .add = F) %>%
    group_by(Layer_3, .add = T) %>%
    group_by(Layer_2, .add = T) %>%
    arrange(Midpoint, .by_group = T)
  
  split_points <- floor(seq(0, nrow(to_melt), length.out = 4))

  grouped_unmelted$Sthlh <- unlist(lapply( 1:(length(split_points)-1), function(x){
    rep( x, split_points[x+1] - split_points[x] )
  }))

  melted_data <- melt(ungroup(grouped_unmelted), measure.vars = paste0(rep("comp_", kappa), 1:kappa))

  melted_to_plot <- melted_data %>%
    dplyr::group_by(Location) %>%
    dplyr::arrange(Midpoint)

  plot_png <- list()
  plot_pdf <- list()
  for( i in unique(melted_to_plot$Sthlh) ){
    plot_png[[i]] <- func_for_plotting( melted_to_plot[melted_to_plot$Sthlh == i,] )
    plot_pdf[[i]] <- func_for_plotting_pdf( melted_to_plot[melted_to_plot$Sthlh == i,] )
  }  
  
  plot_file_name <- paste0(plot_folder, "/", prefix, kappa, ".png", collapse = "")
  print(plot_file_name)
  Cairo( file = plot_file_name, type = "png", height = 1920, width = 1440, dpi = 28, pointsize = 10, bg = "white" )
  grid.arrange( grobs = plot_png, nrow = 1, top = textGrob(
    paste0(c("K = ", kappa), collapse = ''),
    gp = gpar( fontsize = 50 )
  ))
  dev.off()
  
  plot_file_name_pdf <- paste0(plot_folder, "/", prefix, kappa, ".pdf", collapse = "")
  print(plot_file_name_pdf)
  Cairo(file = plot_file_name_pdf, type = "pdf", height = 1440, width = 1240,  dpi = 35, pointsize = 12)
  grid.arrange( grobs = plot_pdf, nrow = 1, top = textGrob(
    paste0(c("K = ", kappa), collapse = ''),
    gp = gpar( fontsize = 50 )
  ))
  dev.off()
  
}
