#! /usr/bin/bash

# * File Names

META_FILE="/home/aggeliki/apoikia/EIGENSTRAT/dataset_25_27_2025/APOIKIA_PLUS_PUBLIC_ANCIENT_PLUS_OUTGROUPS/trimmed_data_maf_005_no_relatives/apoikia.1240K.ANCIENT_plus_Yoruba_Han.LD_200_25_04.trimmed.geno_04.fam"
LABELS="/home/aggeliki/apoikia/APOIKIA_Analysis/admixture_analysis/Layers_for_Admixture_27_25_2025.csv"

# ** Geno 08

INPUT_FOLDER_04_GENO_08="~/apoikia/admixture_logs/dataset_25_27_2025/haploid_no_paleo/LD_04/geno_08"
PLOT_FOLDER_04_GENO_08="~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_25_27_2025/no_maf/LD_04/geno_08"
INPUT_FOLDER_06_GENO_08="~/apoikia/admixture_logs/dataset_25_27_2025/haploid_no_paleo/LD_06/geno_08"
PLOT_FOLDER_06_GENO_08="~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_25_27_2025/no_maf/LD_06/geno_08"
INPUT_FOLDER_08_GENO_08="~/apoikia/admixture_logs/dataset_25_27_2025/haploid_no_paleo/LD_08/geno_08"
PLOT_FOLDER_08_GENO_08="~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_25_27_2025/no_maf/LD_08/geno_08"

/usr/bin/Rscript plot_admixture_25_27_2025_updated_layers.R \
	-input_folder=$INPUT_FOLDER_04_GENO_08 \
	-plot_folder=$PLOT_FOLDER_04_GENO_08 \
	-label_file=$LABELS \
	-meta=$META_FILE

/usr/bin/Rscript plot_admixture_25_27_2025_updated_layers.R \
	-input_folder=$INPUT_FOLDER_06_GENO_08 \
	-plot_folder=$PLOT_FOLDER_06_GENO_08 \
	-label_file=$LABELS \
	-meta=$META_FILE

/usr/bin/Rscript plot_admixture_25_27_2025_updated_layers.R \
	-input_folder=$INPUT_FOLDER_08_GENO_08 \
	-plot_folder=$PLOT_FOLDER_08_GENO_08 \
	-label_file=$LABELS \
	-meta=$META_FILE


# ** Geno 06

INPUT_FOLDER_04_GENO_06="~/apoikia/admixture_logs/dataset_25_27_2025/haploid_no_paleo/LD_04/geno_06"
PLOT_FOLDER_04_GENO_06="~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_25_27_2025/no_maf/LD_04/geno_06"
INPUT_FOLDER_06_GENO_06="~/apoikia/admixture_logs/dataset_25_27_2025/haploid_no_paleo/LD_06/geno_06"
PLOT_FOLDER_06_GENO_06="~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_25_27_2025/no_maf/LD_06/geno_06"
INPUT_FOLDER_08_GENO_06="~/apoikia/admixture_logs/dataset_25_27_2025/haploid_no_paleo/LD_08/geno_06"
PLOT_FOLDER_08_GENO_06="~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_25_27_2025/no_maf/LD_08/geno_06"

/usr/bin/Rscript plot_admixture_25_27_2025_updated_layers.R \
	-input_folder=$INPUT_FOLDER_04_GENO_06 \
	-plot_folder=$PLOT_FOLDER_04_GENO_06 \
	-label_file=$LABELS \
	-meta=$META_FILE

/usr/bin/Rscript plot_admixture_25_27_2025_updated_layers.R \
	-input_folder=$INPUT_FOLDER_06_GENO_06 \
	-plot_folder=$PLOT_FOLDER_06_GENO_06 \
	-label_file=$LABELS \
	-meta=$META_FILE

/usr/bin/Rscript plot_admixture_25_27_2025_updated_layers.R \
	-input_folder=$INPUT_FOLDER_08_GENO_06 \
	-plot_folder=$PLOT_FOLDER_08_GENO_06 \
	-label_file=$LABELS \
	-meta=$META_FILE


# ** Geno 04

INPUT_FOLDER_04_GENO_04="~/apoikia/admixture_logs/dataset_25_27_2025/haploid_no_paleo/LD_04/geno_04"
PLOT_FOLDER_04_GENO_04="~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_25_27_2025/no_maf/LD_04/geno_04"
INPUT_FOLDER_06_GENO_04="~/apoikia/admixture_logs/dataset_25_27_2025/haploid_no_paleo/LD_06/geno_04"
PLOT_FOLDER_06_GENO_04="~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_25_27_2025/no_maf/LD_06/geno_04"
INPUT_FOLDER_08_GENO_04="~/apoikia/admixture_logs/dataset_25_27_2025/haploid_no_paleo/LD_08/geno_04"
PLOT_FOLDER_08_GENO_04="~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_25_27_2025/no_maf/LD_08/geno_04"

/usr/bin/Rscript plot_admixture_25_27_2025_updated_layers.R \
	-input_folder=$INPUT_FOLDER_04_GENO_04 \
	-plot_folder=$PLOT_FOLDER_04_GENO_04 \
	-label_file=$LABELS \
	-meta=$META_FILE

/usr/bin/Rscript plot_admixture_25_27_2025_updated_layers.R \
	-input_folder=$INPUT_FOLDER_06_GENO_04 \
	-plot_folder=$PLOT_FOLDER_06_GENO_04 \
	-label_file=$LABELS \
	-meta=$META_FILE

/usr/bin/Rscript plot_admixture_25_27_2025_updated_layers.R \
	-input_folder=$INPUT_FOLDER_08_GENO_04 \
	-plot_folder=$PLOT_FOLDER_08_GENO_04 \
	-label_file=$LABELS \
	-meta=$META_FILE
