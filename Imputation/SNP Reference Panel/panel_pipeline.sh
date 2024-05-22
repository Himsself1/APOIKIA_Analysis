#Scripts to filter vcfs (in our case 1KGP),
#and create the input files required by GLIMPSE

mkdir out
mkdir out/alleles
mkdir out/chunks

#FIlters .vcf files
ls *gz | xargs -P 20 -I X bash filter_reference_vcf.sh X
cd out

#Creates .alleles file containing the list of sites for phasing
ls *gz | xargs -P 20 -I X bash get_alleles.sh X

#Creates genomic chunks used by GLIMPSE
ls *gz | xargs -P 20 -I X bash chunks.sh X
