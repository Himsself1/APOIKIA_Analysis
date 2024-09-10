#!/bin/python3

# Libraries
import os
import pandas as pd
import sys

# Arguments directed from qpadm_filtering.sh
input_dir = sys.argv[1]
output_dir = sys.argv[2]


# Regex pattern to match any digit from 1 to 9 (Everything but zero)
pattern = r'[1-9]'

# Take files from input dir
files = [f for f in os.listdir(input_dir) if f.endswith(".OUTQPADM")]
print(f"Number of QPADM files: {len(files)}")

for file in files:
    abs_file=sys.argv[1]+file
    qpdm_df = pd.read_csv(abs_file, header=None, delimiter=r"\s+")
    thrd_col = qpdm_df.iloc[:, 2].astype(str)
    
    filtered_rows = qpdm_df[~thrd_col.str.contains(pattern)]
    new_file_name = os.path.join(output_dir, file+"_filtered.OUTQPADM")
    filtered_rows.to_csv(new_file_name, index=False, header=False, sep=' ')
