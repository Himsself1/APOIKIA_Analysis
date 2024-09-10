# Reads ancIBD output and plots shared IBDs in a distance matrix
# Excludes individuals of no interest. It also can plot the samples in a
# user defined order (e.g. chronological order)
# Needs the .csv output


import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np


def convert(filename, column1, column2=None):

    # Read .csv ancIBD output
    data = pd.read_csv(filename, sep=",")
    
    # Exclude individuals of no interest, in this case individuals with <0.25X
    exclude = ['Amv_Epi_Cl_3', 'Amv_Epi_Hel_2', 'Amv_Epi_LateCl_to_Hel', 'Ten_Pel_Rom_4']
    
    # Identify all unique samples from the original data
    all_samples = set(data['iid1']).union(set(data['iid2']))
    
    # Filter the data
    grouped = data[(~data['iid1'].isin(exclude)) & (~data['iid2'].isin(exclude))]
    
    # Calculate pairwise shared IBDs within each category
    if column2 is None:
        grouped['distance'] = grouped[column1]
    else:
        grouped['distance'] = grouped[column1] - grouped[column2]

    # Ensure idx includes all samples
    idx = sorted(all_samples)
    
    # Create the pivot table
    new = (grouped.pivot(index='iid1', columns='iid2', values='distance')
           .reindex(index=idx, columns=idx)
           .fillna(0, downcast='infer')
           .pipe(lambda x: x + x.values.T)
    )
    
    return new
    
def plot_heatmap(distance_matrix1, distance_matrix2, preferred_order, savename):

    # Set font size
    sns.set(font_scale=1.1)


    # Load data
    df1 = pd.DataFrame(distance_matrix1, index=preferred_order, columns=preferred_order)
    df2 = pd.DataFrame(distance_matrix2, index=preferred_order, columns=preferred_order)

    # Compute correlation matrices (if not already computed)
    corr1 = df1
    corr2 = df2

    # Create masks
    mask1 = np.tril(np.ones_like(corr1, dtype=bool))
    mask2 = np.triu(np.ones_like(corr2, dtype=bool))

    # Create a figure and axis
    fig, ax = plt.subplots(figsize=(12, 10))

    # Determine the range of the colorbar based on the combined data
    vmin = min(corr1.min().min(), corr2.min().min())
    vmax = max(corr1.max().max(), corr2.max().max())

    # Plot heatmaps with shared colorbar
    sns.heatmap(corr2, mask=mask1, cmap='viridis', vmin=vmin, vmax=vmax,
            square=True, cbar_kws={"shrink": .85}, ax=ax)
    sns.heatmap(corr1, mask=mask2, cmap='viridis', vmin=vmin, vmax=vmax,
            square=True, cbar=False, ax=ax)

    # Customize the plot
    plt.tick_params(axis='y', which='both', left=False, right=False)
    plt.tick_params(axis='x', which='both', bottom=False, top=False)
    plt.xlabel('')
    plt.ylabel('')
    plt.tight_layout()

    # Save the figure
    plt.savefig(savename, dpi=200)


# Example usage:

preferred_order = ['Amm_Epi_LBA_1', 'Amm_Epi_LBA_2', 'Amv_Epi_Arch_1', 'Amv_Epi_Arch_2', 'Amv_Epi_Arch_3', 'Amv_Epi_Archaic_to_Roman', 'Amv_Epi_Cl_1', 'Amv_Epi_Cl_2', 'Amv_Epi_Cl_4', 'Amv_Epi_Cl_5', 'Amv_Epi_Cl_6', 'Amv_Epi_Hel_1', 'Amv_Epi_Hel_3', 'Amv_Epi_Hel_4', 'Ten_Pel_Arch_1', 'Ten_Pel_Arch_2', 'Ten_Pel_Hel_1', 'Ten_Pel_Hel_2', 'Ten_Pel_LHellenistic_ERoman', 'Ten_Pel_Rom_1', 'Ten_Pel_Rom_2', 'Ten_Pel_Rom_3']  # Replace with your preferred order

mydata = 'ancIBD_output.csv'

matrix1 = convert(mydata, 'n_IBD>8', 'n_IBD>12')
matrix2 = convert(mydata, 'n_IBD>12', 'n_IBD>16')
matrix3 = convert(mydata, 'n_IBD>16', 'n_IBD>20')
matrix4 = convert(mydata, 'n_IBD>20')

plot_heatmap(matrix1, matrix2, preferred_order, 'IBD_number_816_removed_0.25X.png')
plot_heatmap(matrix3, matrix4, preferred_order, 'IBD_number_1620_removed_0.25X.png')

