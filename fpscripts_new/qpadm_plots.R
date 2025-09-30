# ===========================
# QPADM per-target Plot
# Left: compact presence squares (UpSet-style y “labels”)
# Right: horizontal stacked weights
# ===========================

args <- commandArgs(trailingOnly = TRUE)

# Assign values if provided
if (length(args) >= 1) pop_dir        <- args[1]
if (length(args) >= 2) out_pdf        <- ifelse(args[2] == "NULL", NULL, args[2])
add_plot_title <- FALSE 

cat("Parameters in use:\n")
cat("  pop_dir        =", pop_dir, "\n")
cat("  out_pdf        =", out_pdf, "\n")

suppressPackageStartupMessages({
  library(dplyr); library(tidyr); library(readr); library(ggplot2)
  library(scales); library(grid); library(patchwork)
  suppressWarnings({
    if (requireNamespace("ggsci", quietly = TRUE)) library(ggsci)
    if (requireNamespace("RColorBrewer", quietly = TRUE)) library(RColorBrewer)
  })
})

# ---------- helpers ----------
read_one_tsv <- function(path) {
  df <- tryCatch(readr::read_tsv(path, show_col_types = FALSE, progress = FALSE),
                 error = function(e) NULL)
  if (is.null(df) || ncol(df) <= 1) {
    df <- tryCatch(readr::read_delim(path, delim = "\\s+",
                                     show_col_types = FALSE, progress = FALSE),
                   error = function(e) NULL)
  }
  if (is.null(df)) return(tibble())
  names(df) <- trimws(names(df))
  df |> mutate(across(everything(), ~ if (is.character(.x)) trimws(.x) else .x))
}

nice_palette <- function(n) {
  if (requireNamespace("ggsci", quietly = TRUE)) {
    base <- tryCatch(ggsci::pal_d3("category20")(20), error = function(e) NULL)
    if (!is.null(base)) return(colorRampPalette(base)(n))
    try_pal <- function(fun, k) {
      pal <- tryCatch(fun(k), error = function(e) NULL)
      if (!is.null(pal)) colorRampPalette(pal)(n) else NULL
    }
    pal <- try_pal(ggsci::pal_npg(), 10); if (!is.null(pal)) return(pal)
    pal <- try_pal(ggsci::pal_lancet(),  9); if (!is.null(pal)) return(pal)
    pal <- try_pal(ggsci::pal_nejm(),    8); if (!is.null(pal)) return(pal)
  }
  if (requireNamespace("RColorBrewer", quietly = TRUE)) {
    base <- RColorBrewer::brewer.pal(12, "Set3")
    return(colorRampPalette(base)(n))
  }
  scales::hue_pal(l = 60, c = 100)(n)
}

# ---------- 1) read + combine ----------
stopifnot(dir.exists(pop_dir))
files <- list.files(pop_dir, pattern = "\\.tsv$", full.names = TRUE)
if (!length(files)) stop("No .tsv files found in: ", pop_dir)

df_all <- files |> lapply(read_one_tsv) |> bind_rows(.id = "file_id")
if (nrow(df_all) == 0) stop("All TSVs empty in: ", pop_dir)

# keep only feasible 
feas_col <- names(df_all)[tolower(names(df_all)) == "feasible"]
if (length(feas_col) == 1) {
  df_all <- df_all |> filter(tolower(.data[[feas_col]]) %in% c("true","t","1","yes","y"))
  if (nrow(df_all) == 0) stop("No feasible rows after filtering.")
}
#legend_title  <- paste0(legend_target, "\n", "\n", "Left Populations:")

# ---- legend title & labels ----
tgt_col <- names(df_all)[tolower(names(df_all)) == "target"]
target_raw <- if (length(tgt_col) == 1) unique(na.omit(df_all[[tgt_col]]))[1] else "Target"
legend_target <- gsub("_", " ", target_raw, fixed = TRUE)
legend_title  <- paste0(legend_target, "\n", "\n", "Left Populations:")
pretty_labels <- function(x) gsub("_", " ", x, fixed = TRUE)

# add n_lefts (how many left_* per row)
left_cols   <- grep("^left_\\d+$", names(df_all), value = TRUE, ignore.case = TRUE)
weight_cols <- grep("^weight_\\d+$", names(df_all), value = TRUE, ignore.case = TRUE)
if (!length(left_cols))   stop("No left_* columns.")
if (!length(weight_cols)) stop("No weight_* columns.")

df_all <- df_all %>%
  mutate(
    n_lefts = rowSums(across(all_of(left_cols), function(x) {
      x <- as.character(x)
      !is.na(x) & x != "" & tolower(x) != "na"
    }))
  )

# ---------- 2) long table ----------
df_long_left <- df_all |>
  mutate(row_id = row_number()) |>
  select(row_id, n_lefts, all_of(left_cols)) |>
  pivot_longer(cols = all_of(left_cols),
               names_to = "left_idx", values_to = "left") |>
  mutate(idx = readr::parse_number(left_idx))

df_long_weight <- df_all |>
  mutate(row_id = row_number()) |>
  select(row_id, all_of(weight_cols)) |>
  pivot_longer(cols = all_of(weight_cols),
               names_to = "weight_idx", values_to = "weight") |>
  mutate(idx = readr::parse_number(weight_idx),
         weight = suppressWarnings(as.numeric(weight)))

long_df <- df_long_left |>
  left_join(df_long_weight, by = c("row_id", "idx")) |>
  mutate(left = trimws(left)) |>
  filter(!is.na(left), left != "", tolower(left) != "na")

# ---------- 3) normalize for plotting ----------
long_df <- long_df |>
  mutate(weight_plot = ifelse(is.na(weight), 0, weight),
         weight_plot = pmax(weight_plot, 0)) |>
  group_by(row_id, n_lefts) |>
  mutate(sum_pos = sum(weight_plot, na.rm = TRUE),
         weight_plot = if_else(sum_pos > 0, weight_plot / sum_pos, 0)) |>
  ungroup() |>
  select(-sum_pos)

# ---------- 4) GLOBAL pop_order (legend/columns). Use mean weight, or set your own.
pop_order <- long_df %>%
  group_by(left) %>%
  summarise(m = mean(weight_plot, na.rm = TRUE), .groups = "drop") %>%
  arrange(desc(m)) %>% pull(left)

long_df <- long_df %>% mutate(left = factor(left, levels = pop_order))

# ---------- 5) winner per row ----------
top_by_row <- long_df %>%
  group_by(row_id, n_lefts) %>%
  arrange(desc(weight_plot), idx, .by_group = TRUE) %>%
  summarise(top_left = first(left), top_w = first(weight_plot), .groups = "drop")

# ---------- 6) segments — stack by pop_order; draw leftmost with Option A (reverse levels only for plotting) ----------
segments <- long_df %>%
  group_by(row_id, n_lefts) %>%
  arrange(left, .by_group = TRUE) %>%                     
  mutate(
    xmin = lag(cumsum(weight_plot), default = 0),
    xmax = cumsum(weight_plot),
    left_plot = factor(left, levels = rev(pop_order))     
  ) %>%
  ungroup()

# ---------- 7) ROW ORDER: sort by winner according to pop_order, but put winners at the TOP ----------
row_order <- top_by_row %>%
  mutate(top_left = factor(top_left, levels = pop_order)) %>%
  arrange(n_lefts, top_left, desc(top_w), row_id) %>%      
  group_by(n_lefts) %>%
  mutate(n_rows = n(),
         y = n_rows - row_number() + 1) %>%                
  ungroup() %>%
  select(row_id, n_lefts, y)

segments <- segments %>% left_join(row_order, by = c("row_id","n_lefts"))

# ---------- palette ----------
cols <- nice_palette(length(pop_order)); names(cols) <- pop_order

# ---------- legend sizing ----------
n_pops <- length(pop_order)
legend_text_size  <- max(9, min(14, 13 - 0.05 * (n_pops - 8)))
legend_title_size <- max(11, min(16, 15 - 0.03 * (n_pops - 8)))
legend_key_h <- unit(max(8, 16 - 0.3 * (n_pops - 8)), "pt")
legend_key_w <- unit(max(8, 16 - 0.3 * (n_pops - 8)), "pt")
legend_text_size  <- max(11, min(18, 15 - 0.03 * (n_pops - 8)))
legend_title_size <- max(13, min(20, 18 - 0.02 * (n_pops - 8)))
legend_key_h <- unit(max(10, 20 - 0.2 * (n_pops - 8)), "pt")
legend_key_w <- unit(max(10, 20 - 0.2 * (n_pops - 8)), "pt")

#legend_text_size  <- max(14, min(24, 20 - 0.02 * (n_pops - 8)))
#legend_title_size <- max(16, min(28, 24 - 0.015 * (n_pops - 8)))
#legend_key_h <- unit(max(14, 28 - 0.15 * (n_pops - 8)), "pt")
#legend_key_w <- unit(max(14, 28 - 0.15 * (n_pops - 8)), "pt")

# ---------- LEFT PANEL ----------
rows_df <- segments |> distinct(n_lefts, y, row_id)

dot_grid <- tidyr::crossing(
  rows_df,
  left = factor(pop_order, levels = pop_order)
) |>
  mutate(x = as.integer(left)) |>
  tidyr::drop_na(y, x)

present_df <- segments |> distinct(n_lefts, y, left) |> mutate(present = TRUE)

dot_df <- dot_grid |>
  left_join(present_df, by = c("n_lefts","y","left")) |>
  mutate(present = !is.na(present))

sq_h <- 1.00; sq_w <- 0.995

p_left <- ggplot() +
  geom_tile(data = dot_df, aes(x = x, y = y), width = sq_w, height = sq_h,
            fill = "grey92", color = NA) +
  geom_tile(data = dplyr::filter(dot_df, present),
            aes(x = x, y = y, fill = left), width = sq_w, height = sq_h, color = NA) +
  facet_grid(n_lefts ~ ., scales = "free_y", space = "free_y",
             labeller = labeller(n_lefts = function(x) paste0(x, "-way"))) +
  geom_hline(data = rows_df, aes(yintercept = y + 0.5),
             color = "grey30", linewidth = 0.05) +
  geom_vline(xintercept = seq(0.5, length(pop_order) + 0.5, 1),
             color = "grey30", linewidth = 0.05) +
  scale_fill_manual(values = cols, limits = pop_order, drop = FALSE, guide = "none") +
  scale_x_continuous(breaks = NULL, expand = expansion(mult = 0)) +
  scale_y_continuous(expand = expansion(mult = 0)) +
  labs(x = NULL, y = NULL) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid       = element_blank(),
    panel.spacing.y  = unit(2, "pt"),
    panel.spacing    = unit(0, "pt"),
    panel.border     = element_rect(color = "black", fill = NA, linewidth = 0.5),
    strip.text.y     = element_blank(),
    strip.background = element_blank(),
    axis.text        = element_blank(),
    axis.ticks       = element_blank(),
    plot.margin      = margin(6, 0, 6, 6)
  )

# ---------- RIGHT PANEL ----------
bars <- segments |>
  mutate(xmid = (xmin + xmax) / 2, w = pmax(0, xmax - xmin)) |>
  filter(w > 0)

p_right <- ggplot(bars, aes(fill = left_plot)) +
  geom_tile(aes(x = xmid, y = y, width = w, height = 1.00), color = NA) +
  facet_grid(
    n_lefts ~ .,
    scales = "free_y",
    space  = "free_y",
    labeller = labeller(n_lefts = function(x) paste0(x, "-way"))
  ) +
  scale_fill_manual(
    values = cols, limits = rev(pop_order), drop = FALSE,
    name = legend_title, labels = pretty_labels
  ) +
  guides(fill = guide_legend(ncol = 1, byrow = FALSE, reverse = TRUE)) +
  scale_x_continuous(limits = c(0, 1.0005), breaks = seq(0, 1, by = 0.25),
                     expand = expansion(mult = c(0, 0))) +
  scale_y_continuous(expand = expansion(mult = 0)) +
  labs(x = NULL, y = NULL) +
  geom_hline(data = rows_df, aes(yintercept = y + 0.5),
             color = "black", linewidth = 0.05) +
  theme_minimal(base_size = 12) +
  theme(
    legend.title        = element_text(face = "bold", size = legend_title_size),
    legend.text         = element_text(size = legend_text_size),
    legend.key.height   = legend_key_h,
    legend.key.width    = legend_key_w,
    panel.grid.major.x  = element_line(color = "grey90", linewidth = 0.35),
    panel.grid.minor.x  = element_line(color = "grey94", linewidth = 0.3),
    panel.grid.major.y  = element_blank(),
    panel.grid.minor.y  = element_blank(),
    panel.spacing.y     = unit(2, "pt"),
    panel.spacing       = unit(0, "pt"),
    panel.border        = element_rect(color = "black", fill = NA, linewidth = 0.5),
    
    # --- right-side row strip: horizontal text ---
    strip.placement     = "outside",
    strip.background    = element_rect(fill = "snow2", color = "black", linewidth = 0.5),
    strip.text.y.right  = element_text(face = "bold", size = 12, angle = 0, hjust = 0.5, vjust = 0.5),
    
    axis.text.y         = element_blank(),
    axis.text.x         = element_text(size = 12),
    axis.ticks.y        = element_blank(),
    plot.margin         = margin(6, 6, 6, 0)
  )

# ---------- combine ----------

left_width <- max(0.7, length(pop_order) * 0.15)
p_all <- p_left + p_right +
  plot_layout(widths = c(left_width, 6), guides = "collect") &
  theme(legend.justification = c("right", "top"))
p_all <- p_left + p_right +
  plot_layout(widths = c(left_width, 6), guides = "collect") &
  theme(
    legend.text       = element_text(size = 9),  
    legend.title      = element_text(size = 10),  
    legend.key.height = unit(10, "pt"),           
    legend.key.width  = unit(10, "pt"),
    legend.spacing.y  = unit(1, "pt"),             
    legend.justification = c("right", "top")
 )

if (add_plot_title) p_all <- p_all + plot_annotation(title = legend_target)

print(p_all)

# ---------- save ----------
rows_per_facet <- segments %>% group_by(n_lefts) %>% summarise(rows = max(y), .groups = "drop")
total_rows <- sum(rows_per_facet$rows, na.rm = TRUE)

pdf_width  <- 15

pdf_height <- max(1.5, min(0.12 * total_rows, 50))

#print(pdf_height)
if (!is.null(out_pdf)) {
  # Save PDF
  if (capabilities("cairo")) {
    ggsave(out_pdf, p_all, width = pdf_width, height = pdf_height,
           device = cairo_pdf, limitsize = FALSE)
  } else {
    ggsave(out_pdf, p_all, width = pdf_width, height = pdf_height, limitsize = FALSE)
  }
  message("Saved to: ", normalizePath(out_pdf, mustWork = FALSE))
  
  # Save PNG (same name but with .png extension)
  out_png <- sub("\\.pdf$", ".png", out_pdf)
  ggsave(out_png, p_all, width = pdf_width, height = pdf_height,
         dpi = 300, device = "png", limitsize = FALSE)
  message("Saved PNG to: ", normalizePath(out_png, mustWork = FALSE))
}