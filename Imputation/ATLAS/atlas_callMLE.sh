#Script for ATLAS Maximum Likelihood-based calling function.

#Requires:
#-the path to FASTA .fa file
#-the path to the .alleles files that contain the sites for the calling to be made
#(one file per each chromosome, with the chromosome number within the file name)


FASTA=/PATH/TO/FASTA/REFERENCE/FILE
bam=$(echo $1 | cut -f2 -d'_')
chr=$(echo $1 | cut -f1 -d'_')
nam=$(echo $1 | cut -f2 -d'_' | cut -f1 -d'.')


mkdir CALLS

atlas task=call method=MLE bam=$1 fasta=$FASTA infoFields=DP formatFields=GT,AD,AB,AI,DP,GQ,PL,GL pmdFile=${bam/.bam/_PMD_input_Empiric.txt} alleles=./ALLELES/ALL.chr${chr}.phase3_shapeit2_mvncall_integrated_v5b.20130502.alleles sampleName=$nam noTriallelic printAll vcf trim5=2 trim3=2 out=CALLS/$nam.$chr chr=$chr
