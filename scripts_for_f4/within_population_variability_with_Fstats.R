# * Libraries

## install.packages("stringr")
## library(admixr)
## install.packages("Hmisc")
library(Hmisc)
library(admixtools)
library(ggplot2)
library(stringr)
library(Cairo)
library(ggsci)

# * Reading Data and preprocessing

data_prefix <- "~/apoikia/EIGENSTRAT/dataset_04_05_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/apoikia_with_yoruba"

yor = read_packedancestrymap(
  "~/apoikia/EIGENSTRAT/dataset_04_05_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/apoikia_with_yoruba",
  pops = "Yoruba")

flags <- read.table("~/apoikia/APOIKIA_Analysis/scripts_for_f4/Updated_Labels_for_f3.csv",
  sep = ",", header = T, na.strings = c("NA", "")
)

yoruba_output <- "/home/aggeliki/apoikia/f3_outputs/f3_results/dataset_04_05_2024/variability/yoruba_outgroup"
yoruba_plot <- "/home/aggeliki/apoikia/f3_outputs/plots/dataset_04_05_2024/variability/yoruba_outgroup"

dir.create( yoruba_output, recursive = T )
dir.create( yoruba_plot, recursive = T )

# ** Ammotopos

pop1 <- "Yoruba"
pop2 <- "GRC_Ammotopos_LBA_1275-1125BCE"
 
inds_of_pop2 <- which(flags$Ammotopos.1275.1125BCE == pop2)
all_f3_ammotopos <- c()
for( i in 1:(length(inds_of_pop2)-1) ){
  for( j in (i+1):length(inds_of_pop2)){
    temp_f2 <- f2_from_geno(
      data_prefix,
      inds = c(flags$Genetic_ID[inds_of_pop2[i]], flags$Genetic_ID[inds_of_pop2[j]], yor$ind[[1]]),
      pops = c(flags$Genetic_ID[inds_of_pop2[i]], flags$Genetic_ID[inds_of_pop2[j]], yor$ind[[3]]),
      maxmiss = 0.1, adjust_pseudohaploid = TRUE
    )
    temp_snps <- count_snps(temp_f2)
    temp_f3_initial <- as.data.frame(
      f3(
        temp_f2,
        pop1,flags$Genetic_ID[inds_of_pop2[i]], flags$Genetic_ID[inds_of_pop2[j]], 
        )
    )
    all_f3_ammotopos <- rbind( all_f3_ammotopos, c(temp_f3_initial, temp_snps) )
  }
}

# ** Amvrakia Archaic

pop1 <- "Yoruba"
pop2 <- "GRC_Amvrakia_Archaic_550-480BCE"

inds_of_pop2 <- which(flags$Archaic.550.480BCE. == pop2)
all_f3_amv_archaic <- c()
for( i in 1:(length(inds_of_pop2)-1) ){
  for( j in (i+1):length(inds_of_pop2)){
    temp_f2 <- f2_from_geno(
      data_prefix,
      inds = c(flags$Genetic_ID[inds_of_pop2[i]], flags$Genetic_ID[inds_of_pop2[j]], yor$ind[[1]]),
      pops = c(flags$Genetic_ID[inds_of_pop2[i]], flags$Genetic_ID[inds_of_pop2[j]], yor$ind[[3]]),
      maxmiss = 0.1, adjust_pseudohaploid = TRUE
    )
    temp_snps <- count_snps(temp_f2)
    temp_f3_initial <- as.data.frame(
      f3(
        temp_f2,
        pop1,flags$Genetic_ID[inds_of_pop2[i]], flags$Genetic_ID[inds_of_pop2[j]], 
        )
    )
    all_f3_amv_archaic <- rbind( all_f3_amv_archaic, c(temp_f3_initial, temp_snps) )
  }
}
  
# ** Archaic Tenea

pop1 <- "Yoruba"
pop2 <- "GRC_Tenea_Archaic_550-480BCE"

inds_of_pop2 <- which(flags$Archaic.550.480BCE. == pop2)
all_f3_tenea_archaic <- c()
for( i in 1:(length(inds_of_pop2)-1) ){
  for( j in (i+1):length(inds_of_pop2)){
    temp_f2 <- f2_from_geno(
      data_prefix,
      inds = c(flags$Genetic_ID[inds_of_pop2[i]], flags$Genetic_ID[inds_of_pop2[j]], yor$ind[[1]]),
      pops = c(flags$Genetic_ID[inds_of_pop2[i]], flags$Genetic_ID[inds_of_pop2[j]], yor$ind[[3]]),
      maxmiss = 0.1, adjust_pseudohaploid = TRUE
    )
    temp_snps <- count_snps(temp_f2)
    temp_f3_initial <- as.data.frame(
      f3(
        temp_f2,
        pop1,flags$Genetic_ID[inds_of_pop2[i]], flags$Genetic_ID[inds_of_pop2[j]], 
        )
    )
    all_f3_tenea_archaic <- rbind( all_f3_tenea_archaic, c(temp_f3_initial, temp_snps) )
  }
}

# ** Classical Amvrakia

pop1 <- "Yoruba"
pop2 <- "GRC_Amvrakia_Classical_475-325BCE"

inds_of_pop2 <- which(flags$Classical.475.325BCE. == pop2)
all_f3_amv_classical <- c()
for( i in 1:(length(inds_of_pop2)-1) ){
  for( j in (i+1):length(inds_of_pop2)){
    temp_f2 <- f2_from_geno(
      data_prefix,
      inds = c(flags$Genetic_ID[inds_of_pop2[i]], flags$Genetic_ID[inds_of_pop2[j]], yor$ind[[1]]),
      pops = c(flags$Genetic_ID[inds_of_pop2[i]], flags$Genetic_ID[inds_of_pop2[j]], yor$ind[[3]]),
      maxmiss = 0.1, adjust_pseudohaploid = TRUE
    )
    temp_snps <- count_snps(temp_f2)
    temp_f3_initial <- as.data.frame(
      f3(
        temp_f2,
        pop1,flags$Genetic_ID[inds_of_pop2[i]], flags$Genetic_ID[inds_of_pop2[j]], 
        )
    )
    all_f3_amv_classical <- rbind( all_f3_amv_classical, c(temp_f3_initial, temp_snps) )
  }
}

# ** Hellenistic Amvrakia

pop1 <- "Yoruba"
pop2 <- "GRC_Amvrakia_Hellenistic_325-100BCE"

inds_of_pop2 <- which(flags$Hellenistic.325.100BCE. == pop2)
all_f3_amv_hel <- c()
for( i in 1:(length(inds_of_pop2)-1) ){
  for( j in (i+1):length(inds_of_pop2)){
    temp_f2 <- f2_from_geno(
      data_prefix,
      inds = c(flags$Genetic_ID[inds_of_pop2[i]], flags$Genetic_ID[inds_of_pop2[j]], yor$ind[[1]]),
      pops = c(flags$Genetic_ID[inds_of_pop2[i]], flags$Genetic_ID[inds_of_pop2[j]], yor$ind[[3]]),
      maxmiss = 0.1, adjust_pseudohaploid = TRUE
    )
    temp_snps <- count_snps(temp_f2)
    temp_f3_initial <- as.data.frame(
      f3(
        temp_f2,
        pop1,flags$Genetic_ID[inds_of_pop2[i]], flags$Genetic_ID[inds_of_pop2[j]], 
        )
    )
    all_f3_amv_hel <- rbind( all_f3_amv_hel, c(temp_f3_initial, temp_snps) )
  }
}

# ** Hellenistic Tenea

pop1 <- "Yoruba"
pop2 <- "GRC_Tenea_Hellenistic_150-100BCE"

inds_of_pop2 <- which(flags$Hellenistic.325.100BCE. == pop2)
all_f3_tenea_hel <- c()
for( i in 1:(length(inds_of_pop2)-1) ){
  for( j in (i+1):length(inds_of_pop2)){
    temp_f2 <- f2_from_geno(
      data_prefix,
      inds = c(flags$Genetic_ID[inds_of_pop2[i]], flags$Genetic_ID[inds_of_pop2[j]], yor$ind[[1]]),
      pops = c(flags$Genetic_ID[inds_of_pop2[i]], flags$Genetic_ID[inds_of_pop2[j]], yor$ind[[3]]),
      maxmiss = 0.1, adjust_pseudohaploid = TRUE
    )
    temp_snps <- count_snps(temp_f2)
    temp_f3_initial <- as.data.frame(
      f3(
        temp_f2,
        pop1,flags$Genetic_ID[inds_of_pop2[i]], flags$Genetic_ID[inds_of_pop2[j]], 
        )
    )
    all_f3_tenea_hel <- rbind( all_f3_tenea_hel, c(temp_f3_initial, temp_snps) )
  }
}

# ** Tenea Roman

pop1 <- "Yoruba"
pop2 <- "GRC_Tenea_Roman_31BCE-330CE"

inds_of_pop2 <- which(flags$Roman.31BCE.330CE. == pop2)
all_f3_tenea_roman <- c()
for( i in 1:(length(inds_of_pop2)-1) ){
  for( j in (i+1):length(inds_of_pop2)){
    temp_f2 <- f2_from_geno(
      data_prefix,
      inds = c(flags$Genetic_ID[inds_of_pop2[i]], flags$Genetic_ID[inds_of_pop2[j]], yor$ind[[1]]),
      pops = c(flags$Genetic_ID[inds_of_pop2[i]], flags$Genetic_ID[inds_of_pop2[j]], yor$ind[[3]]),
      maxmiss = 0.1, adjust_pseudohaploid = TRUE
    )
    temp_snps <- count_snps(temp_f2)
    temp_f3_initial <- as.data.frame(
      f3(
        temp_f2,
        pop1,flags$Genetic_ID[inds_of_pop2[i]], flags$Genetic_ID[inds_of_pop2[j]], 
        )
    )
    all_f3_tenea_roman <- rbind( all_f3_tenea_roman, c(temp_f3_initial, temp_snps) )
  }
}

# * Save Statistics

ammotopos_file_name <- paste0( c(yoruba_output, "/ammotopos_variability_f3.tsv"), collapse = ""  )
amv_archaic_file_name <- paste0( c(yoruba_output, "/amv_archaic_variability_f3.tsv"), collapse = ""  )
amv_classical_file_name <- paste0( c(yoruba_output, "/amv_classical_variability_f3.tsv"), collapse = ""  )
amv_hel_file_name <- paste0( c(yoruba_output, "/amv_hel_variability_f3.tsv"), collapse = ""  )
tenea_hel_file_name <- paste0( c(yoruba_output, "/tenea_hel_variability_f3.tsv"), collapse = ""  )
tenea_roman_file_name <- paste0( c(yoruba_output, "/tenea_roman_variability_f3.tsv"), collapse = ""  )

write.table(all_f3_ammotopos, ammotopos_file_name, quote = FALSE, sep = '\t', row.names = FALSE)
write.table(all_f3_amv_archaic, amv_archaic_file_name, quote = FALSE, sep = '\t', row.names = FALSE)
write.table(all_f3_amv_classical, amv_classical_file_name, quote = FALSE, sep = '\t', row.names = FALSE)
write.table(all_f3_amv_hel, amv_hel_file_name, quote = FALSE, sep = '\t', row.names = FALSE)
write.table(all_f3_tenea_hel, tenea_hel_file_name, quote = FALSE, sep = '\t', row.names = FALSE)
write.table(all_f3_tenea_roman, tenea_roman_file_name, quote = FALSE, sep = '\t', row.names = FALSE)

all_f3_ammotopos  <- read.table(ammotopos_file_name, sep = '\t', header = T)
all_f3_amv_archaic <- read.table(amv_archaic_file_name, sep = '\t', header = T)
all_f3_amv_classical <- read.table(amv_classical_file_name, sep = '\t', header = T)
all_f3_amv_hel <- read.table(amv_hel_file_name, sep = '\t', header = T)
all_f3_tenea_hel <- read.table(tenea_hel_file_name, sep = '\t', header = T)
all_f3_tenea_roman <- read.table(tenea_roman_file_name, sep = '\t', header = T)

# * Make the plots

# ** Data Manipulations

# *** Points

mean_ammotopos <- c( "Ammotopos", "Bronze Age", mean(all_f3_ammotopos$est) )
mean_amv_archaic <- c( "Amvrakia", "Archaic", mean(all_f3_amv_archaic$est) )
mean_amv_classical <- c( "Amvrakia", "Classical", mean(all_f3_amv_classical$est) )
mean_amv_hel <- c( "Amvrakia", "Hellenistic", mean(all_f3_amv_hel$est) )
mean_tenea_hel <- c( "Tenea", "Hellenistic", mean(all_f3_tenea_hel$est) )
mean_tenea_roman <- c( "Tenea", "Roman", mean(all_f3_tenea_roman$est) )

data_points_to_plot <- data.frame(
  est = c(
    mean(all_f3_ammotopos$est),
    mean(all_f3_amv_archaic$est),
    mean(all_f3_amv_classical$est),
    mean(all_f3_amv_hel$est),
    mean(all_f3_tenea_hel$est),
    mean(all_f3_tenea_roman$est)
  ),
  location = factor(
    c( "Ammotopos", rep("Amvrakia", 3), rep("Tenea", 2) ),
    levels = c("Ammotopos", "Amvrakia", "Tenea"), ordered = T
  ),
  age = factor(
    c("Bronze Age", "Archaic", "Classical", "Hellenistic", "Hellenistic", "Roman"),
    levels = c( "Bronze Age", "Archaic", "Classical", "Hellenistic", "Roman"),
    ordered = T
  )
)

# *** Boxplots

data_boxes_to_plot <- data.frame(
  rbind(
    all_f3_ammotopos, all_f3_amv_archaic, all_f3_amv_classical,
    all_f3_amv_hel, all_f3_tenea_hel, all_f3_tenea_roman
  ),
  location = factor(c(
    rep("Ammotopos", nrow(all_f3_ammotopos)),
    rep("Amvrakia", nrow(all_f3_amv_archaic)),
    rep("Amvrakia", nrow(all_f3_amv_classical)),
    rep("Amvrakia", nrow(all_f3_amv_hel)),
    rep("Tenea", nrow(all_f3_tenea_hel)),
    rep("Tenea", nrow(all_f3_tenea_roman))),
    levels = c("Ammotopos", "Amvrakia", "Tenea"), ordered = T
  ),
  age = factor(c(
    rep("Bronze Age", nrow(all_f3_ammotopos)),
    rep("Archaic", nrow(all_f3_amv_archaic)),
    rep("Classical", nrow(all_f3_amv_classical)),
    rep("Hellenistic", nrow(all_f3_amv_hel)),
    rep("Hellenistic", nrow(all_f3_tenea_hel)),
    rep("Roman", nrow(all_f3_tenea_roman))),
    levels = c( "Bronze Age", "Archaic", "Classical", "Hellenistic", "Roman"),
    ordered = T
  )
)

# ** Plotting

# *** Points

plotted <- ggplot( data_points_to_plot, aes( x = location, y = est, fill = age, color = age ) )
## plotted <- plotted + geom_col( width = 0.8, stat = "identity",
##                               position = position_dodge( preserve = "single") )
plotted <- plotted + geom_point(
  # stat = "identity",
  position = position_dodge( width = 0.1 )
)
plotted <- plotted + theme(
  axis.title = element_blank(),
  legend.title = element_blank(),
  axis.text = element_text( size = 14 )
)
plotted <- plotted + scale_color_aaas()

Cairo( file = paste0(c(yoruba_plot, "/variability_plot.pdf"), collapse = ''),
      type = "pdf", dpi = 90, width = 9, height = 6, units = "in" )
print(plotted)
dev.off()


# *** Boxes

plotted_boxes <- ggplot(data_boxes_to_plot,
                        aes( x = location, y = est, fill = age, color = age ))
plotted_boxes <- plotted_boxes + geom_boxplot(
  position = position_dodge(width = 1, preserve = "total"),
  outliers = F )
plotted_boxes <- plotted_boxes + geom_point( position = position_dodge(width = 1) )
## plotted_boxes <- plotted_boxes + facet_wrap( ~ location )
plotted_boxes <- plotted_boxes + theme(
  axis.title = element_blank(),
  legend.title = element_blank(),
  axis.text.x = element_text( size = 14 ),
  legend.text = element_text( size = 14 )
)
plotted_boxes <- plotted_boxes + scale_color_aaas() + scale_fill_aaas( alpha = 0.5 )

Cairo( file = paste0(c(yoruba_plot, "/variability_boxplot.pdf"), collapse = ''),
      type = "pdf", dpi = 80, width = 7, height = 5, units = "in" )
print(plotted_boxes)
dev.off()

Cairo( file = paste0(c(yoruba_plot, "/variability_boxplot.png"), collapse = ''),
      type = "png", dpi = 300, width = 7, height = 5, units = "in" )
print(plotted_boxes)
dev.off()

