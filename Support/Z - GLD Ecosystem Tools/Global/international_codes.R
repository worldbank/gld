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
library(stringdist)
library(magrittr)
library(readxl)
library(hablar)


# source main 
here::i_am("main.R")
source("main.R")


# load network data
load(PHL_meta)
if (FALSE) {load(PHL_labels)}

# get functions
source(file.path(code, "Global/read_pdf_table.R"))
source(file.path(code, "Global/correspondance.R"))
source(file.path(code, "Global/import_surveys.R"))

# pdf file path
psic94_path <- file.path(PHL, "PHL_docs/International Codes/PSA_PSIC_1994.pdf")
psic09_path <- file.path(PHL, "PHL_docs/International Codes/PSA_PSIC_2009.pdf")
psoc12_path <- file.path(PHL, "PHL_docs/International Codes/PSA_PSOC_2012.pdf")
isco88_08_path <- file.path(PHL, "PHL_docs/International Codes/wcms_172572.pdf")
isco88_08_xls_path <- file.path(PHL, "PHL_docs/International Codes/corrtab88-08.xls")
isco88_08_2dig_xls_path <- file.path(PHL, "PHL_docs/International Codes/ISCO.xlsx")




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
  select(-page_grp)

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
    ymin = 82,
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
      ymin = 85,
      xlabel = c(160, 420),
      xmin = c(91, 130, 450, 475),
      xmax = c(130, 175, 492, 9999),
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
    minor    = case_when(is.na(minor)  ~ str_sub(unit, 1,3),
                      TRUE          ~ minor),
    submajor = str_sub(minor, 1,2)) %>%
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
  filter(rowAny(across(table_vars_sm, ~ !is.na(.x)))) %>% # at least 1 col must be non-NA
  filter(rowAny(across(all_of(table_vars_pi), ~ !is.na(.x)))) # at least 1 col must be non-NA

  # check
  assertthat::assert_that( (nrow(isco12_clean) + nrow(isco12_leftover))
                           == nrow(psoc12_codes)   )

  ## eliminate strange puncutation marks
  isco12_clean <- isco12_clean %>%
    mutate(psoc92 = str_replace(psoc92, "[:punct:]", "")) %>%
    mutate(psoc92 = str_replace(psoc92, "p", "")) %>%
    mutate(psoc92 = str_replace(psoc92, "\\`", NA_character_)) %>%
    mutate(psoc92 = str_replace(psoc92, " ", NA_character_)) %>%
    ungroup() %>%
    select(-page_grp)

# clean duplicates
  isco12_clean %>% janitor::get_dupes() # there is 1 pair of dups

  isco12_clean <- isco12_clean %>%
    distinct()


assertthat::assert_that( sum(str_length(isco12_clean$submajor) != 2, na.rm=TRUE) == 0 ) # should be 0 or close to








# Isco88-08 ------------

## raw ----

isco88_08_raw <- read_xls(path = isco88_08_xls_path,
                          sheet= "Sheet1",
                          col_types = "text",
                          col_names = TRUE)

## clean ----

isco88_08_clean <- isco88_08_raw %>%
  rename("title88" = "ISCO-88 Title EN",
         "title08" = "ISCO-08 Title EN",
         "isco88"  = "ISCO-88 code",
         "isco08"  = "ISCO 08 Code",
         "part08"  = "ISCO-08 part",
         "comments"= "Comments") %>%
  select(isco88, isco08, part08, title08) %>%
  mutate()



# 2 digit versions ------

# all "2-digit" versions will have numerals at the first two digits but will be padded to the
# right with 0's such that they fill 4 digits worth of space 

## PSOC92-ISCO88 ----
## There is no PDF version of a 4-digit PSOC92 to isco08, but a 2 digit
## version can be created semi-manually with relative ease since there
## are only about 30 distinct codes at the 2 digit level.
##
## Furthermore, the ILO publish a 2-digit conversion scheme between
## ISCO88 - ISCO08. Start by importing all the codes from the ISCO88
## column of this document and, since most codes in PSOC are the same
## anyway, replace manually.
##
## General note: I will assume that all farming and agricultural-related
## activities are market-based since it is not stated in PSOC, thus will
## code appropriately in ISCO below.

psoc92_2dig_raw <- read_xlsx(path = isco88_08_2dig_xls_path,
                        sheet = "ISCO_SKILLS",
                        range = "I2:L46",
                        col_names = TRUE,
                        col_types = "text")

psoc92_2dig <- psoc92_2dig_raw %>%
  rename_with(.cols = everything(), .fn = ~ paste0("isco88_", .x)) %>%
  filter(!is.na(isco88_sub_major)) %>%
    # start with PSOC as isco88 as default, then change as needed
  mutate( psoc92 = isco88_sub_major)  %>%
  select(psoc92, isco88_sub_major, everything()) %>%
    # make manual changes
  mutate(psoc92 = case_when(psoc92 == "62" ~ "*removethis*", # substistence ag not listed in PSOC
                            TRUE ~ as.character(psoc92)),
         psoc92_description = NA_character_) %>%
  # add PSOC data
  add_row(psoc92 = "14", isco88_sub_major = "13",
          psoc92_description = "Supervisors") %>% # Supervisors to general managers
  add_row(psoc92 = "62", isco88_sub_major = "61",
          psoc92_description = "Animal Producers") %>% # Animal produces to market agriculture
  add_row(psoc92 = "63", isco88_sub_major = "61",
          psoc92_description = "Forestry and Related Workers") %>% # forestry to market agriculture
  add_row(psoc92 = "64", isco88_sub_major = "61",
          psoc92_description = "Fisherman") %>% # fisherman to market agriculture
  add_row(psoc92 = "65", isco88_sub_major = "61",
          psoc92_description = "Hunters") %>% # hunters to market agriculture
  add_row(psoc92 = "02", isco88_sub_major = "51",
          psoc92_description = "Housekeepers, Pensioners, Students") %>% # housekeepers etc to personal/protective services
  add_row(psoc92 = "09", isco88_sub_major = NA_character_,
          psoc92_description = "Not Classifiable and Other Occupations")  %>% # Not classifiable to missing
  filter(psoc92 != "*removethis*")

### map isco08 colums ----
### The easiest way to introduce ISCO08 conversions is to include a isco08 column directly
### in the PSOC92-ISCO88 key. This way we can merge directly and gain the ISCO08 information.

## Import ISCO88-ISCO08 Key
isco88_08_2dig_raw <- read_xlsx(path = isco88_08_2dig_xls_path,
                                sheet = "ISCO_SKILLS",
                                range = "A1:L46",
                                col_names = FALSE,
                                col_types = "text")

## Clean Key
isco88_08_2dig <- isco88_08_2dig_raw %>%
  janitor::row_to_names(2, remove_row = T, remove_rows_above = T) %>%
  clean_names() %>%
  rename_with(.cols = ends_with("_2"), .fn = ~ gsub("_2", "_isco88",.x)) %>%
  rename_with(.cols = c("major", "sub_major", "major_label", "description"), .fn = ~ paste0(.x, "_isco08")) %>%
  fill(skill) %>%
  fill(skill_label) %>%
  fill(aggregate) %>%
  fill(aggregate_label) %>%
  mutate(across(c(major_isco08, major_isco88), ~ dplyr::na_if(.x, "X"))) # replace "X" with "NA"



## Join Key to PSOC92-ISCO88 Key
psoc92_2dig_isco08_key <- psoc92_2dig %>%
  left_join(isco88_08_2dig,
            by = c("isco88_sub_major" = "sub_major_isco88"),
            keep = FALSE,
            na_matches = "never") %>%
  mutate(across(c("psoc92", "isco88_sub_major", "sub_major_isco08"), 
                ~ stringr::str_pad(.x, 4, "right", "0"), .names = "{.col}_pad"))





## Determine Best Matches ----
match_isic94_list <- corresp(df = isic94_clean,
                                country_code = class,
                                international_code = isic3_1,
                                pad_vars = "isic3_1",
                                check_matches = F)

match_isic94_table <- match_isic94_list[[1]] %>%
  distinct()



match_isic09_list <- corresp(df = isic09_clean,
                             country_code = class,
                             international_code = isic4,
                             pad_vars = "isic4",
                             check_matches = F)

match_isic09_table <- match_isic09_list[[1]] %>%
  distinct()



match_isco12_list <- corresp(df = isco12_clean,
                                unit,
                                isco08,
                                pad_vars = "isco08",
                                check_matches = F)

match_isco12_table <- match_isco12_list[[1]]



match_isco88_08_list <- corresp(df = isco88_08_clean,
                                country_code = isco88,
                                international_code = isco08,
                                pad_vars = c("isco08", "isco88"),
                                check_matches = F)


match_isco88_08_table <- match_isco88_08_list[[1]] 


# create a 2-digit match tables ----
## for isco88-to-08
isco88_08_2dig <- isco88_08_clean %>%
  mutate(isco08_2dig = stringr::str_sub(isco08, 1,2),
         isco88_2dig = stringr::str_sub(isco88, 1,2)) %>%
  #distinct(across(contains("2dig")), .keep_all = TRUE) %>%
  select(contains("2dig"), "title08") %>%
  mutate(across(c("isco08_2dig", "isco88_2dig"), 
                ~ stringr::str_pad(.x, 4, "right", "0"), .names = "{.col}_pad"))


## for ISIC09
raw_2dig_isic09 <- match_isic09_table %>%
  select(class, isic4) %>%
  mutate(
    psic_2dig = str_sub(class, 1,2),
    isic4_2dig= str_sub(isic4, 1,2))

match_isic09_2dig_list <- corresp(df = raw_2dig_isic09,
                                  psic_2dig,
                                  isic4_2dig,
                                  pad_vars = NULL,
                                  check_matches = F)

match_isic09_2dig_table <- match_isic09_2dig_list[[1]] %>%
  mutate(across(c("psic_2dig", "isic4_2dig"), 
                ~ stringr::str_pad(.x, 4, "right", "0"), .names = "{.col}_pad"))


## for ISIC94
raw_2dig_isic94 <- match_isic94_table %>%
  select(class, isic3_1) %>%
  mutate(
    psic_2dig = str_sub(class, 1,2),
    isic3_1_2dig= str_sub(isic3_1, 1,2))

match_isic94_2dig_list <- corresp(df = raw_2dig_isic94,
                                  psic_2dig,
                                  isic3_1_2dig,
                                  pad_vars = NULL,
                                  check_matches = F)

match_isic94_2dig_table <- match_isic94_2dig_list[[1]] %>%
  mutate(across(c("psic_2dig", "isic3_1_2dig"), 
                ~ stringr::str_pad(.x, 4, "right", "0"), .names = "{.col}_pad"))

## for ISCO12
raw_2dig_isco12 <- match_isco12_table %>%
  select(unit, isco08) %>%
  mutate(
    psic_2dig = str_sub(unit, 1,2),
    isco08_2dig= str_sub(isco08, 1,2))

match_isco12_2dig_list <- corresp(df = raw_2dig_isco12,
                                  psic_2dig,
                                  isco08_2dig,
                                  pad_vars = NULL,
                                  check_matches = F)

match_isco12_2dig_table <- match_isco12_2dig_list[[1]] %>%
  mutate(across(c("psic_2dig", "isco08_2dig"), 
                ~ stringr::str_pad(.x, 4, "right", "0"), .names = "{.col}_pad"))



# create a 2-digit match table for isco88-to-08
isco88_08_2dig <- isco88_08_clean %>%
  mutate(isco08_2dig = stringr::str_sub(isco08, 1,2),
         isco88_2dig = stringr::str_sub(isco88, 1,2)) %>%
  #distinct(across(contains("2dig")), .keep_all = TRUE) %>%
  select(contains("2dig"), "title08")

match_isco88_08_2dig_list <- corresp(df = isco88_08_2dig,
                                     country_code = isco88_2dig,
                                     international_code = isco08_2dig,
                                     pad_vars = NULL,
                                     check_matches = F)

match_isco88_08_2dig_table <- match_isco88_08_2dig_list[[1]] %>%
  mutate(across(c("isco88_2dig", "isco08_2dig"), 
                ~ stringr::str_pad(.x, 4, "right", "0"), .names = "{.col}_pad"))


# save data ----
if (TRUE) {

# Rdata
save(isic94_codes_raw, isic94_codes, isic94_leftover, isic94_clean, psic94_path,
     isic09_codes_raw, isic09_codes, isic09_leftover, isic09_clean, psic09_path,
     psoc12_codes_raw, psoc12_codes, isco12_leftover, isco12_clean, psoc12_path,
     read_pdf, UNisic3, corresp,
     match_isic94_list, match_isic94_table,
     match_isic09_list, match_isic09_table,
     match_isco12_list, match_isco12_table,
     match_isco88_08_list, match_isco88_08_table,
     match_isco88_08_2dig_list, match_isco88_08_2dig_table,
     match_isic09_2dig_list, match_isic09_2dig_table,
     match_isic94_2dig_list, match_isic94_2dig_table,
     match_isco12_2dig_list, match_isco12_2dig_table,
     psoc92_2dig, psoc92_2dig_isco08_key, isco88_08_2dig,
     file = file.path(PHL, "PHL_data/international_codes.Rdata") )


# export dta
for (i in seq(from=1997,to=2011)) {
  haven::write_dta(match_isic94_table,
                   path = file.path(PHL,
                                    paste0("PHL_",as.character(i),"_LFS"),
                                    paste0("PHL_",as.character(i),"_LFS",
                                           "_v01_M/Data/Stata/PHL_PSIC_ISIC_94_key.dta")),
                   version = 14)
  haven::write_dta(match_isic94_2dig_table,
                   path = file.path(PHL,
                                    paste0("PHL_",as.character(i),"_LFS"),
                                    paste0("PHL_",as.character(i),"_LFS",
                                           "_v01_M/Data/Stata/PHL_PSIC_ISIC_94_key_2dig.dta")),
                   version = 14)
}

for (i in seq(from=2012,to=2019)) {
  haven::write_dta(match_isic09_table,
                   path = file.path(PHL,
                                    paste0("PHL_",as.character(i),"_LFS"),
                                    paste0("PHL_",as.character(i),"_LFS",
                                           "_v01_M/Data/Stata/PHL_PSIC_ISIC_09_key.dta")),
                   version = 14)
  haven::write_dta(match_isic09_2dig_table,
                   path = file.path(PHL,
                                    paste0("PHL_",as.character(i),"_LFS"),
                                    paste0("PHL_",as.character(i),"_LFS",
                                           "_v01_M/Data/Stata/PHL_PSIC_ISIC_09_key_2dig.dta")),
                   version = 14)
}

for (i in seq(from=2016,to=2019)) {
  haven::write_dta(match_isco12_table,
                   path = file.path(PHL,
                                    paste0("PHL_",as.character(i),"_LFS"),
                                    paste0("PHL_",as.character(i),"_LFS",
                                           "_v01_M/Data/Stata/PHL_PSOC_ISCO_12_key.dta")),
                   version = 14)
  haven::write_dta(match_isco12_2dig_table,
                   path = file.path(PHL,
                                    paste0("PHL_",as.character(i),"_LFS"),
                                    paste0("PHL_",as.character(i),"_LFS",
                                           "_v01_M/Data/Stata/PHL_PSOC_ISCO_12_key_2dig.dta")),
                   version = 14)
}

for (i in seq(from=1997,to=2016)) {
  haven::write_dta(psoc92_2dig_isco08_key,
                   path = file.path(PHL,
                                    paste0("PHL_",as.character(i),"_LFS"),
                                    paste0("PHL_",as.character(i),"_LFS",
                                           "_v01_M/Data/Stata/PHL_PSOC92_ISCO88_08_key.dta")),
                   version = 14)

}

for (i in seq(from=2016,to=2016)) {
haven::write_dta(match_isco88_08_table,
                 path = file.path(PHL,
                                  paste0("PHL_",as.character(i),"_LFS"),
                                    paste0("PHL_",as.character(i),"_LFS",
                                           "_v01_M/Data/Stata/PHL_PSOC_ISCO_88_08_key.dta")),
                   version = 14)
}

for (i in seq(from=2016,to=2016)) {
  haven::write_dta(match_isco88_08_2dig_table,
                   path = file.path(PHL,
                                    paste0("PHL_",as.character(i),"_LFS"),
                                    paste0("PHL_",as.character(i),"_LFS",
                                           "_v01_M/Data/Stata/PHL_PSOC_ISCO_88_08_key_2digits.dta")),
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


haven::write_dta(match_isco88_08_table,
                 path = file.path(PHL, "PHL_data/GLD/PHL_PSOC_ISCO_88_08_key.dta"),
                 version = 14)

haven::write_dta(match_isco88_08_2dig_table,
                 path = file.path(PHL, "PHL_data/GLD/PHL_PSOC_ISCO_88_08_key_2digits.dta"),
                 version = 14)

haven::write_dta(match_isic94_2dig_table,
                 path = file.path(PHL, "PHL_data/GLD/PHL_PSIC_ISIC_94_key_2dig.dta"),
                 version = 14)

haven::write_dta(match_isic09_2dig_table,
                 path = file.path(PHL, "PHL_data/GLD/PHL_PSIC_ISIC_09_key_2dig.dta"),
                 version = 14)

haven::write_dta(match_isco12_2dig_table,
                 path = file.path(PHL, "PHL_data/GLD/PHL_PSOC_ISCO_12_key_2dig.dta"),
                 version = 14)

haven::write_dta(psoc92_2dig_isco08_key,
                 path = file.path(PHL, "PHL_data/GLD/PHL_PSOC92_ISCO88_08_key.dta"),
                 version = 14)

}
