#! /usr/bin/bash

# * File Names

META_FILE="/home/aggeliki/apoikia/EIGENSTRAT/dataset_04_05_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/no_moroccans/apoikia.1240K.ANCIENT.LD_200_25_04.trimmed.geno_08.fam"
LABELS="~/apoikia/APOIKIA_Analysis/admixture_analysis/Layers_for_Admixture_04_05_2024.csv"

# ** Geno 08

INPUT_FOLDER_04_GENO_08="~/apoikia/admixture_logs/dataset_04_05_2024/haploid_no_paleo/LD_04/geno_08"
PLOT_FOLDER_04_GENO_08="~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_no_morrocans/no_maf/LD_04/geno_08"
INPUT_FOLDER_06_GENO_08="~/apoikia/admixture_logs/dataset_04_05_2024/haploid_no_paleo/LD_06/geno_08"
PLOT_FOLDER_06_GENO_08="~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_no_morrocans/no_maf/LD_06/geno_08"
INPUT_FOLDER_08_GENO_08="~/apoikia/admixture_logs/dataset_04_05_2024/haploid_no_paleo/LD_08/geno_08"
PLOT_FOLDER_08_GENO_08="~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_no_morrocans/no_maf/LD_08/geno_08"

Rscript plot_admixture_04_05_2024_updated_layers.R \
	-input_folder=$INPUT_FOLDER_04_GENO_08 \
	-plot_folder=$PLOT_FOLDER_04_GENO_08 \
	-label_file=$LABELS \
	-meta=$META_FILE

Rscript plot_admixture_04_05_2024_updated_layers.R \
	-input_folder=$INPUT_FOLDER_06_GENO_08 \
	-plot_folder=$PLOT_FOLDER_06_GENO_08 \
	-label_file=$LABELS \
	-meta=$META_FILE

Rscript plot_admixture_04_05_2024_updated_layers.R \
	-input_folder=$INPUT_FOLDER_08_GENO_08 \
	-plot_folder=$PLOT_FOLDER_08_GENO_08 \
	-label_file=$LABELS \
	-meta=$META_FILE


# ** Geno 06

INPUT_FOLDER_04_GENO_06="~/apoikia/admixture_logs/dataset_04_05_2024/haploid_no_paleo/LD_04/geno_06"
PLOT_FOLDER_04_GENO_06="~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_no_morrocans/no_maf/LD_04/geno_06"
INPUT_FOLDER_06_GENO_06="~/apoikia/admixture_logs/dataset_04_05_2024/haploid_no_paleo/LD_06/geno_06"
PLOT_FOLDER_06_GENO_06="~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_no_morrocans/no_maf/LD_06/geno_06"
INPUT_FOLDER_08_GENO_06="~/apoikia/admixture_logs/dataset_04_05_2024/haploid_no_paleo/LD_08/geno_06"
PLOT_FOLDER_08_GENO_06="~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_no_morrocans/no_maf/LD_08/geno_06"

Rscript plot_admixture_04_05_2024_updated_layers.R \
	-input_folder=$INPUT_FOLDER_04_GENO_06 \
	-plot_folder=$PLOT_FOLDER_04_GENO_06 \
	-label_file=$LABELS \
	-meta=$META_FILE

Rscript plot_admixture_04_05_2024_updated_layers.R \
	-input_folder=$INPUT_FOLDER_06_GENO_06 \
	-plot_folder=$PLOT_FOLDER_06_GENO_06 \
	-label_file=$LABELS \
	-meta=$META_FILE

Rscript plot_admixture_04_05_2024_updated_layers.R \
	-input_folder=$INPUT_FOLDER_08_GENO_06 \
	-plot_folder=$PLOT_FOLDER_08_GENO_06 \
	-label_file=$LABELS \
	-meta=$META_FILE


# ** Geno 04

INPUT_FOLDER_04_GENO_04="~/apoikia/admixture_logs/dataset_04_05_2024/haploid_no_paleo/LD_04/geno_04"
PLOT_FOLDER_04_GENO_04="~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_no_morrocans/no_maf/LD_04/geno_04"
INPUT_FOLDER_06_GENO_04="~/apoikia/admixture_logs/dataset_04_05_2024/haploid_no_paleo/LD_06/geno_04"
PLOT_FOLDER_06_GENO_04="~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_no_morrocans/no_maf/LD_06/geno_04"
INPUT_FOLDER_08_GENO_04="~/apoikia/admixture_logs/dataset_04_05_2024/haploid_no_paleo/LD_08/geno_04"
PLOT_FOLDER_08_GENO_04="~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_no_morrocans/no_maf/LD_08/geno_04"

Rscript plot_admixture_04_05_2024_updated_layers.R \
	-input_folder=$INPUT_FOLDER_04_GENO_04 \
	-plot_folder=$PLOT_FOLDER_04_GENO_04 \
	-label_file=$LABELS \
	-meta=$META_FILE

Rscript plot_admixture_04_05_2024_updated_layers.R \
	-input_folder=$INPUT_FOLDER_06_GENO_04 \
	-plot_folder=$PLOT_FOLDER_06_GENO_04 \
	-label_file=$LABELS \
	-meta=$META_FILE

Rscript plot_admixture_04_05_2024_updated_layers.R \
	-input_folder=$INPUT_FOLDER_08_GENO_04 \
	-plot_folder=$PLOT_FOLDER_08_GENO_04 \
	-label_file=$LABELS \
	-meta=$META_FILE
