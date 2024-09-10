# Load necessary libraries
packages <- c(
  "ggplot2", "ggtext", "dplyr", "tidyr"
)

# Install missing packages
for (i in packages) {
  if (!require(i, character.only = TRUE)) {
    install.packages(i, dependencies = TRUE)
  }
  library(i, character.only = TRUE)
}

# Parse command line arguments
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 4) {
  stop("Please provide both input and output directories, and the save name for the plot.")
}

input_directory <- args[1]  # First argument: input directory
output_directory <- args[2]  # Second argument: output directory
save_name <-  args[3]  # Third argument: name of the plot
run_dir <-  args[4]  # Fourth argument: run directory

# Set working directory to the input directory
setwd(input_directory)

# Step 1: Read the list of run parameters from a text file
runs_from_file <- readLines(file.path(run_dir, "runs.list"))

# Trim any leading/trailing spaces from runs (important for precise matching)
runs_from_file <- trimws(runs_from_file)

# Step 2: Get the list of files that match the criteria
files <- list.files(pattern = ".*filtered.OUTQPADM$")
files <- files[grepl("^(haplo|diplo)", files)]  # Match files starting with 'haplo' or 'diplo'

# Initialize list to collect data
pop_data <- list()

# Step 3: Loop through each file and extract data
for (file in files) {
  parameters <- strsplit(file, "-")[[1]]
  if (length(parameters) >= 3) {
    run_info <- paste(parameters[1:3], collapse = "-")
  } else {
    next  # Skip if there are not enough parameters
  }

  # Read the QPADM data
  qpdm_df <- read.table(file, header = FALSE)
  popmix_col <- as.character(qpdm_df[, 1])  # Population mix
  pop_contributions <- as.character(qpdm_df[, 5])  # Contributions

  # Check if the number of population mixes and contributions match
  if (length(popmix_col) != length(pop_contributions)) {
    cat("Mismatch in lengths for file:", file, "\n")
    next
  }

  # Collect data
  for (i in seq_along(popmix_col)) {
    pop_data <- append(pop_data, list(data.frame(Run = run_info, Population = popmix_col[i], Contribution = pop_contributions[i])))
  }
}

# Step 4: Combine the collected data into a single data frame
pop_df <- do.call(rbind, pop_data)

# Step 5: Split population and contribution columns and calculate the number of contributions
pop_df$Population_Split <- strsplit(as.character(pop_df$Population), ",")
pop_df$Contribution_Split <- lapply(strsplit(as.character(pop_df$Contribution), ","), as.numeric)

# Add a column 'Num_Contributions' that contains the number of splits (contributions) for each row
pop_df <- pop_df %>%
  mutate(Num_Contributions = lengths(Contribution_Split))

# Step 6: Sort the dataframe based on Num_Contributions
pop_df <- pop_df %>%
  arrange(Num_Contributions)

# Step 7: Ensure there are at least 1 unique runs
unique_runs <- unique(pop_df$Run)
if (length(unique_runs) < 1) {
  cat("Error: There are only", length(unique_runs), "unique runs. At least 1 are required.\n")
  stop("Not enough unique runs to proceed.")
}

# Step 8: Initialize a list to hold the data for plotting
plot_data <- list()
unique_populations <- unique(pop_df$Population)

# Step 9: Aggregate contributions for each inner population across different runs
for (outer_pop in unique_populations) {
  outer_pop_df <- subset(pop_df, Population == outer_pop)

  inner_populations <- unique(unlist(outer_pop_df$Population_Split))
  inner_pop_contributions <- matrix(0, nrow = length(runs_from_file), ncol = length(inner_populations))
  colnames(inner_pop_contributions) <- inner_populations

  for (i in seq_len(nrow(outer_pop_df))) {
    run_index <- match(outer_pop_df$Run[i], runs_from_file)
    if (!is.na(run_index)) {
      for (j in seq_along(outer_pop_df$Population_Split[[i]])) {
        inner_pop <- outer_pop_df$Population_Split[[i]][j]
        contribution <- outer_pop_df$Contribution_Split[[i]][j]
        inner_pop_contributions[run_index, inner_pop] <- contribution
      }
    }
  }

  plot_data[[outer_pop]] <- data.frame(inner_pop_contributions, Run = runs_from_file)
}

# Step 10: Combine the data frames into one
combined_data <- bind_rows(plot_data, .id = "Population")

# Step 11: Convert from wide to long format
long_data <- pivot_longer(combined_data,
                          cols = -c(Run, Population),
                          names_to = "Inner_Population",
                          values_to = "Contribution")

# Step 12: Replace NA values with zeros in the Contribution column
long_data$Contribution <- replace_na(long_data$Contribution, 0)

# Ensure Contribution is numeric
long_data$Contribution <- as.numeric(long_data$Contribution)

custom_palette <- c(
  "#F38400",  # Vivid Orange
  "#A1CAF1",  # Very Light Blue
  "#F3C300",  # Vivid Yellow
  "#875692",  # Strong Purple  
  "#BE0032",  # Vivid Red
  "#C2B280",  # Grayish Yellow
  "#008856",  # Vivid Green
  "#E68FAC",  # Strong Purplish Pink
  "#0067A5",  # Strong Blue
  "#F99379",  # Light Pink
  "#604E97",  # Strong Violet
  "#F6A600",  # Vivid Orange Yellow
  "#B3446C",  # Strong Purplish Red
  "#DCD300",  # Vivid Greenish Yellow
  "#882D17",  # Strong Reddish Brown
  "#8DB600",  # Vivid Yellowish Green
  "#654522",  # Deep Yellowish Brown
  "#E25822",  # Vivid Reddish Orange
  "#2B3D26",  # Dark Olive Green
  "#222222"   # Black
)




# Maximum number of colors in your custom palette
max_custom_colors <- length(custom_palette)

# Assign colors based on the number of populations
inner_populations <- unique(long_data$Inner_Population)
if (length(inner_populations) <= max_custom_colors) {
  colors <- custom_palette[1:length(inner_populations)]
} else {
  colors <- colorRampPalette(custom_palette)(length(inner_populations))
}

# Sort inner populations based on their appearance in the first outer population
first_outer_pop <- unique(long_data$Population)[1]
sorted_inner_pops <- long_data %>%
  filter(Population == first_outer_pop) %>%
  arrange(Run) %>%
  pull(Inner_Population) %>%
  unique()

# Ensure sorted_inner_pops contains all inner populations
missing_inner_pops <- setdiff(inner_populations, sorted_inner_pops)
sorted_inner_pops <- c(sorted_inner_pops, missing_inner_pops)

# Reorder the long_data factor levels for Inner_Population
long_data$Inner_Population <- factor(long_data$Inner_Population, levels = sorted_inner_pops)

# Step 13: Create upset-style labels for populations
upset_labels <- sapply(unique(long_data$Population), function(pop) {
  label <- paste(mapply(function(inner_pop, color) {
    if (grepl(inner_pop, pop)) {
      paste0("<span style='color:", color, "; font-size:35px;'>●</span><br/>")
    } else {
      "<span style='color:lightgrey; font-size:35px;'>●</span><br/>"
    }
  }, sorted_inner_pops, colors), collapse = "")
  return(label)
})

# Assign the labels to the Population factor
long_data$Population <- factor(long_data$Population,
                               levels = unique(long_data$Population),
                               labels = upset_labels)

# Step 14: Plot the data with upset-style labels
a <- ggplot(long_data, aes(x = Run, y = Contribution, fill = Inner_Population, group = Inner_Population)) +
  geom_bar(position = "stack", stat = "identity", color = "black", linewidth = 0.05, width = 1) +
  facet_grid(Population ~ ., scales = "free_y", switch = "y") +
  scale_fill_manual(values = setNames(colors, sorted_inner_pops)) +
  theme_minimal() +
  labs(x = "Run", y = "Population Model", fill = "Population") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        strip.text.y.left = element_markdown(angle = 90),
        axis.text.y = element_blank(),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 10))

# Step 15: Save the plot to the output directory
output_file <- file.path(output_directory, save_name)

save_plot <- function(output_file, plot, num_outer_pops) {
  base_height <- 8  # Base height for a minimal number of populations
  base_width <- 4

  plot_height <- base_height + (0.5 * num_outer_pops)
  base_width <- base_width + (0.025 * num_outer_pops)

  plot_height <- max(8, min(plot_height, 200))  # Height between 6 and 40 units
  base_width <- max(4, min(plot_height, 30))  # Width between 4 and 30 units

  ggsave(output_file, plot = plot, width = base_width, height = plot_height, dpi = 72, limitsize = FALSE)
}

num_outer_pops <- length(unique(long_data$Population))
save_plot(output_file, a, num_outer_pops)
warnings()

print('Process completed and plot saved.')

