#! /usr/bin/bash

# * File Names
META_FILE="/home/aggeliki/apoikia/EIGENSTRAT/dataset_04_05_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/no_moroccans/apoikia.1240K.ANCIENT.LD_200_25_06.trimmed.geno_04.fam"
PLOT_FOLDER="~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_no_morrocans/no_maf"
LABELS="~/apoikia/APOIKIA_Analysis/admixture_analysis/Layers_for_Admixture_04_05_2024.csv"
INPUT_FILE_06_GENO_04_K_3="~/apoikia/admixture_logs/dataset_04_05_2024/haploid_no_paleo/LD_06/geno_04/apoikia.1240K.ANCIENT.LD_200_25_06.trimmed.geno_04.3.Q"

Rscript plot_admixture_04_05_2024_updated_layers_figure_2b.R \
	-input_file=$INPUT_FILE_06_GENO_04_K_3 \
	-plot_folder=$PLOT_FOLDER \
	-label_file=$LABELS \
	-meta=$META_FILE
