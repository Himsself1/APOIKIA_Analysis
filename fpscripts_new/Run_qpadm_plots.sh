#!/bin/bash

# Base directory 
BASE_DIR="/your/filtered/directories"

# Prefix for the PDF names
PREFIX="plot_title_prefix"

# Loop through all subdirectories of BASE_DIR
for pop_dir in "$BASE_DIR"/*; do
    if [ -d "$pop_dir" ]; then
        dir_name=$(basename "$pop_dir")
        out_pdf="${PREFIX}${dir_name}.pdf"

        echo "Running: Rscript qpadm_plots.R \"$pop_dir\" \"$out_pdf\""
        Rscript qpadm_plots.R "$pop_dir" "$out_pdf"
    fi
done
