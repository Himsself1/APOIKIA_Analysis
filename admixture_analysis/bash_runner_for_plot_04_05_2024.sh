#! /usr/bin/bash

# * File Names
META_FILE="~/apoikia/EIGENSTRAT/dataset_04_05_2024/APOIKIA_PLUS_PUBLIC_ANCIENT/apoikia.1240K.ANCIENT_maf_005_no_relatives.fam"
LABELS="~/apoikia/APOIKIA_Analysis/admixture_analysis/Layers_for_Admixture_04_05_2024.csv"

# ** No filtering based on missingness (Geno 99)

INPUT_FOLDER_04="~/apoikia/admixture_logs/dataset_04_05_2024/haploid_with_maf_no_relatives/LD_04"
PLOT_FOLDER_04="~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_04_05_2024/maf_005/LD_04/geno_99"
INPUT_FOLDER_06="~/apoikia/admixture_logs/dataset_04_05_2024/haploid_with_maf_no_relatives/LD_06"
PLOT_FOLDER_06="~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_04_05_2024/maf_005/LD_06/geno_99"
INPUT_FOLDER_08="~/apoikia/admixture_logs/dataset_04_05_2024/haploid_with_maf_no_relatives/LD_08"
PLOT_FOLDER_08="~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_04_05_2024/maf_005/LD_08/geno_99"

Rscript plot_admixture_04_05_2024.R \
	-input_folder=$INPUT_FOLDER_04 \
	-plot_folder=$PLOT_FOLDER_04 \
	-label_file=$LABELS \
	-meta=$META_FILE

Rscript plot_admixture_04_05_2024.R \
	-input_folder=$INPUT_FOLDER_06 \
	-plot_folder=$PLOT_FOLDER_06 \
	-label_file=$LABELS \
	-meta=$META_FILE

Rscript plot_admixture_04_05_2024.R \
	-input_folder=$INPUT_FOLDER_08 \
	-plot_folder=$PLOT_FOLDER_08 \
	-label_file=$LABELS \
	-meta=$META_FILE


# ** Geno 08

INPUT_FOLDER_04_GENO_08="~/apoikia/admixture_logs/dataset_04_05_2024/haploid_with_maf_no_relatives/LD_04/geno_08"
PLOT_FOLDER_04_GENO_08="~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_04_05_2024/maf_005/LD_04/geno_08"
INPUT_FOLDER_06_GENO_08="~/apoikia/admixture_logs/dataset_04_05_2024/haploid_with_maf_no_relatives/LD_06/geno_08"
PLOT_FOLDER_06_GENO_08="~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_04_05_2024/maf_005/LD_06/geno_08"
INPUT_FOLDER_08_GENO_08="~/apoikia/admixture_logs/dataset_04_05_2024/haploid_with_maf_no_relatives/LD_08/geno_08"
PLOT_FOLDER_08_GENO_08="~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_04_05_2024/maf_005/LD_08/geno_08"

Rscript plot_admixture_04_05_2024.R \
	-input_folder=$INPUT_FOLDER_04_GENO_08 \
	-plot_folder=$PLOT_FOLDER_04_GENO_08 \
	-label_file=$LABELS \
	-meta=$META_FILE

Rscript plot_admixture_04_05_2024.R \
	-input_folder=$INPUT_FOLDER_06_GENO_08 \
	-plot_folder=$PLOT_FOLDER_06_GENO_08 \
	-label_file=$LABELS \
	-meta=$META_FILE

Rscript plot_admixture_04_05_2024.R \
	-input_folder=$INPUT_FOLDER_08_GENO_08 \
	-plot_folder=$PLOT_FOLDER_08_GENO_08 \
	-label_file=$LABELS \
	-meta=$META_FILE


# ** Geno 06

INPUT_FOLDER_04_GENO_06="~/apoikia/admixture_logs/dataset_04_05_2024/haploid_with_maf_no_relatives/LD_04/geno_06"
PLOT_FOLDER_04_GENO_06="~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_04_05_2024/maf_005/LD_04/geno_06"
INPUT_FOLDER_06_GENO_06="~/apoikia/admixture_logs/dataset_04_05_2024/haploid_with_maf_no_relatives/LD_06/geno_06"
PLOT_FOLDER_06_GENO_06="~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_04_05_2024/maf_005/LD_06/geno_06"
INPUT_FOLDER_08_GENO_06="~/apoikia/admixture_logs/dataset_04_05_2024/haploid_with_maf_no_relatives/LD_08/geno_06"
PLOT_FOLDER_08_GENO_06="~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_04_05_2024/maf_005/LD_08/geno_06"

Rscript plot_admixture_04_05_2024.R \
	-input_folder=$INPUT_FOLDER_04_GENO_06 \
	-plot_folder=$PLOT_FOLDER_04_GENO_06 \
	-label_file=$LABELS \
	-meta=$META_FILE

Rscript plot_admixture_04_05_2024.R \
	-input_folder=$INPUT_FOLDER_06_GENO_06 \
	-plot_folder=$PLOT_FOLDER_06_GENO_06 \
	-label_file=$LABELS \
	-meta=$META_FILE

Rscript plot_admixture_04_05_2024.R \
	-input_folder=$INPUT_FOLDER_08_GENO_06 \
	-plot_folder=$PLOT_FOLDER_08_GENO_06 \
	-label_file=$LABELS \
	-meta=$META_FILE


# ** Geno 04

INPUT_FOLDER_04_GENO_04="~/apoikia/admixture_logs/dataset_04_05_2024/haploid_with_maf_no_relatives/LD_04/geno_04"
PLOT_FOLDER_04_GENO_04="~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_04_05_2024/maf_005/LD_04/geno_04"
INPUT_FOLDER_06_GENO_04="~/apoikia/admixture_logs/dataset_04_05_2024/haploid_with_maf_no_relatives/LD_06/geno_04"
PLOT_FOLDER_06_GENO_04="~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_04_05_2024/maf_005/LD_06/geno_04"
INPUT_FOLDER_08_GENO_04="~/apoikia/admixture_logs/dataset_04_05_2024/haploid_with_maf_no_relatives/LD_08/geno_04"
PLOT_FOLDER_08_GENO_04="~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_04_05_2024/maf_005/LD_08/geno_04"

Rscript plot_admixture_04_05_2024.R \
	-input_folder=$INPUT_FOLDER_04_GENO_04 \
	-plot_folder=$PLOT_FOLDER_04_GENO_04 \
	-label_file=$LABELS \
	-meta=$META_FILE

Rscript plot_admixture_04_05_2024.R \
	-input_folder=$INPUT_FOLDER_06_GENO_04 \
	-plot_folder=$PLOT_FOLDER_06_GENO_04 \
	-label_file=$LABELS \
	-meta=$META_FILE

Rscript plot_admixture_04_05_2024.R \
	-input_folder=$INPUT_FOLDER_08_GENO_04 \
	-plot_folder=$PLOT_FOLDER_08_GENO_04 \
	-label_file=$LABELS \
	-meta=$META_FILE
