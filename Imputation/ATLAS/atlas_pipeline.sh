
#PMD estimation step
ls *.bam | xargs -P 20 -I X bash atlas_PMD.sh X

#Create a dummy .list file for the next step
#It helps splitting chromosomes during SNP calling
for i in *bam; do for j in {1..22}; do echo ${j}_$i >> chromosome_bam.list; done; done

#SNP calling step
#10 chromosomes in parallel
#Depending on the available amount of RAM this number can be changed. 
cat chromosome_bam.list | xargs -P 10 -I Z bash atlas_callMLE.sh Z



