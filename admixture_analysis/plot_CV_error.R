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

cv_no_trim <- read.table("~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.no_trim.CV.txt")
rownames(cv_no_trim) <- 2:(nrow(cv_no_trim)+1)
cv_08 <- read.table("~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.200_25_08.CV.txt")
rownames(cv_08) <- 2:(nrow(cv_08)+1)
cv_06 <- read.table("~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.200_25_06.CV.txt")
rownames(cv_06) <- 2:(nrow(cv_06)+1)
cv_04 <- read.table("~/apoikia/APOIKIA_Analysis/admixture_analysis/apoikia.200_25_04.CV.txt")
rownames(cv_04) <- 2:(nrow(cv_04)+1)

to_plot <- data.frame(
  Errors = c(
    cv_no_trim[,1],
    cv_08[,1],
    cv_06[,1],
    cv_04[,1]
  ),
  K = c(
    rownames(cv_no_trim),
    rownames(cv_08),
    rownames(cv_06),
    rownames(cv_04)
  ),
  Treatment = c(
    rep("Unprunned", nrow(cv_no_trim)),
    rep("80 %", nrow(cv_08)),
    rep("60 %", nrow(cv_06)),
    rep("40 %", nrow(cv_04))
  )
)



plot_ks <- ggplot(
  data = to_plot,
  aes(as.numeric(K), Errors, fill = Treatment )) +
  geom_point(color = "black", alpha = 0.8,
             shape = 21, size = 6 ) +
  geom_line(aes(group = Treatment))


png(
  "~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/cv_all_errors.png",
  width = 1024, height = 1024
)
plot_ks
dev.off()
