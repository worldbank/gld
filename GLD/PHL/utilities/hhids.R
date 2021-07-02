# try to find the hhid uniqueness

library(tidyverse)
library(janitor)

load(PHL_meta)

files_tib <- files_tib %>% arrange(row_number())

jan97 <- readRDS("Y:/GLD-Harmonization/551206_TM/PHL/PHL_1997_LFS/PHL_1997_LFS_v01_M/Data/R/LFS JAN1997.Rds")
jan01 <- readRDS("Y:/GLD-Harmonization/551206_TM/PHL/PHL_2001_LFS/PHL_2001_LFS_v01_M/Data/R/LFS JAN2001.Rds")
apr02 <- readRDS("Y:/GLD-Harmonization/551206_TM/PHL/PHL_2002_LFS/PHL_2002_LFS_v01_M/Data/R/LFS APR2002.Rds")

apr03 <- readRDS(files_tib$rpath[13])
jan03 <- readRDS(files_tib$rpath[14])
jul03 <- readRDS(files_tib$rpath[15])
oct03 <- readRDS(files_tib$rpath[16])

fam <- jan97 %>%
  group_by(regn, hcn) %>%
  summarise(.groups = "keep") %>%
  nrow()

n_distinct(jan97$hcn)
n_distinct(jan97$panel)

fam01 <- jan01 %>%
  group_by(regn, hcn) %>%
  summarise(.groups = "keep") 

dups <- jan01 %>%
  get_dupes(regn, hcn, c101_lno)

jan01 %>% get_dupes()

fam02apr <- apr02 %>%
  group_by(regn, prov, hcn) %>%
  summarise(.groups = "keep") %>%
  nrow()

dupsApr02 <- apr02 %>% get_dupes(regn, prov, hcn, c101_lno)

# exploration for 2003
# function for n groupings by region, province, hcn
n_hh_reg_prov_hcn <- function(x, a, b, c) {
    x %>%
    group_by(regn, prov, hcn) %>%
    summarise(.groups = "keep") %>%
    nrow() 
}


HHapr03_n <- n_hh_reg_prov_hcn(apr03)

HHjan03_n <- n_hh_reg_prov_hcn(jan03)

#these groups of vars define about the same number of units for july and october, but slightly more
#than in january and aprlil  

  jul03 %>%
  group_by(creg, stratum, psu, ea_unique, shsn, hcn) %>%
  summarise(.groups = "keep") %>%
  nrow()
  
  oct03 %>%
    group_by(creg, stratum, psu, ea_unique, shsn, hcn) %>%
    summarise(.groups = "keep") %>%
    nrow()

# try to verify that these are the actually the variables that define the HH   
  
  hh <- jul03 %>% 
    group_by(creg, stratum, psu, ea_unique, shsn, hcn) %>%
    mutate(hhid = cur_group_id())
    # if this is really true then there should be no duplicate cc101_lno by the generated hhid 
    
    get_dupes(hh, hhid, cc101_lno) # true, 0 dupes
