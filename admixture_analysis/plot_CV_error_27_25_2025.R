# * Libraries
list_of_packages <- c(
  "ggplot2", "reshape2",
  "forcats", "ggthemes",
  "patchwork", "gridExtra",
  "grid"
)

library(ggplot2)
library(reshape2)
library(forcats)
library(ggthemes)
library(patchwork)
library(grid)
library(gridExtra)


# * CV Error Files

list_of_file_names <- list(
  "/home/aggeliki/apoikia/admixture_logs/dataset_25_27_2025/haploid_no_paleo/LD_04/geno_04/CV_errors_apoikia.1240K.ANCIENT_plus_Yoruba_Han.LD_200_25_04.geno_04.trimmed.csv",
  "/home/aggeliki/apoikia/admixture_logs/dataset_25_27_2025/haploid_no_paleo/LD_04/geno_06/CV_errors_apoikia.1240K.ANCIENT_plus_Yoruba_Han.LD_200_25_04.geno_06.trimmed.csv",
  "/home/aggeliki/apoikia/admixture_logs/dataset_25_27_2025/haploid_no_paleo/LD_04/geno_08/CV_errors_apoikia.1240K.ANCIENT_plus_Yoruba_Han.LD_200_25_04.geno_08.trimmed.csv",
  "/home/aggeliki/apoikia/admixture_logs/dataset_25_27_2025/haploid_no_paleo/LD_06/geno_04/CV_errors_apoikia.1240K.ANCIENT_plus_Yoruba_Han.LD_200_25_06.geno_04.trimmed.csv",
  "/home/aggeliki/apoikia/admixture_logs/dataset_25_27_2025/haploid_no_paleo/LD_06/geno_06/CV_errors_apoikia.1240K.ANCIENT_plus_Yoruba_Han.LD_200_25_06.geno_06.trimmed.csv",
  "/home/aggeliki/apoikia/admixture_logs/dataset_25_27_2025/haploid_no_paleo/LD_06/geno_08/CV_errors_apoikia.1240K.ANCIENT_plus_Yoruba_Han.LD_200_25_06.geno_08.trimmed.csv",
  "/home/aggeliki/apoikia/admixture_logs/dataset_25_27_2025/haploid_no_paleo/LD_08/geno_04/CV_errors_apoikia.1240K.ANCIENT_plus_Yoruba_Han.LD_200_25_08.geno_04.trimmed.csv",
  "/home/aggeliki/apoikia/admixture_logs/dataset_25_27_2025/haploid_no_paleo/LD_08/geno_06/CV_errors_apoikia.1240K.ANCIENT_plus_Yoruba_Han.LD_200_25_08.geno_06.trimmed.csv",
  "/home/aggeliki/apoikia/admixture_logs/dataset_25_27_2025/haploid_no_paleo/LD_08/geno_08/CV_errors_apoikia.1240K.ANCIENT_plus_Yoruba_Han.LD_200_25_08.geno_08.trimmed.csv"
)

run_files <- unlist(lapply(list_of_file_names, file.exists))

which_files <- rep( run_files, times = 1, each = 9 )

all_cvs <- do.call(
  rbind,
  lapply(list_of_file_names[run_files], function(x) {
    ld <- strsplit( regmatches( x, regexpr( "LD_[0-9]+", x ) ), split = '_' )[[1]][2]
    # Matches LD_XX in file path and returns XX
    geno <- strsplit( regmatches( x, regexpr( "geno_[0-9]+", x ) ), split = '_' )[[1]][2]
    temp <- read.csv(x, header = FALSE)
    return( cbind( temp, rep(ld, nrow(temp)), rep(geno, nrow(temp))) )
  })
)
colnames(all_cvs) <- c("K", "Errors", "LD_Cutoff", "Missing_Cutoff")

plot_ks <- ggplot(data = all_cvs, aes(as.factor(K), Errors, fill = LD_Cutoff)) +
  geom_point(color = "black", alpha = 0.8, shape = 21, size = 6) +
  geom_line(aes(group = LD_Cutoff)) +
  xlab("K") + 
  theme( 
    strip.text = element_text(size = 17),
    axis.title = element_text(size = 18),
    axis.text = element_text(size = 14),
    legend.title = element_text(size = 17),
    legend.text = element_text(size = 14)
  ) +
  facet_wrap(~Missing_Cutoff, strip.position = "top", dir = "v")

png( "/home/aggeliki/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_25_27_2025/no_maf/CV_errors_25_27_2025.png",  width = 1024, height = 1024 )
plot_ks
dev.off()
