#! /usr/bin/bash

# * File Names
META_FILE="~/apoikia/EIGENSTRAT/dataset_25_27_2025/APOIKIA_PLUS_PUBLIC_ANCIENT_PLUS_OUTGROUPS/trimmed_data_maf_005_no_relatives/apoikia.1240K.ANCIENT_plus_Yoruba_Han.LD_200_25_06.trimmed.geno_04.fam"
PLOT_FOLDER="~/apoikia/APOIKIA_Analysis/admixture_analysis/plots/dataset_25_27_2025/no_maf"
LABELS="~/apoikia/APOIKIA_Analysis/admixture_analysis/Layers_for_Admixture_27_25_2025.csv"
INPUT_FILE_06_GENO_04_K_3="~/apoikia/admixture_logs/dataset_25_27_2025/haploid_no_paleo/LD_06/geno_04/apoikia.1240K.ANCIENT_plus_Yoruba_Han.LD_200_25_06.trimmed.geno_04.3.Q"


/usr/bin/Rscript plot_admixture_25_27_2025_updated_layers_figure_2b.R \
				 -input_file=$INPUT_FILE_06_GENO_04_K_3 \
				 -plot_folder=$PLOT_FOLDER \
				 -label_file=$LABELS \
				 -meta=$META_FILE
