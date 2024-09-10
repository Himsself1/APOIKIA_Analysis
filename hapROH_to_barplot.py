import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import seaborn as sns

# Read the dataset from a CSV file
df = pd.read_csv('test.csv', sep='\t')

# Calculate the ROH length categories and store them in the dataframe
df['4-8 cM'] = df['sum_roh>4'] - df['sum_roh>8']
df['8-12 cM'] = df['sum_roh>8'] - df['sum_roh>12']
df['12-20 cM'] = df['sum_roh>12'] - df['sum_roh>20']

# Prepare the data for plotting
labels = df['iid'].tolist()
s4_8 = df['4-8 cM'].values
s8_12 = df['8-12 cM'].values
s12_20 = df['12-20 cM'].values
s20 = df['sum_roh>20'].values

# Set the width for the bars
width = 0.5

# Create the plot
fig, ax = plt.subplots(figsize=(10, 6))  # Added figsize for better visualization
ax.bar(labels, s4_8, width, label='4-8 cM', color='#0F5390')
ax.bar(labels, s8_12, width, bottom=s4_8, label='8-12 cM', color='#BDDFDF')
ax.bar(labels, s12_20, width, bottom=s4_8 + s8_12, label='12-20 cM', color='#C5AFAE')
ax.bar(labels, s20, width, bottom=s4_8 + s8_12 + s12_20, label='>20 cM', color='#D41F31')

# Rotate the x-axis labels for better readability
plt.xticks(rotation=90)

# Set the y-axis label
ax.set_ylabel('Sum of inferred ROH (>4 cM)')

# Add legend
ax.legend()

# Adjust the x-axis tick parameters
ax.tick_params(axis='x', labelsize=6)

# Remove the top and right spines from the plot
sns.despine()

# Adjust layout for better fit
plt.tight_layout()

# Save the plot as a PNG file with 300 dpi resolution
plt.savefig('ROH_distribution.png', dpi=300)

# Uncomment to display the plot
# plt.show()

