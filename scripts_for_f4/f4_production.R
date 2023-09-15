library(admixr)
## install.packages("Hmisc")
library(Hmisc)
library(admixtools)


##### Generates an EIGENSTRAT formatted dataset with the ones I want
## a) Find out yoruban indexes
## b) Use the indexes of apoikiaYorMyc for tests

##### Read datasets #####
yor = read_packedancestrymap( '~/apoikia/EIGENSTRAT/HumanOriginsPublic2068', pops='Yoruba' )
data = read_packedancestrymap( '~/apoikia/EIGENSTRAT/APOIKIA_ClementeAncient_LazaridisModern' )

##### There are some individuals marked as "Ignore" #####
ignored <- -which( data$ind[[3]] == "Ignore" )
clean_data_genomes <- data$geno[,ignored]
clean_data_indexes <- data$ind[ignored,]

##### Find out common SNPs #####
snps_in_yorubans_indexes <- which(yor$snp[[1]] %in% data$snp[[1]])
yoruban_geno <- yor$geno[snps_in_yorubans_indexes,]

##### Add Yoruban genomes and SNPs to Ancient #####
all_genomes <- cbind(clean_data_genomes, yoruban_geno)
all_indexes <- rbind(clean_data_indexes, yor$ind )

apoikia_timed_indexes <- read.table( "~/apoikia/EIGENSTRAT/apoikiaYorMyc2.ind",
                                    header = F, sep = '\t' ) ## Better indexes for apoikia
in_all_data <- match( apoikia_timed_indexes[,1], all_indexes[[1]] )

all_indexes[[3]][in_all_data] <- apoikia_timed_indexes[,3] ## Assign the better indexes

##### Write new dataset #####
write_geno( as.data.frame(all_genomes),
           "~/apoikia/data_manipulations/clement_lazaridis_modern_clean.geno" )
write_snp( as.data.frame(data$snp),
          "~/apoikia/data_manipulations/clement_lazaridis_modern_clean.snp" )
write_snp( as.data.frame(all_indexes),
          "~/apoikia/data_manipulations/clement_lazaridis_modern_clean.ind" )

##########################################################################
##########################################################################
###################### Analysis Starts Here ##############################
##########################################################################
##########################################################################

#### Remove Low Converage Data
## to_ignore <- c("Amvrakia_Hel_175-125BCE_0.67Χ_ΧΧ_mother_of_9_1",
##                "Amvrakia_Archaic-to-Roman_0.38Χ_ΧΥ",
##                "5_1_lys3_ex2_L1 U Amvrakia_LateCl_to_Hel_425-100BCE_0.15X_XX",
##                "Amvrakia_Hel_250-200BCE_0.07X_XY",
##                "Tenea_Rom_27BCE-476CE_0.11X_XX",
##                "Amvrakia_Hel_200-125BCE_0.32X_XX",
##                "Amvrakia_Cl_400-375BCE_0.05X_XX",
##                "Amvrakia_Cl_450_425BCE_0.29X_XY",
##                "MODERN")

## The vector here is cosmetic; it is not used downstream
ind_apoikia_names_ignore <- c("8_1_lys1_ex2_L1",
                              "7_2_lys2_ex2_L1",
                              "163_lys1_ex2_L1",
                              "16_2_lys3_ex2_L1",
                              "161_lys1_ex2_L1",
                              "14_3_lys1_ex2_L1",
                              "131_1_lys1_ex2_L1",
                              "128_2_lys2_ex2_L1"
                              )

## Read indexes and pick which individuals will be in the analysis
real_indexes <- read.table("~/apoikia/data_manipulations/clement_lazaridis_modern_clean.ind", header = F, sep = '\t')
original_names <- data$ind
actual_names <- which(original_names[[3]] == "Ignore")
ignored <- which( real_indexes[,1] %in% ind_apoikia_names_ignore )
ignored <- c( ignored, which( real_indexes[,3] == "MODERN" ) )
ignored <- c( ignored, which( real_indexes[,3] %in% c( "WHG","EHG", "CHG", "SHG", "Iran_HotuIIIb", "Europe_EN" ) ) )
ignored <- c( ignored, which( real_indexes[,3] %in% c( "Anatolia_Tepecik_N", "Europe_MNChL" ) ) )
vector_of_final_pops <- real_indexes[[3]][-ignored]
vector_of_final_inds <- real_indexes[[1]][-ignored]

## Balkans_N == Balkans_Cl
## vector_of_final_pops[ vector_of_final_pops %in% c( "Balkans_N", "Balkans_Chl" )] <- "Balkans_N_Cl"
## vector_of_final_pops[ vector_of_final_pops %in% c( "Balkans_LBA", "Balkans_EBA" )] <- "Balkans_EBA_LBA"
## vector_of_final_pops[ vector_of_final_pops %in% c( "Tenea_EarlyRom", "Tenea_Rom" )] <- "Tenea_Roman_All"
## vector_of_final_pops[ vector_of_final_pops %in% c( "Armenia_MLBA", "Armenia_EBA" )] <- "Armenia_MLBA_EB"
## vector_of_final_pops[ vector_of_final_pops %in% c( "Anatolia_ChL", "Anatolia_BA" )] <- "Anatolia_Chl_BA"

## Will calculate f2 blocks for all possible combinations
## Will only take SNPs that are present in all populations
prefic_data <- "~/apoikia/data_manipulations/clement_lazaridis_modern_clean"
f2_blocks <- f2_from_geno(prefic_data,
                          inds = vector_of_final_inds, pops = vector_of_final_pops,
                          adjust_pseudohaploid = TRUE)
f4_initial <- as.data.frame(f4(f2_blocks,
                               "Yoruba",
                               c("Greece_N"),
                               c("Tenea_Hel", "Tenea_Arch", "Tenea_Roman_All", "Ammotopos_LBA"),
                               c( "Amvrakia_Hel", "Amvrakia_LateCl", "Amvrakia_Arch", "Amvrakia_Cl" ) ) )
f4_inverted <- as.data.frame(f4(f2_blocks,
                                "Yoruba",
                                c( "Amvrakia_Hel", "Amvrakia_LateCl", "Amvrakia_Arch", "Amvrakia_Cl" ),
                                "Greece_N",
                                c("Tenea_Hel", "Tenea_Arch", "Tenea_Roman_All", "Ammotopos_LBA") )) 


write.table( f4_initial, "~/apoikia/f4_outputs/initial_f4.tsv", quote = FALSE, sep = '\t',
            row.names = FALSE, col.names = TRUE )
write.table( f4_inverted, "~/apoikia/f4_outputs/initial_inverted_f4.tsv", quote = FALSE, sep = '\t',
            row.names = FALSE, col.names = TRUE )

## Concatenate Ambrakia and Tenea
concat_vector <- vector_of_final_pops
concat_vector[ concat_vector %in% c( "Amvrakia_LateCl", "Amvrakia_Cl" )] <- "Amvrakia_Cl_LateCl"
concat_vector[ concat_vector %in% c( "Amvrakia_Hel", "Amvrakia_Arch" )] <- "Amvrakia_Hel_Arch"
concat_vector[ concat_vector %in% c( "Tenea_Hel", "Tenea_Arch" )] <- "Tenea_Hel_Arch"

f2_blocks_concat <- f2_from_geno(prefic_data,
                                 inds = vector_of_final_inds, pops = concat_vector,
                                 adjust_pseudohaploid = TRUE)

f4_concat <- as.data.frame(f4(f2_blocks_concat,
                              "Yoruba",
                              "Greece_N",
                              c("Tenea_Hel_Arch", "Tenea_Roman_All", "Ammotopos_LBA"),
                              c( "Amvrakia_Hel_Arch", "Amvrakia_Cl_LateCl" ) ) )

f4_concat_inverted <- as.data.frame(f4(f2_blocks_concat,
                                       "Yoruba",
                                       c("Tenea_Hel_Arch", "Tenea_Roman_All", "Ammotopos_LBA"),
                                       "Greece_N",
                                       c( "Amvrakia_Hel_Arch", "Amvrakia_Cl_LateCl" ) ) )

write.table( f4_concat, "~/apoikia/f4_outputs/concatenated_f4.tsv", quote = FALSE, sep = '\t',
            row.names = FALSE, col.names = TRUE )
write.table( f4_concat_inverted, "~/apoikia/f4_outputs/concatenated_inverted_f4.tsv",
            quote = FALSE, sep = '\t',
            row.names = FALSE, col.names = TRUE )


######################### Calculate f2 blocks only for the 4 populations that will go to f4 every time ######################### 
prefic_data <- "~/apoikia/data_manipulations/clement_lazaridis_modern_clean"
real_indexes <- read.table("~/apoikia/data_manipulations/clement_lazaridis_modern_clean.ind", header = F, sep = '\t')

pop1 <- c("Yoruba")
pop2 <- c("Greece_LBA_Mycenaean", "Greece_N", "Ammotopos_LBA")
pop3 <- c("Tenea_Hel", "Tenea_Arch", "Tenea_EarlyRom", "Tenea_Rom")
pop4 <- c("Amvrakia_Hel", "Amvrakia_LateCl", "Amvrakia_Arch", "Amvrakia_Cl")

all_combinations <- expand.grid( "pop1" = pop1, "pop2" = pop2, "pop3" = pop3, "pop4" = pop4,
                                stringsAsFactors = F )
inverted_combinations <- expand.grid( "pop1" = pop1, "pop2" = pop3, "pop3" = pop2, "pop4" = pop4,
                                stringsAsFactors = F )

## Do not exclude low coverage from this calculation

vector_of_final_pops <- real_indexes[[3]]
vector_of_final_inds <- real_indexes[[1]]

## vector_of_final_pops[ vector_of_final_pops %in% c( "Tenea_EarlyRom", "Tenea_Rom" )] <- "Tenea_Roman_All"

all_snp_f4 <- t(sapply(1:nrow(all_combinations),
                       function(x) score_4(all_combinations[x,], vector_of_final_pops,
                                           vector_of_final_inds, prefic_data) ) )

write.table( all_snp_f4,
            "~/apoikia/f4_outputs/f4_marginal_more_romans_common_SNPs.tsv",
            quote = FALSE, sep = '\t',
            row.names = FALSE, col.names = TRUE )

##### Same analysis  as (pop1-pop3)*(pop2-pop4)
all_snp_f4_inverted <- t(sapply(1:nrow(inverted_combinations),
                                function(x) score_4(inverted_combinations[x,], vector_of_final_pops,
                                                    vector_of_final_inds, prefic_data) ) )

write.table( all_snp_f4_inverted,
            "~/apoikia/f4_outputs/f4_marginal_more_romans_common_SNPs_inverted.tsv",
            quote = FALSE, sep = '\t',
            row.names = FALSE, col.names = TRUE )


##### Check for Roman Tenea ######
temp_pops <- vector_of_final_pops[vector_of_final_pops %in% c("Yoruba", "Greece_LBA_Mycenaean", "Tenea_EarlyRom", "Tenea_Rom")]
temp_inds <- vector_of_final_inds[vector_of_final_pops %in% c("Yoruba", "Greece_LBA_Mycenaean", "Tenea_EarlyRom", "Tenea_Rom")]
temp_f2 <- f2_from_geno(prefic_data,
                        inds = temp_inds, pops = temp_pops, maxmiss = 0.1,
                        adjust_pseudohaploid = TRUE)
temp_snps <- count_snps(temp_f2)
temp_f4_initial <- as.data.frame(f4(temp_f2,
                                    "Yoruba",
                                    "Greece_LBA_Mycenaean",
                                    "Tenea_EarlyRom",
                                    "Tenea_Rom") )

temp_f4_initial_inv <- as.data.frame(f4(temp_f2,
                                    "Yoruba",
                                    "Tenea_EarlyRom",
                                    "Greece_LBA_Mycenaean",
                                    "Tenea_Rom") )

##################################
temp_pops <- vector_of_final_pops[vector_of_final_pops %in% c("Yoruba", "Ammotopos_LBA", "Tenea_EarlyRom", "Tenea_Rom")]
temp_inds <- vector_of_final_inds[vector_of_final_pops %in% c("Yoruba", "Ammotopos_LBA", "Tenea_EarlyRom", "Tenea_Rom")]
temp_f2 <- f2_from_geno(prefic_data,
                        inds = temp_inds, pops = temp_pops, maxmiss = 0.1,
                        adjust_pseudohaploid = TRUE)
temp_snps <- count_snps(temp_f2)
temp_f4_initial <- as.data.frame(f4(temp_f2,
                                    "Yoruba",
                                    "Ammotopos_LBA",
                                    "Tenea_EarlyRom",
                                    "Tenea_Rom") )
##################################

##### Perform all f4 calculations i.e. ABCD, ACBD, ADCB #####

prefic_data <- "~/apoikia/data_manipulations/clement_lazaridis_modern_clean"
real_indexes <- read.table("~/apoikia/data_manipulations/clement_lazaridis_modern_clean.ind", header = F, sep = '\t')

pop1 <- c("Yoruba")
pop2 <- c("Greece_LBA_Mycenaean", "Greece_N", "Ammotopos_LBA")
pop3 <- c("Tenea_Hel", "Tenea_Arch", "Tenea_EarlyRom", "Tenea_Rom")
pop4 <- c("Amvrakia_Hel", "Amvrakia_LateCl", "Amvrakia_Arch", "Amvrakia_Cl")

all_combinations <- expand.grid( "pop1" = pop1, "pop2" = pop2, "pop3" = pop3, "pop4" = pop4,
                                stringsAsFactors = F )

vector_of_final_pops <- real_indexes[[3]]
vector_of_final_inds <- real_indexes[[1]]


alphabet_f4_ABCD <- t(sapply(1:nrow(all_combinations),
                             function(x) score_4(all_combinations[x,], vector_of_final_pops,
                                                 vector_of_final_inds, prefic_data) ) )

alphabet_f4_ACBD <- t(sapply(1:nrow(all_combinations),
                             function(x) score_4(all_combinations[x,c(1,3,2,4)], vector_of_final_pops,
                                                 vector_of_final_inds, prefic_data) ) )

alphabet_f4_ADBC <- t(sapply(1:nrow(all_combinations),
                             function(x) score_4(all_combinations[x,c(1,4,2,3)], vector_of_final_pops,
                                                 vector_of_final_inds, prefic_data) ) )
alphabet_all_permutations <- cbind( alphabet_f4_ABCD, alphabet_f4_ACBD[,5:8], alphabet_f4_ADBC[,5:8] )

## rbind(alphabet_f4_ABCD[1,],
##       alphabet_f4_ACBD[1,],
##       alphabet_f4_ADBC[1,])

colnames(alphabet_all_permutations) <- c("pop1", "pop2", "pop3", "pop4",
                                         "est_ABCD", "se_ABCD", "z_ABCD", "p_ABCD", "SNPs",
                                         "est_ACBD", "se_ACBD", "z_ACBD", "p_ACBD",
                                         "est_ADCB", "se_ADCB", "z_ADCB", "p_ADBC")

write.table( alphabet_all_permutations,
            "~/apoikia/f4_outputs/alphabet_f4_all_permutations.tsv",
            quote = FALSE, sep = '\t',
            row.names = FALSE, col.names = TRUE )

###### Include the Tenea Romans and Tenea Early-Romans ######

pop1 <- c("Yoruba")
pop2 <- c("Greece_LBA_Mycenaean", "Greece_N", "Ammotopos_LBA")
pop3 <- c("Tenea_EarlyRom")
pop4 <- c("Tenea_Rom")

roman_combs <- expand.grid( "pop1" = pop1, "pop2" = pop2, "pop3" = pop3, "pop4" = pop4,
                           stringsAsFactors = F )

roman_f4_ABCD <- t(sapply(1:nrow(roman_combs),
                          function(x) score_4(roman_combs[x,], vector_of_final_pops,
                                              vector_of_final_inds, prefic_data) ) )

roman_f4_ACBD <- t(sapply(1:nrow(roman_combs),
                          function(x) score_4(roman_combs[x,c(1,3,2,4)], vector_of_final_pops,
                                              vector_of_final_inds, prefic_data) ) )

roman_f4_ADBC <- t(sapply(1:nrow(roman_combs),
                          function(x) score_4(roman_combs[x,c(1,4,2,3)], vector_of_final_pops,
                                              vector_of_final_inds, prefic_data) ) )

roman_all_perms <- cbind( roman_f4_ABCD, roman_f4_ACBD[,5:8], roman_f4_ADBC[,5:8] )

colnames(roman_all_perms) <- c("pop1", "pop2", "pop3", "pop4",
                               "est_ABCD", "se_ABCD", "z_ABCD", "p_ABCD", "SNPs",
                               "est_ACBD", "se_ACBD", "z_ACBD", "p_ACBD",
                               "est_ADCB", "se_ADCB", "z_ADCB", "p_ADBC")

write.table( roman_all_perms,
            "~/apoikia/f4_outputs/roman_f4_all_permutations.tsv",
            quote = FALSE, sep = '\t',
            row.names = FALSE, col.names = TRUE )

#############################################################
score_4 <- function( combination, vector_of_pops, vector_of_inds, prefix ){
    ## "combination" is a vector of 4 populations. F4 will be calculated as
    ## (combination[1]-combination[2])*(combination[3]-combination[4])
    ## "vector_of_pops" is a vector with size = sample_size that corresponds to
    ## which population each sample belongs to.
    ## "vector_of_inds" is a vector that contains the name of each sample.
    ## "prefix" should countain the prefic to an EIGESTRAT dataset
    ## print( "enter" )
    colnames(combination) <- c( "pop1", "pop2", "pop3", "pop4" )
    temp_pops <- vector_of_pops[vector_of_pops %in% combination]
    temp_inds <- vector_of_inds[vector_of_pops %in% combination]
    temp_f2 <- f2_from_geno(prefix,
                            inds = temp_inds, pops = temp_pops,
                            maxmiss = 0.1, adjust_pseudohaploid = TRUE)
    ## print( "F2")
    temp_snps <- count_snps(temp_f2)
    temp_f4_initial <- as.data.frame(f4(temp_f2,
                                        combination[1], combination[2],
                                        combination[3], combination[4]) )
    ## print("F4")
    all_snp_f4 <- cbind( temp_f4_initial, temp_snps )
    colnames(all_snp_f4) <- c(colnames(temp_f4_initial),"SNPs")
    ## print("colnames")
    return( all_snp_f4 )
}

score_4_all_possibilities <- function( combination, vector_of_pops, vector_of_inds, prefix ){
##### Same as score_4 but it calculates all possible f4: ABCD, ACBD, ADCB #####
    print( "enter" )
    temp_pops <- vector_of_pops[vector_of_pops %in% combination]
    temp_inds <- vector_of_inds[vector_of_pops %in% combination]
    temp_f2 <- f2_from_geno(prefix,
                            inds = temp_inds, pops = temp_pops,
                            maxmiss = 0.1, adjust_pseudohaploid = TRUE)
    print( "F2")
    ## print( combination )
    ## print( temp_pops )
    ## print( temp_inds )
    temp_snps <- count_snps(temp_f2)
    temp_f4_ABCD <- as.data.frame(f4(temp_f2,
                                     combination[1], combination[2],
                                     combination[3], combination[4]) )
    print("F4_1")
    ## print(combination[c(1,3,2,4)])
    names(combination) <- c( "pop1", "pop3", "pop2", "pop4" )
    temp_f4_ACBD <- as.data.frame(f4(temp_f2,
                                     combination[1], combination[3],
                                     combination[2], combination[4]) )
    print("F4_2")
    names(combination) <- c( "pop1", "pop4", "pop2", "pop3" )
    print( combination )
    temp_f4_ADBC <- as.data.frame(f4(temp_f2,
                                     combination[1], combination[4],
                                     combination[2], combination[3]) )
    print("F4_3")
    colnames(temp_f4_ABCD) <- c(colnames(temp_f4_ABCD)[1:4],
                                "est_ABCD", "se_ABCD", "z_ABCD", "p_ABCD")
    colnames(temp_f4_ACBD) <- c(colnames(temp_f4_ACBD)[1:4],
                                "est_ACBD", "se_ACBD", "z_ACBD", "p_ACBD")
    colnames(temp_f4_ADBC) <- c(colnames(temp_f4_ADBC)[1:4],
                                "est_ADBC", "se_ADBC", "z_ADBC", "p_ADBC")
    alphabet_snp_f4 <- c( temp_f4_ABCD, temp_f4_ACBD[,5:8], temp_f4_ADBC[,5:8], temp_snps )
    colnames(alphabet_snp_f4) <- c(colnames(temp_f4_ABCD), colnames(temp_f4_ACBD)[5:8],
                              colnames(temp_f4_ADBC)[5:8], "SNPs")
    return( alphabet_snp_f4 )
}
