# * Libraries

list_of_packages <- c(
  "ggplot2", "devtools",
  "stringr", "ggsci",
  "ggh4x"
)

for( i in list_of_packages ){
  if (!require(i, character.only = TRUE)) {
    install.packages(i, dependencies = T)
  }
}

# * Build the data frame for plot.
Sample_ID <- c(
  "Amm_Epi_LBA_1", "Amm_Epi_LBA_2",
  "Amv_Epi_Arch_1", "Amv_Epi_Arch_2", "Amv_Epi_Arch_3",
  "Amv_Epi_Archaic_to_Roman",
  "Amv_Epi_Cl_1", "Amv_Epi_Cl_2", "Amv_Epi_Cl_3", "Amv_Epi_Cl_4", "Amv_Epi_Cl_5", "Amv_Epi_Cl_6",
  "Amv_Epi_Hel_1", "Amv_Epi_Hel_2", "Amv_Epi_Hel_3", "Amv_Epi_Hel_4", "Amv_Epi_Hel_5",
  "Ten_Pel_Arch_1", "Ten_Pel_Arch_2",
  "Ten_Pel_Hel_1", "Ten_Pel_Hel_2",
  "Ten_Pel_LHellenisticERoman",
  "Ten_Pel_Rom_1", "Ten_Pel_Rom_2", "Ten_Pel_Rom_3", "Ten_Pel_Rom_4"  
)

location <- factor(
  c(
    rep("Ammotopos*", 2),
    rep("Amvrakia", 15),
    rep("Tenea", 9)
  ),
  levels = c("Ammotopos*", "Amvrakia", "Tenea"),
  ordered = T
  )  

## Estimates were taken from Supplementary Table S1 - Full Date
## and are estimate of the burial dating
lower_estimate <- c(
  -1350, -1350,                       # Bronze age Ammotopos
  -550, -550, -500,                   # Amvrakia Archaic
  -700,                               # Amvrakia Archaic to Roman
  -375, -450, -400, -475, -375, -375, # Amvrakia Classical
  -200, -250, -175, -175, -325,       # Amvrakia Hellenistic
  -500, -550,                         # Tenea Archaic
  -150, -323,                         # Tenea Hellenistic
  -100,                               # Tenea Late Hellenistic Early Roman
  -31, 75, 200, -31                   # Tenea Roman
  )

high_estimate <- c(
  -1200, -1200,                       # Bronze age Ammotopos
  -500, -525, -480,                   # Amvrakia Archaic
  330,                                # Amvrakia Archaic to Roman
  -350, -425, -375, -450, -350, -350, # Amvrakia Classical
  -125, -200, -125, -125, -100,       # Amvrakia Hellenistic
  -480, -500,                         # Tenea Archaic
  -100, -31,                          # Tenea Hellenistic
  100,                                # Tenea Late Hellenistic Early Roman
  330, 125, 300, 330                  # Tenea Roman
)

midpoint <- (lower_estimate + high_estimate)/2

to_plot <- data.frame(
  ID = Sample_ID,
  Site = location,
  Date = midpoint,
  low = lower_estimate,
  high = high_estimate
)

to_plot$Age <- factor(
  c(
    rep("Bronze Age", 2),
    rep("Archaic", 3),
    "Archaic to Roman",
    rep("Classical", 6),
    rep("Hellenistic", 5),
    rep("Archaic", 2),
    rep("Hellenistic", 2),
    "Late Hellenistic to Early Roman",
    rep("Roman", 4)
  ),
  levels = c( "Bronze Age", "Archaic", "Archaic to Roman", "Classical",
             "Hellenistic", "Late Hellenistic to Early Roman", "Roman" ),
  ordered = T
)

# * Plot

plotting <- ggplot(
  to_plot,
  aes( x = Date, y = ID, color = Age )
)
plotting <- plotting + geom_point( stat = "identity", alpha = 1)
plotting <- plotting + geom_errorbar( aes( xmin = low, xmax = high ), width = 0.8, alpha = 0.7 )
plotting <- plotting + scale_color_jco()
## plotting  <- plotting + scale_colour_brewer(palette = "Pastel2")
## scale_fill_aaas( alpha = 0.5 )
plotting  <- plotting + scale_x_continuous(
  transform = scales::new_transform( offset, function(x){x+1500}, function(x){x-1500} )
)
plotting  <- plotting + facet_nested(
  Site ~.,
  scales = "free_y", space = "free_y", shrink = TRUE,
  render_empty = FALSE,
  solo_line = T, nest_line = TRUE,
  strip = strip_nested(
    text_y = element_text(angle = 0),
    background_y = element_rect( fill = NA, linetype = 1, colour = "black" )
  )
)
plotting  <- plotting + theme(
  strip.placement = "outside",
  ggh4x.facet.nestline = element_line(colour = "blue"),
  axis.title.y = element_blank(),
  legend.title = element_blank(),
  panel.border = element_rect( colour = "black", linetype = 1, fill = NA ),
  panel.grid = element_blank(),
  panel.background = element_blank()
)

pdf(
  "/home/aggeliki/apoikia/APOIKIA_Analysis/timeline_plot_after_revisions.pdf",
  width = 7, height = 4
)
plotting
dev.off()

png(
  "/home/aggeliki/apoikia/APOIKIA_Analysis/timeline_plot_after_revisions.png",
  width = 7, height = 4, units = "in", res = 400
)
plotting
dev.off()
