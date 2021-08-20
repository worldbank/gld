# international_codes.R
# matches isic, isco, isced codes to PHL LFS survey data
# 
# 
# This script assumes you've run main.R first 
# 
# The main purpose of this script is to match isic (industry), 
# isco (occupation) and isced (education) codes to produce 
# either 
#   - tables, or 
#   - easily-writable in-script code that coverts the raw data to ISIC/ISCO etc 
# 
# Most of the findings here will be documents in "Industry_Occupation Codes.md" in 
# the "Country Survey Details" Folder for the Philippines

library(tidyverse)
library(stringr)
library(pdftools)
library(janitor)
library(magrittr)



# load network data
load(PHL_meta)
if (FALSE) {load(PHL_labels)}

# get functions
source(file.path(code, "Global/read_pdf_table.R"))
source(file.path(code, "Global/best_matches.R"))

# pdf file path
psic94_path <- file.path(PHL, "PHL_docs/International Codes/PSA_PSIC_1994.pdf")
psic09_path <- file.path(PHL, "PHL_docs/International Codes/PSA_PSIC_2009.pdf")
psoc12_path <- file.path(PHL, "PHL_docs/International Codes/PSA_PSOC_2012.pdf")





              ##### ISIC ####

# Import ISIC 3.0 data --------------------------------- 
# we know that only years 1997 - 2011 use this
UNisic3 <- read_delim(file = file.path(PHL, "PHL_data/GLD/international_codes/ISIC_Rev_3_english_structure.txt"))


pdf <- pdftools::pdf_data(psic94_path)

## ISIC 94 Raw ----
## Note that there are two "halves" with varying page specifications.
## Solution is import by each half and then append.

isic94_codes_raw_A <- read_pdf(
  
  pdf_path = psic94_path,
  page_min = 2,
  page_max = 11, 
  varnames = c("class", "subclass", "psic1994", "psic77", "isic3.1"),
  ymin = 90,
  xlabel = c(130, 390),
  xmin = c(55, 90, 391, 430, 470),
  xmax = c(89, 129, 429, 469, 9999),
  header = FALSE,
  numlist = c(1994, 1977, 3.1)
)

isic94_codes_raw_B <- read_pdf(
  
  pdf_path = psic94_path,
  page_min = 12,
  page_max = 185,
  varnames = c("class", "subclass", "psic1994", "psic77", "isic3.1"),
  ymin = 90,
  xlabel = c(130, 434),
  xmin = c(55, 90, 435, 470, 505),
  xmax = c(89, 129, 469, 504, 9999),
  header = FALSE,
  numlist = c(1994, 1977, 3.1),
  fuzzy_rows = FALSE
)


isic94_codes_raw <- bind_rows(isic94_codes_raw_A, 
                              isic94_codes_raw_B)


# cleaning ----
## setup 
table_vars_gc <- c("group", "class")
table_vars_ppi<- c("psic1994", "psic77", "isic3.1")
rowAny <- function(x) rowSums(x) > 0 


## create "class" from subclass and "group" variable from class
## we know that class is always the first four digits of subclass 
## and group is always the first 3 digits of class. But for some 
## obs, class is provided, so do not overwrite this info. Treat 
## given info as authoritative.

isic94_codes <- isic94_codes_raw %>%
  mutate(
    class = case_when(is.na(class)  ~ str_sub(subclass, 1,4),
                      TRUE          ~ class),
    group = str_sub(class, 1,3)) %>%
  select(y, page_grp, page, group, class, everything())



# this object has "leftotver stubs" that do not list any useful information.
# it only lists the structure of the group and class, which can be extracted so
# create a leftover object to verify that we filtered correctly
# object 1 is what we want removed where both group and class are missing.
# object 2 is where all of psic1994, isic4, acic vars are missing

isic94_leftover1 <-  isic94_codes %>% 
  filter(across(all_of(table_vars_gc), ~ is.na(.x))) 

isic94_leftover2 <- isic94_codes %>%
  filter(across(all_of(table_vars_ppi), ~is.na(.x)))

isic94_leftover <- bind_rows(isic94_leftover1, isic94_leftover2)



## ISIC 94 clean ----
fin_vrs <- c("group", "class", "subclass", "psic1994", "psic77", "isic3.1")

isic94_clean <- isic94_codes %>%
  ## eliminate the "("
  mutate(psic1994 = str_replace(psic1994, "\\(", "")) %>%
  mutate(psic1994 = str_replace(psic1994, "\\)", "")) %>%
  #mutate(across(fin_vrs), .fns = list( fc = ~ str_replace(, ":", "")))
  ## eliminate group and class-only rows
  #filter(rowAny(across(table_vars_gc, ~ !is.na(.x)))) %>% # at least 1 col must be non-NA
  filter(rowAny(across(all_of(table_vars_ppi), ~ !is.na(.x)))) %>% # at least 1 col must be non-NA
  ungroup() %>%
  select(-y, -page_grp)

# check
assertthat::assert_that( (nrow(isic94_clean) + nrow(isic94_leftover2)) == nrow(isic94_codes)   )


isic94_clean %>% janitor::get_dupes() # there is 1 pair of dups

isic94_clean <- isic94_clean %>%
  rename("isic3_1" = "isic3.1") %>%
  distinct() 


assertthat::assert_that( sum(str_length(isic94_clean$class) <= 3, na.rm = TRUE) ==0 ) # should be 0 or close to
assertthat::assert_that( sum(str_length(isic94_clean$group) != 3, na.rm = TRUE) == 0 ) # should be 0 or close to






## ISIC 09 Raw ----
isic09_codes_raw <- read_pdf(
                      
    pdf_path = psic09_path,
    page_min = 22,
    page_max = 316,
    varnames = c("class", "subclass", "psic1994", "isic4", "acic"),
    ymin = 90,
    xlabel = c(155, 420),
    xmin = c(91, 131, 415, 446, 501),
    xmax = c(130, 175, 445, 500, 9999),
    header = TRUE,
    fuzzy_rows = TRUE,
    match_tol = 2
    )




# cleaning ----
## setup 
table_vars_gc <- c("group", "class")
table_vars_spia<- c("psic1994", "isic4", "acic")
rowAny <- function(x) rowSums(x) > 0 


## create "class" from subclass and "group" variable from class
## we know that class is always the first four digits of subclass 
## and group is always the first 3 digits of class. But for some 
## obs, class is provided, so do not overwrite this info. Treat 
## given info as authoritative.

isic09_codes <- isic09_codes_raw %>%
  mutate(
    class = case_when(is.na(class)  ~ str_sub(subclass, 1,4),
                      TRUE          ~ class),
    group = str_sub(class, 1,3)) %>%
  select( page_grp, page, group, class, everything())



# this object has "leftotver stubs" that do not list any useful information.
# it only lists the structure of the group and class, which can be extracted so
# create a leftover object to verify that we filtered correctly
# object 1 is what we want removed where both group and class are missing.
# object 2 is where all of psic1994, isic4, acic vars are missing

isic09_leftover1 <-  isic09_codes %>% 
  filter(across(all_of(table_vars_gc), ~ is.na(.x))) 

isic09_leftover2 <- isic09_codes %>%
  filter(across(all_of(table_vars_spia), ~is.na(.x)))

isic09_leftover <- bind_rows(isic09_leftover1, isic09_leftover2)



## ISIC clean ----
isic09_clean <- isic09_codes %>%
  ## eliminate the "("
  mutate(psic1994 = str_replace(psic1994, "\\(", "")) %>%
  mutate(psic1994 = str_replace(psic1994, "\\)", "")) %>%
  ## eliminate group and class-only rows
  #filter(rowAny(across(table_vars_gc, ~ !is.na(.x)))) %>% # at least 1 col must be non-NA
  filter(rowAny(across(all_of(table_vars_spia), ~ !is.na(.x)))) %>% # at least 1 col must be non-NA
  ungroup() %>%
  select(-page_grp) %>%
  select(page, y, group, class, subclass, psic1994, isic4, acic)
  
# check
assertthat::assert_that( (nrow(isic09_clean) + nrow(isic09_leftover2)) == nrow(isic09_codes)   )


isic09_clean %>% janitor::get_dupes() # there is 1 pair of dups

isic09_clean <- isic09_clean %>%
  distinct()


assertthat::assert_that( sum(str_length(isic09_clean$class) <= 3, na.rm = TRUE) ==0 ) # should be 0 or close to
assertthat::assert_that( sum(str_length(isic09_clean$group) != 3, na.rm = TRUE) == 0 ) # should be 0 or close to












                  ##### ISCO ####



# Use Function to import raw data 
# ISCO raw ----

psoc12_codes_raw <- read_pdf(
  
      pdf_path = psoc12_path,
      page_min = 102,
      page_max = 540,
      varnames = c("minor", "unit", "psoc92", "isco08"),
      ymin = 90,
      xlabel = c(160, 420),
      xmin = c(91, 130, 450, 495),
      xmax = c(130, 175, 495, 9999), 
      fuzzy_rows = FALSE

      )



# clean up result ----

## setup 
table_vars_sm <- c("submajor", "minor")
table_vars_pi<- c("psoc92", "isco08")
isco_order <- c("submajor", "minor", "unit", "psoc92", "isco08")


## create "submajor" from minor and "minor" variable from unit
## we know that minor is always the first four digits of unit 
## and submajor is always the first 3 digits of minor. But for some 
## obs, this info is provided, so do not overwrite this info. Treat 
## given info as authoritative.

psoc12_codes <- psoc12_codes_raw %>%
  mutate(
    minor    = case_when(is.na(minor)  ~ str_sub(unit, 1,4),
                      TRUE          ~ minor),
    submajor = str_sub(minor, 1,3)) %>%
  select(y, page_grp, page, submajor, minor, unit, psoc92, isco08)



# filter out leftoverstubs 
isco12_leftover1 <-  psoc12_codes %>% 
  filter(across(all_of(table_vars_sm), ~ is.na(.x))) 

isco12_leftover2 <- psoc12_codes %>%
  filter(across(all_of(table_vars_pi), ~is.na(.x)))

isco12_leftover <- bind_rows(isco12_leftover1, isco12_leftover2)



# ISCO clean ----
## note that for now in order to sidestep issue #96, will not filter yet
isco12_clean <- psoc12_codes %>%
  ## eliminate group and class-only rows
  #filter(rowAny(across(table_vars_sm, ~ !is.na(.x)))) %>% # at least 1 col must be non-NA
  filter(rowAny(across(all_of(table_vars_pi), ~ !is.na(.x)))) # at least 1 col must be non-NA
  
  # check
  assertthat::assert_that( (nrow(isco12_clean) + nrow(isco12_leftover2)) == nrow(psoc12_codes)   )

  ## eliminate strange puncutation marks
  isco12_clean <- isco12_clean %>%
    mutate(psoc92 = str_replace(psoc92, "[:punct:]", "")) %>%
    mutate(psoc92 = str_replace(psoc92, "p", "")) %>% 
    mutate(psoc92 = str_replace(psoc92, "\\`", NA_character_)) %>% 
    mutate(psoc92 = str_replace(psoc92, " ", NA_character_)) %>% 
    ungroup() %>%
    select(-y, -page_grp) 

# clean duplicates
  isco12_clean %>% janitor::get_dupes() # there is 1 pair of dups
  
  isco12_clean <- isco12_clean %>%
    distinct()


assertthat::assert_that( sum(str_length(isco12_clean$submajor) != 3, na.rm=TRUE) == 0 ) # should be 0 or close to



## Determine Best Matches ----
match_isic94_list <- best_match(df = isic94_clean, 
                                country_code = "class", 
                                international_code = "isic3_1")

match_isic94_table <- match_isic94_list[[1]]



match_isic09_list <- best_match(df = isic09_clean,
                                country_code = "class",
                                international_code = "isic4")

match_isic09_table <- match_isic09_list[[1]]



match_isco12_list <- best_match(df = isco12_clean,
                                country_code = "minor",
                                international_code = "isco08")

match_isco12_table <- match_isco12_list[[1]]



# save data ----
if (FALSE) {
  
# Rdata 
save(isic94_codes_raw, isic94_codes, isic94_leftover, isic94_clean, psic94_path,
     isic09_codes_raw, isic09_codes, isic09_leftover, isic09_clean, psic09_path, 
     psoc12_codes_raw, psoc12_codes, isco12_leftover, isco12_clean, psoc12_path,
     read_pdf, UNisic3,
     match_isic94_list, match_isic94_table,
     match_isic09_list, match_isic09_table, 
     match_isco12_list, match_isco12_table,
     file = file.path(PHL, "PHL_data/international_codes.Rdata") )


# export dta 
for (i in seq(from=1997,to=2011)) {
  haven::write_dta(match_isic94_table,
                   path = file.path(PHL, 
                                    paste0("PHL_",as.character(i),"_LFS"), 
                                    paste0("PHL_",as.character(i),"_LFS",
                                           "_v01_M/Data/Stata/PHL_PSIC_ISIC_94_key.dta")),
                   version = 14)
}

for (i in seq(from=2012,to=2019)) {
  haven::write_dta(match_isic09_table,
                   path = file.path(PHL, 
                                    paste0("PHL_",as.character(i),"_LFS"), 
                                    paste0("PHL_",as.character(i),"_LFS",
                                           "_v01_M/Data/Stata/PHL_PSIC_ISIC_09_key.dta")),
                   version = 14)
}

for (i in seq(from=2016,to=2019)) {
  haven::write_dta(match_isco12_table,
                   path = file.path(PHL, 
                                    paste0("PHL_",as.character(i),"_LFS"), 
                                    paste0("PHL_",as.character(i),"_LFS",
                                           "_v01_M/Data/Stata/PHL_PSOC_ISCO_12_key.dta")),
                   version = 14)
}

haven::write_dta(match_isic94_table,
                 path = file.path(PHL, "PHL_data/GLD/PHL_PSIC_ISIC_94_key.dta"),
                 version = 14)

haven::write_dta(match_isic09_table,
                 path = file.path(PHL, "PHL_data/GLD/PHL_PSIC_ISIC_09_key.dta"),
                 version = 14)

haven::write_dta(match_isco12_table,
                 path = file.path(PHL, "PHL_data/GLD/PHL_PSOC_ISCO_12_key.dta"),
                 version = 14)
}