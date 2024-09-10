#!/bin/bash
# This script serves as the main tool for generating labeled bar plots in an Upset-like style. 
# It processes QPADM output files by filtering the data, keeping only rows where the third column contains all-zero values.
# After filtering, it creates visualizations, offering multipleplotting methods to display the data effectively.
# Filtering QPADM -> Plotting
# Paths
target_dir="/path/to/target/directory/" # Where files will be saved
input_qpadm="/path/to/input/qpadm/directory/" # Directory of qpadm files
script_path="/path/to/scripts/directory/" # Where the scripts folder is located
N_T=10 # Number of cores ( For parallel plotting )

bold=$(tput bold)
normal=$(tput sgr0)

# Create necessary directories
mkdir -p $target_dir
pushd $target_dir
mkdir -p Filter_QPADM ParPlots
popd
echo "${bold}Filtering...${normal}"
# Perform filtering using Python script
python3 "${script_path}/filter_nonzero.py" $input_qpadm ${target_dir}/Filter_QPADM

# Make directories based on OUTQPADM entries for plotting
pushd ${target_dir}/Filter_QPADM

echo "${bold}Files emptied after filtering:${normal}"
find . -type f -empty -print -delete # Finds empty files and deletes them

# Takes unique names
ls *_filtered.OUTQPADM | sed -n 's/^[^-]*-[^-]*-[^-]*-\(.*\).OUTQPADM_.*/\1/p' > tmp.list
sort tmp.list | uniq > targets.list
rm tmp.list
# Takes unique runs
ls *_filtered.OUTQPADM | sed -n 's/^\([^-]*-[^-]*-[^-]*\)-.*\.OUTQPADM.*/\1/p' > tmp.list
sort tmp.list | uniq > runs.list
rm tmp.list

# Organize files into directories for each target
for i in $(cat targets.list); do
    mkdir -p "$i"
    find . -maxdepth 1 -type f -name "*$i*" -exec mv "{}" "$i/" \;
    output_pdir="${target_dir}/ParPlots/$i"
    mkdir -p "$output_pdir"
done
popd

# Define the plotting function
func_plotting() {
    local target="$1"
    local output_pdir="${target_dir}/ParPlots/$target"
    Rscript "${script_path}/HDPlotting.R" "${target_dir}/Filter_QPADM/$target" "$output_pdir" "HD_${target}.png" "${target_dir}/Filter_QPADM/" # For Haplo & Diplo
    Rscript "${script_path}/DPlotting.R" "${target_dir}/Filter_QPADM/$target" "$output_pdir" "D_${target}.png" "${target_dir}/Filter_QPADM/" # For Diplo
    Rscript "${script_path}/HPlotting.R" "${target_dir}/Filter_QPADM/$target" "$output_pdir" "H_${target}.png" "${target_dir}/Filter_QPADM/" # For Haplo
    Rscript "${script_path}/main_Plotting.R" "${target_dir}/Filter_QPADM/$target" "$output_pdir" "main_${target}.png" "${target_dir}/Filter_QPADM/" # For Haplot with x labels modifications
    
}

# Run the plotting function in parallel
export -f func_plotting
export N_T
export script_path
export target_dir
echo "${bold}Plotting...${normal}"
cat ${target_dir}/Filter_QPADM/targets.list | parallel -j "$N_T" func_plotting {}

# cleanup
unset func_plotting
unset N_T
unset script_path
unset target_dir

echo "${bold}Script Completed${normal}"



    
    
