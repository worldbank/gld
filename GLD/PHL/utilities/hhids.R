# try to find the hhid uniqueness

library(tidyverse)
library(janitor)


# files ----

load(PHL_meta)

files_tib <- files_tib %>% arrange(row_number())

jan97 <- readRDS(files_tib$rpath[2])
jan01 <- readRDS(files_tib$rpath[8])
apr02 <- readRDS(files_tib$rpath[9])

apr03 <- readRDS(files_tib$rpath[13])
jan03 <- readRDS(files_tib$rpath[14])
jul03 <- readRDS(files_tib$rpath[15])
oct03 <- readRDS(files_tib$rpath[16])
oct04 <- readRDS(files_tib$rpath[20])
jul06 <- readRDS(files_tib$rpath[27])
oct06 <- readRDS(files_tib$rpath[28])
jan07 <- readRDS(files_tib$rpath[30])

jan17 <- readRDS(files_tib$rpath[70])
apr17 <- readRDS(files_tib$rpath[69])
jul17 <- readRDS(files_tib$rpath[71])
oct17 <- readRDS(files_tib$rpath[72])

# initial explorations----
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

# exploration for 2003 ----
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
  
  hh03 <- jul03 %>% 
    group_by(creg, stratum, psu, ea_unique, shsn, hcn) %>%
    mutate(hhid = cur_group_id())
    # if this is really true then there should be no duplicate cc101_lno by the generated hhid 
    
    get_dupes(hh03, hhid, cc101_lno) # true, 0 dupes


# 2004  ----
  hh04 <- oct04 %>% 
      group_by(creg, prov, stratum, psu, shsn, hcn) %>%
      mutate(hhid = cur_group_id()) %>%
      select(cc101_lno, hhid,creg, prov, stratum, psu, shsn, hcn, everything()) %>%
      arrange(hhid, cc101_lno)    
    
  dupsOct04 <- get_dupes(hh04, hhid, cc101_lno) # no dups found
  
  assertthat::assert_that(nrow(dupsOct04) == 0) # ensure that there are no dups
  
# 2006 ----
  hh06jul <- jul06 %>% 
  group_by(creg, prov, stratum, psu, ea_unique, shsn, hcn) %>%
    mutate(hhid = cur_group_id()) %>%
    select(cc101_lno, hhid,creg, prov, stratum, psu, ea_unique, shsn, hcn, everything()) %>%
    arrange(hhid, cc101_lno) 
  
  hh06oct <- oct06 %>% 
    group_by(creg, prov, stratum, psu, ea_unique, shsn, hcn) %>%
    mutate(hhid = cur_group_id()) %>%
    select(cc101_lno, hhid,creg, prov, stratum, psu, ea_unique, shsn, hcn, everything()) %>%
    arrange(hhid, cc101_lno)   
  
  get_dupes(oct06, creg, prov, stratum, psu, ea_unique, shsn, hcn, cc101_lno) %>% View()
  
  # looks like there may be duplicate entries for a given household number across these variables,
  # will have to drop observation if hhid is in the duplicate list
  

  dups06jul <- get_dupes(hh06jul, hhid, cc101_lno) # no dups found
  dups06oct <- get_dupes(hh06oct, hhid, cc101_lno) # no dups found
  n_distinct(dups06oct$hhid) # only 1 household that has duplicates
  
  assertthat::assert_that(nrow(dups06jul) == 0) # ensure that there are no dups
  assertthat::assert_that(nrow(dups06oct) == 0) # ensure that there are no dups
  
# 2007 ---- 
  hh07jan <- jan07 %>% 
    group_by( w_regn, w_prv, w_ea, w_shsn, lstr, eaunique_psu, w_hcn) %>%
    mutate(hhid = cur_group_id()) %>%
    select(hhid, lc101_lno, w_regn, w_prv, w_ea, w_shsn, lestrata, eaunique_psu, w_hcn, everything()) %>%
    arrange(hhid, lc101_lno)
  
  dups07jan <- get_dupes(hh07jan, hhid, lc101_lno)
  n_distinct(dups07jan$hhid) # only 4 households that have duplicates
  
  dups07jan_ids <- unique(dups07jan$hhid)
  n_dups_in_fam_07jan <- 
    hh07jan %>% filter(hhid %in% dups07jan_ids) %>% nrow() # there are 48 observations that belong to households with dups
  

# 2017 ----
# what are the duplicates like for each round
  get_dupes(jan17, pufhhnum, pufc01_lno)  # only 2 dups
  get_dupes(apr17, lreg, l1prrcd, l1mun, l1ea, lhusn, l1bgy, lhsn, lpsu, lc101_lno) # 0 dups
  get_dupes(jul17, pufhhnum, pufc01_lno) # 0 dups 
  get_dupes(oct17, pufhhnum, pufc01_lno) # 0 dups
  
  ## check construction of apr17 hhid 
  hh17apr <- apr17 %>% 
    group_by( lreg, l1prrcd, l1mun, l1ea, lhusn, l1bgy, lhsn, lpsu) %>%
    mutate(hhid = cur_group_id()) %>%
    select(hhid, lc101_lno, lreg, l1prrcd, l1mun, l1ea, lhusn, l1bgy, lhsn, lpsu, everything()) %>%
    arrange(hhid, lc101_lno)
  
  dups17apr <- get_dupes(hh17apr, hhid, lc101_lno) # 0 dups
  
  dups17jan <- get_dupes(jan17, pufhhnum, pufc01_lno)
  dups17jan_ids <- unique(dups17jan$pufhhnum)
  
  n_dups_in_fam_17jan <- 
    jan17 %>% filter(pufhhnum %in% dups17jan_ids) %>% nrow() # there are 4 observations that belong to households with dups
  
  
  
    