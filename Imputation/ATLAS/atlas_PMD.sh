#Script for PMD estimation

#Requires a Fasta reference file

#No need to previously split RGs by length in our case
#as we have merged Paired-End reads.

FASTA=/PATH/TO/FASTA/REFERENCE/FILE


atlas task=PMD bam=$1 fasta=$FASTA length=50
