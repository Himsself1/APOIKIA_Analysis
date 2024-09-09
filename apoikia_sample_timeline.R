library(ggplot2)
library(admixtools)
library(stringr)
library(ggsci)

location <- factor(
  c(
    rep("Ammotopos", 2),
    rep("Amvrakia", 14),
    rep("Tenea", 9),
    "Amvrakia"
  ),
  levels = c("Tenea", "Amvrakia","Ammotopos"),
  ordered = T
  )  

## Estimates were taken from Supplementary Table S1 - Sample list
## and are estimate of the burial dating
lower_estimate <- c(
  -1350, -1350, -550, -550, -500, -375, -450, -400, -475, -375,
  -375, -200, -250, -175, -175, -325, -500, -550, -150, -323, -100,
  -31, 75, 200, -31, -700
  )

high_estimate <- c(
  -1200, -1200, -500, -525, -480, -350, -425, -375, -450, -350,
  -350, -125, -200, -125, -125, -100, -480, -500, -100, 31, 100,
  330, 125, 300, 330, 476
)

midpoint <- (lower_estimate + high_estimate)/2

to_plot <- data.frame(
  Site = location,
  Date = midpoint,
  low = lower_estimate,
  high = high_estimate
)

to_plot$Age <- factor(
  c(
    rep( "Bronze Age", 2 ),
    rep("Archaic", 3),
    rep("Classical", 6),
    rep("Hellenistic", 5),
    rep("Archaic", 2),
    rep("Hellenistic", 2),
    "Late Hellenistic to Early Roman",
    rep("Roman", 4),
    "Archaic to Roman"
  ),
  levels = c( "Bronze Age", "Archaic", "Archaic to Roman", "Classical",
             "Hellenistic", "Late Hellenistic to Early Roman", "Roman" ),
  ordered = T
)

plotting <- ggplot(
  to_plot,
  aes( x = Date, y = Site, color = Age )
)
## plotting  <- plotting + geom_point(
##   shape = 15, size = 1.2, position = position_dodge(width = 0.5)
## )
## plotting  <- plotting + geom_jitter(
##   height = 0.18, width = 0.25, shape = 15, size = 1.2
## )
plotting  <- plotting + geom_pointrange(
  aes( xmin = low, xmax = high), size = 0.4,
  position = position_jitter( height = 0.2, width = 0.02 )
)
plotting  <- plotting + theme_minimal()
plotting  <- plotting + theme(
  legend.title = element_blank(),
  panel.grid.major.x = element_blank(),
  panel.grid.minor = element_blank(),
  panel.grid.major.y = element_line(
    linetype = "dashed",
    color = "black", size = 0.25
  ),
  panel.border = element_rect( color = "darkgray", linewidth = 0.3, fill = "transparent"),
  axis.text.x = element_text( size = 14 ),
  axis.text.y = element_text( size = 16 ),
  axis.title = element_blank(),
  legend.text = element_text( size = 14 ),
  legend.key = element_rect( color = "white", fill = "gray80" )
)
plotting  <- plotting + scale_color_aaas()

pdf(
  "/home/aggeliki/apoikia/APOIKIA_Analysis/timeline_plot.pdf",
  width = 9, height = 2
)
plotting
dev.off()

png(
  "/home/aggeliki/apoikia/APOIKIA_Analysis/timeline_plot.png",
  width = 9, height = 2, units = "in", res = 400
)
plotting
dev.off()
