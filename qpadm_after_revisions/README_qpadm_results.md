# Readme for qpadm analysis

## Ultimate Sources

We wanted to test the ancestry profile of our sampled individuals
compared to the commonly described ancestry components that shaped
most populations of that era.  

### **base** and **sources**.

These populations were initialy selected as a **base** group of
populations for *qpadm*. Each of these populations will be tested as a
potential **source** but will act as *right* when not tested.  

+ `RUS_S_AfontovaGora_UP_HG_16250-15900BCE`
+ `ITA-ESP-CHE_M_WHG_12250-5750BCE`
+ `RUS_M_EHG_7050-5500BCE`
+ `TUR_NW_Barcin_N_6500-5900BCE`
+ `ISR_RaqefetCave_EpiP_Natufian_12000_9500BCE`
+ `ISR-JOR_PPN_Levant_8400-6200BCE`
+ `IRN_GanjDareh_N_8300-7600BCE`
+ `SRB_M_HG_IronGates_9800-5700BCE`
+ `IRQ_TUR_PPNA-like_Mesopotamia_9500-1200BCE`
+ `GEO_M_CHG_11500-7500BCE`
+ `MAR_NorthEast_Taforalt_UP_HG_Iberomaurusian_13200-11900BCE`
+ `TUR_SWC_Pinarbasi_Epipaleolithic_HG_13650-13300BCE`
+ `TUR_SC_BoncukluHoyuk_N_8300-7600BCE`
+ `RUS_S_Malta_UP_HG_22600-22150BCE`

In addition to the **base** poppulations, another group of populations
was selected to only act as potential **sources** of ancestry.  

+ `IRN_HajjiFiruz_N_6050-5700BCE`
+ `IRN_SehGabi_C_4850-3800BCE`
+ `IRN_TepeHissar_C_BA_3700-1950BCE`
+ `RUS_W_Samara_EBA_Yamnaya_3350-2500BCE`

### Testing **base** populations with qpwave.

*qpWave* was run for all the pairs of **base** and **sources** in
order to determine if any pair of populations form a clade with one
another in respect to all possible **targets**.  

`qpwave( (Pop_i, Pop_j), (outgroup & targets) )` where `Pop_i` and
`Pop_j` are all possible pairs in the union of **sources** and
**right**. This initial test was run using `f2_from_geno` output of
the admixtools R package with parameters `adjust_pseudohaploid =
TRUE`, `maxmiss = 0.2` and `afpprod = TRUE`. 682360 polymorphic SNPs
remained after filtering.  

Populations

+ `ISR-JOR_PPN_Levant_8400-6200BCE`
+ `RUS_M_EHG_7050-5500BCE`
+ `TUR_SWC_Pinarbasi_Epipaleolithic_HG_13650-13300BCE`
+ `TUR_NW_Barcin_N_6500-5900BCE`
+ `ISR_RaqefetCave_EpiP_Natufian_12000_9500BCE`
+ `RUS_S_AfontovaGora_UP_HG_16250-15900BCE`
+ `IRQ_TUR_PPNA-like_Mesopotamia_9500-1200BCE`

ended up being removed from **base** because they formed a clade either
with multiple populations from **base** or an older population.  

### qpAdm

*qpAdm* was run with the updated list of **base** populations using
the `qpadm_multi` function of admixtools with parameter `allsnps =
TRUE`

## Most Proximate Sources

For each sampled population, we want to infer ancestry components
based on available populations that are as close, spatially and
temporally, as possible.

For each of the APOIKIA samples, we have selected groups of such
populations that are going to act as potential **sources**.  
We tested each pair of potential **sources** using *qpWave*, in order
to determine which of these will also act as **right** when not
considered **left** in *qpAdm*.

We included all APOIKIA populations as targets in the *qpWave* tests
as, if we only chose each population individually, the F4 matrix would
be 1x1 making it difficult to evaluate tree-like relationships of
**sources**.

Alongside `Yoruba`, populations

+ `IRN_GanjDareh_N_8300-7600BCE`
+ `SRB_M_HG_IronGates_9800-5700BCE` 

were also employed as outgroups, in order to have a critical mass of
**right** populations for *qpAdm* analysis.  
Note that the `Yoruba` population is always the first **right** in
*qpadm* analysis.

### Ammotopos

Populations in **base** after *qpwave*:

+ `GRC_Peloponnese_LBA_1600_1280BCE`
+ `TUR_S-SW_MBA-to-MLBA_2000-1300BCE`
+ `GRC_Crete_LBA_1700-1250BCE`
+ `ISR-JOR_MLBA-to-LBA_2000-1285BCE`
+ `HRV-MNE_MBA-to-MLBA_1750-1280BCE`
+ `BGR_EMBA_Yamnaya-like_1850-1600BCE`

Populations that are used only as **sources** after *qpwave*:

+ `GRC_StereaEllada_LBA_1600-1300BCE`
+ `ITA_Sardinia_MBA_1550-1300BCE`
+ `ITA_BA_BellBeaker_2500-1900BCE`
+ `ALB_MBA_1900-1700BCE`
+ `GRC_Mainland_North_MBA_2100-1600BCE`

Additional **right** populations:

+ `Yoruba`
+ `IRN_GanjDareh_N_8300-7600BCE`
+ `SRB_M_HG_IronGates_9800-5700BCE`

### Amvrakia Archaic

Populations in **base** after *qpwave*:

+ `GRC_Cyclades_LBA_1175-1150BCE`
+ `SRB_LBA_1000_900BCE`
+ `GRC_Peloponnese_IA_1070-830BCE`
+ `TUR_IA_850-750BCE`
+ `MKD_IA_900-550BCE`
+ `ITA_Sicily_IA_900-700BCE`
+ `HRV_EIA_1050-550BCE`

Populations that are used only as **sources** after *qpwave*:

+ `ITA_Mainland_IA_and_Etruscan_800-540BCE`
+ `GRC_StereaEllada_LBA_1400-1100BCE`
+ `BGR_EIA_1100-500BCE`
+ `ISR-JOR_MLBA-to-LBA_1400-1100BCE`
+ `ALB_MBA_1900-1700BCE`
+ `EGY_IA_800-550BCE`
+ `GRC_Crete_LBA_1350-1050BCE`
+ `ITA_Sardinia_IA_800-550BCE`

Additional **right** populations:

+ `Yoruba`
+ `IRN_GanjDareh_N_8300-7600BCE`
+ `SRB_M_HG_IronGates_9800-5700BCE`

### Amvrakia Classical

Populations in **base** after *qpwave*:

+ `ITA_Mainland_IA_and_Etruscan_800-520BCE`
+ `TUR_Archaic_780-480BCE`
+ `BGR_EIA_1100-500BCE`
+ `ISR-JOR_MLBA-to-LBA_1400-1100BCE`
+ `HRV_EIA_1050-550BCE`
+ `EGY_IA_800-550BCE`
+ `GRC_Crete_LBA_1350-1050BCE`
+ `ITA_Sardinia_IA_800-550BCE`
+ `IRN_GanjDareh_N_8300-7600BCE`
+ `SRB_M_HG_IronGates_9800-5700BCE`

Populations that are used only as **sources** after *qpwave*:

+ `GRC_Peloponnese_IA_1070-830BCE`
+ `GRC_StereaEllada_IA_800-500BCE`
+ `ITA_Adriatic_IA_750-400BCE`
+ `SRB_LBA_1000_900BCE`
+ `MKD_IA_800-500BCE`
+ `GRC_Cyclades_LBA_1175-1150BCE`
+ `ALB_MBA_1900-1700BCE`
+ `ITA_Sicily_IA_900-700BCE`

Additional **right** populations:

+ `Yoruba`
+ `IRN_GanjDareh_N_8300-7600BCE`
+ `SRB_M_HG_IronGates_9800-5700BCE`


### Amvrakia Helenistic

Populations in **base** after *qpwave*:

+ `ITA_Mainland_IA_and_Etruscan_800-400BCE`
+ `MKD_Classical_400-380BCE`
+ `HRV-MNE_EIA_800-400BCE`
+ `ITA_Sicily_IA_900-400BCE`
+ `ITA_Sicily_Himera_Archaic_Classical_LOCAL_780-400BCE`
+ `BGR_EIA_1100-500BCE`
+ `TUR_Archaic-to-Hellenistic_780-390BCE`
+ `ISR-JOR_MLBA-to-LBA_1400-1100BCE`
+ `EGY_IA_800-550BCE`


Populations that are used only as **sources** after *qpwave*:

+ `GRC_StereaEllada_IA_800-500BCE`
+ `GRC_Cyclades_LBA_1175-1150BCE`
+ `GRC_Peloponnese_IA_1070-830BCE`
+ `ITA_Adriatic_IA_750-400BCE`
+ `ALB_IA_650-400BCE`
+ `SRB_LBA_1000_900BCE`
+ `GRC_Crete_LBA_1350-1050BCE`
+ `ITA_Sardinia_IA_800-400BCE`
+ `GRC_Tenea_Archaic_550-480BCE`
+ `GRC_Tenea_Hellenistic_323-31BCE`
+ `GRC_Ammotopos_LBA_1275-1125BCE`
+ `GRC_Amvrakia_Archaic_550-480BCE`
+ `GRC_Amvrakia_Classical_475-325BCE`

Additional **right** populations:

+ `Yoruba`
+ `IRN_GanjDareh_N_8300-7600BCE`
+ `SRB_M_HG_IronGates_9800-5700BCE`

### Tenea Archaic

Populations in **base** after *qpwave*:

+ `GRC_Ammotopos_LBA_1275-1125BCE`
+ `ITA_Mainland_IA_and_Etruscan_800-540BCE`
+ `GRC_StereaEllada_LBA_1400-1100BCE`
+ `BGR_EIA_1100-500BCE`
+ `ISR-JOR_MLBA-to-LBA_1400-1100BCE`
+ `ALB_MBA_1900-1700BCE`
+ `EGY_IA_800-550BCE`
+ `GRC_Crete_LBA_1350-1050BCE`
+ `ITA_Sardinia_IA_800-550BCE`

Populations that are used only as **sources** after *qpwave*:

+ `GRC_Cyclades_LBA_1175-1150BCE`
+ `GRC_Peloponnese_IA_1070-830BCE`
+ `SRB_LBA_1000_900BCE`
+ `HRV_EIA_1050-550BCE`
+ `ITA_Sicily_IA_900-700BCE`
+ `TUR_IA_850-750BCE`
+ `MKD_IA_900-550BCE`

Additional **right** populations:

+ `Yoruba`
+ `IRN_GanjDareh_N_8300-7600BCE`
+ `SRB_M_HG_IronGates_9800-5700BCE`

### Tenea Helenistic

Populations in **base** after *qpwave*:

+ `GRC_Ammotopos_LBA_1275-1125BCE`
+ `GRC_Amvrakia_Archaic_550-480BCE`
+ `GRC_Amvrakia_Classical_475-325BCE`
+ `GRC_Amvrakia_Hellenistic_325-100BCE`
+ `ITA_Mainland_IA_and_Etruscan_800-400BCE`
+ `MKD_Classical_400-380BCE`
+ `HRV-MNE_EIA_800-400BCE`
+ `ITA_Sicily_IA_900-400BCE`
+ `ITA_Sicily_Himera_Archaic_Classical_LOCAL_780-400BCE`
+ `BGR_EIA_1100-500BCE`
+ `TUR_Archaic-to-Hellenistic_780-390BCE`
+ `ISR-JOR_MLBA-to-LBA_1400-1100BCE`
+ `EGY_IA_800-550BCE`
+ `GRC_Tenea_Archaic_550-480BCE`

Populations that are used only as **sources** after *qpwave*:

+ `GRC_StereaEllada_IA_800-500BCE`
+ `ITA_Adriatic_IA_750-400BCE`
+ `GRC_Peloponnese_IA_1070-830BCE`
+ `GRC_Cyclades_LBA_1175-1150BCE`
+ `ALB_IA_650-400BCE`
+ `SRB_LBA_1000_900BCE`
+ `ITA_Sardinia_IA_800-400BCE`
+ `GRC_Crete_LBA_1350-1050BCE`

Additional **right** populations:

+ `Yoruba`
+ `IRN_GanjDareh_N_8300-7600BCE`
+ `SRB_M_HG_IronGates_9800-5700BCE`

### Tenea Roman

Populations in **base** after *qpwave*:

+ `GRC_Ammotopos_LBA_1275-1125BCE`
+ `GRC_Amvrakia_Archaic_550-480BCE`
+ `GRC_Amvrakia_Classical_475-325BCE`
+ `GRC_Amvrakia_Hellenistic_325-100BCE`
+ `ITA_C_IA_Etruscan_RomanRepublic_450-50BCE`
+ `MKD_Classical_Hellenistic_500-100BCE`
+ `ITA_Sardinia_IA_800-200BCE`
+ `ITA_Sicily_IA_900-400BCE`
+ `ITA_Sicily_Himera_Archaic_Classical_LOCAL_780-400BCE`
+ `BGR_IA_1100-200BCE`
+ `ISR-JOR_MLBA-to-LBA_1400-1100BCE`
+ `TUR_Hellenistic_510-30BCE`
+ `EGY_IA_800-550BCE`
+ `GRC_Tenea_Archaic_550-480BCE`
+ `GRC_Tenea_Hellenistic_323-31BCE`

Populations that are used only as **sources** after *qpwave*:

+ `GRC_StereaEllada_IA_800-500BCE`
+ `ITA_Adriatic_IA_750-200BCE`
+ `GRC_Cyclades_LBA_1175-1150BCE`
+ `SRB_LBA_1000_900BCE`
+ `ALB_IA_650-50BCE`
+ `GRC_Crete_LBA_1350-1050BCE`
+ `HRV-MNE_EIA_800-200BCE`

Additional **right** populations:

+ `Yoruba`
+ `IRN_GanjDareh_N_8300-7600BCE`
+ `SRB_M_HG_IronGates_9800-5700BCE`

## More Proximate Sources

This group consists of mostly post-Neolithic populations who either
are or may have contributed to the ancestors of APOIKIA populations.

*qpwave* was employed in a similar fashion as "Most Proximate Sources".
An initial pool of populations were split into **base** and **sources**
in order to be used by *qpadm*.
Parameter values were identical with previous sections.

Populations in **base** after *qpwave*:

+ `TUR_S-SW_MBA-to-MLBA_2000-1300BCE`
+ `GRC_Neolithic_6400-3600BCE`
+ `GRC_Crete_EBA_EMBA_MBA_2900-1700`
+ `RUS_W_Samara_EBA_Yamnaya_3350-2500BCE`
+ `ISR-JOR_MLBA-to-LBA_2000-1285BCE`
+ `ITA_Sicily_EBA_2300-1650BCE`
+ `BGR_EBA_3400-1600BCE`
+ `ITA_BA_BellBeaker_2500-1900BCE`
+ `IRN_TepeHissar_C_BA_3700-1950BCE`

Populations that are used only as **sources** after *qpwave*:

+ `GRC_StereaEllada_LBA_1600-1300BCE`
+ `GRC_EBA_2900-2000BCE`
+ `GRC_Mainland_North_MBA_2100-1600BCE`
+ `ALB_MBA_1900-1700BCE`
+ `ITA_Sardinia_MBA_1550-1300BCE`
+ `BGR-SER_EBA-to-EMBA_Yamnaya-like_2900-2000BCE`
+ `GRC_Crete_LBA_1700-1250BCE`
+ `NW_Balkans_EBA-to-MLBA_2150-1250BCE`
+ `GRC_Peloponnese_LBA_1600_1280BCE`

Additional **right** populations:

+ `Yoruba`
+ `IRN_GanjDareh_N_8300-7600BCE`
+ `SRB_M_HG_IronGates_9800-5700BCE`
