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



# load network data
load(PHL_meta)
if (FALSE) {load(PHL_labels)}

# get function
source(file.path(code, "Global/read_pdf_table.R"))

# pdf file path
psic_path <- file.path(PHL, "PHL_docs/International Codes/PSA_PSIC_2009.pdf")
psoc_path <- file.path(PHL, "PHL_docs/International Codes/PSA_PSOC_2012.pdf")





              ##### ISIC ####

# Import ISIC 3.0 data --------------------------------- 
# we know that only years 1997 - 2011 use this
UNisic3 <- read_delim(file = file.path(PHL, "PHL_data/GLD/international_codes/ISIC_Rev_3_english_structure.txt"))

## ISIC Raw ----
isic_codes_raw <- read_pdf(
                      
    pdf_path = psic_path,
    page_min = 22,
    page_max = 316,
    varnames = c("class", "subclass", "psic1994", "isic4", "acic"),
    ymin = 90,
    xlabel = c(155, 420),
    xmin = c(91, 131, 415, 446, 501),
    xmax = c(130, 175, 445, 500, 9999)
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

isic_codes <- isic_codes_raw %>%
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

isic_leftover1 <-  isic_codes %>% 
  filter(across(all_of(table_vars_gc), ~ is.na(.x))) 

isic_leftover2 <- isic_codes %>%
  filter(across(all_of(table_vars_spia), ~is.na(.x)))

isic_leftover <- bind_rows(isic_leftover1, isic_leftover2)



## ISIC clean ----
isic_clean <- isic_codes %>%
  ## eliminate the "("
  mutate(psic1994 = str_replace(psic1994, "\\(", "")) %>%
  mutate(psic1994 = str_replace(psic1994, "\\)", "")) %>%
  ## eliminate group and class-only rows
  #filter(rowAny(across(table_vars_gc, ~ !is.na(.x)))) %>% # at least 1 col must be non-NA
  filter(rowAny(across(table_vars_spia, ~ !is.na(.x)))) %>% # at least 1 col must be non-NA
  ungroup() %>%
  select(-y, -text, -page_grp)
  
# check
assertthat::assert_that( (nrow(isic_clean) + nrow(isic_leftover2)) == nrow(isic_codes)   )


isic_clean %>% janitor::get_dupes() # there is 1 pair of dups

isic_clean <- isic_clean %>%
  distinct()


assertthat::assert_that( sum(str_length(isic_clean$class) <= 3, na.rm = TRUE) ==0 ) # should be 0 or close to
assertthat::assert_that( sum(str_length(isic_clean$group) != 3, na.rm = TRUE) == 0 ) # should be 0 or close to












                  ##### ISCO ####



# Use Function to import raw data 
# ISCO raw ----

psoc_codes_raw <- read_pdf(
  
      pdf_path = psoc_path,
      page_min = 102,
      page_max = 540,
      varnames = c("minor", "unit", "psoc92", "isco08"),
      ymin = 90,
      xlabel = c(160, 420),
      xmin = c(91, 130, 450, 495),
      xmax = c(130, 175, 495, 9999)
  
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

isco_codes <- psoc_codes_raw %>%
  mutate(
    minor    = case_when(is.na(minor)  ~ str_sub(unit, 1,4),
                      TRUE          ~ minor),
    submajor = str_sub(minor, 1,3)) %>%
  select(y, page_grp, page, submajor, minor, unit, psoc92, isco08)



# filter out leftoverstubs 
isco_leftover1 <-  isco_codes %>% 
  filter(across(all_of(table_vars_sm), ~ is.na(.x))) 

isco_leftover2 <- isco_codes %>%
  filter(across(all_of(table_vars_pi), ~is.na(.x)))

isco_leftover <- bind_rows(isco_leftover1, isco_leftover2)



# ISCO clean ----
## note that for now in order to sidestep issue #96, will not filter yet
isco_clean <- isco_codes %>%
  ## eliminate group and class-only rows
  #filter(rowAny(across(table_vars_sm, ~ !is.na(.x)))) %>% # at least 1 col must be non-NA
  filter(rowAny(across(table_vars_pi, ~ !is.na(.x)))) # at least 1 col must be non-NA
  
  # check
  assertthat::assert_that( (nrow(isco_clean) + nrow(isco_leftover2)) == nrow(isco_codes)   )

  ## eliminate strange puncutation marks
  isco_clean <- isco_clean %>%
    mutate(psoc92 = str_replace(psoc92, "[:punct:]", "")) %>%
    mutate(psoc92 = str_replace(psoc92, "p", "")) %>% 
    mutate(psoc92 = str_replace(psoc92, "\\`", NA_character_)) %>% 
    mutate(psoc92 = str_replace(psoc92, " ", NA_character_)) %>% 
    ungroup() %>%
    select(-y, -page_grp) 

# clean duplicates
  isco_clean %>% janitor::get_dupes() # there is 1 pair of dups
  
  isco_clean <- isco_clean %>%
    distinct()


assertthat::assert_that( sum(str_length(isco_clean$submajor) != 3, na.rm=TRUE) == 0 ) # should be 0 or close to





# save data ----

# Rdata 
save(isic_codes_raw, isic_codes, isic_leftover, isic_clean, psic_path, 
     psoc_codes_raw, isco_codes, isco_leftover, isco_clean, psoc_path,
     read_pdf, UNisic3,
     file = file.path(PHL, "PHL_data/international_codes.Rdata") )


# export dta 
haven::write_dta(isic_clean,
                 path = file.path(PHL, "PHL_data/GLD/PHL_PSIC_ISIC_key.dta"),
                 version = 14)

haven::write_dta(isco_clean,
                 path = file.path(PHL, "PHL_data/GLD/PHL_PSOC_ISCO_key.dta"),
                 version = 14)
