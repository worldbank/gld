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
#   - easily-writable in-script code that covnerts the raw data to ISIC/ISCO etc 
# 
# Most of the findings here will be docuements in "Industry_Occupation Codes.md" in 
# the "Country Survey Details" Folder for the Philippines

library(tidyverse)
library(stringr)
library(pdftools)
library(janitor)



# load network data
load(PHL_meta)
if (FALSE) {load(PHL_labels)}

# pdf file path
psic_path <- file.path(PHL, "PHL_docs/International Codes/PSA_PSIC_2009.pdf")
psoc_path <- file.path(PHL, "PHL_docs/International Codes/PSA_PSOC_2012.pdf")





              ##### ISIC ####

# Import ISIC 3.0 data --------------------------------- 
# we know that only years 1997 - 2011 use this
UNisic3 <- read_delim(file = file.path(PHL, "PHL_data/GLD/international_codes/ISIC_Rev_3_english_structure.txt"))



# function ----
read_isic_pdf <- function(page) {
  
  
  # define sub-function that extracts column info from partially-processed data
  col_info <- function(data_in, xmin, xmax, varname) {
    
    tib <- data_in %>%
      filter(x >= xmin & x < xmax) %>%
      select(text, y) %>%
      mutate(varname = as.character(varname))
    
    return(tib)
  }
    
    
  # subset data loaded by pdftools
  data <- psic09[[page]] # make this the second argument
  
  data_nolabs <- data %>%
    filter(x < 155 | x > 420) %>%
    mutate(str = str_detect(text, "[:alpha:]+$")) %>%
    filter(str == FALSE)
  
  data_tib <- data_nolabs %>%
    filter(y >= 90) %>% # remove page titles, if no data, no obs.
    select(x, y, text) %>%
    
  
  
  # columns: return sub-function individually and bind
  el_class <- col_info(data_tib, xmin = 91, xmax = 130, varname = "class")
  el_subclass <- col_info(data_tib, xmin = 131, xmax = 175, varname = "subclass")
  
  el_psic1994 <- col_info(data_tib, xmin = 415, xmax = 445, varname = "psic1994")
  el_isic4 <- col_info(data_tib, xmin = 446, xmax = 500, varname = "isic4")
  el_acic <- col_info(data_tib, xmin = 501, xmax = 9999, varname = "acic")
  
  
  tib <- bind_rows(el_class, el_subclass, el_psic1994, el_isic4, el_acic) %>%
    group_by(y) %>%
    mutate(page_grp = cur_group_id(),
           page = page) %>%
    pivot_wider(names_from = "varname",
                values_from= "text")
  
  
  
  return(tib)
  
  
  
  
}

# function call ----
## first load psic data from pdftools 
psic09 <- pdftools::pdf_data(psic_path)

isic_codes_raw <- lapply(22:316, read_isic_pdf)
isic_codes_raw <- do.call(rbind, isic_codes_raw)



# single page call
read_isic_pdf(76)



# clean up result ----

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


isic_clean <- isic_codes %>%
  ## eliminate the "("
  mutate(psic1994 = str_replace(psic1994, "\\(", "")) %>%
  mutate(psic1994 = str_replace(psic1994, "\\)", "")) %>%
  ## eliminate group and class-only rows
  filter(rowAny(across(table_vars_gc, ~ !is.na(.x)))) %>% # at least 1 col must be non-NA
  filter(rowAny(across(table_vars_spia, ~ !is.na(.x)))) %>% # at least 1 col must be non-NA
  ungroup() %>%
  select(-y, -text, -page_grp)
  
# check
assertthat::assert_that( (nrow(isic_clean) + nrow(isic_leftover)) == nrow(isic_codes)   )

# clean duplicates
isic_clean %>% janitor::get_dupes() # there is 1 pair of dups

isic_clean <- isic_clean %>%
  distinct()


assertthat::assert_that( sum(str_length(isic_clean$class) <= 3) ==0 ) # should be 0 or close to
assertthat::assert_that( sum(str_length(isic_clean$group) != 3) == 0 ) # should be 0 or close to




# save data checkpoint 1 ----
save(isic_codes, isic_leftover, isic_clean, read_isic_pdf, psic_path,
     file = file.path(PHL, "PHL_data/isic_codes2.Rdata") )


# export dta 
haven::write_dta(isic_clean,
                path = file.path(PHL, "PHL_data/GLD/PHL_PSIC_ISIC_key.dta"),
                version = 14)











                  ##### ISCO ####

# Import ISCO data --------------------------------- 
read_isco_pdf <- function(page) {
  
  
  # define sub-function that extracts column info from partially-processed data
  col_info <- function(data_in, xmin, xmax, varname) {
    
    tib <- data_in %>%
      filter(x >= xmin & x < xmax) %>%
      select(text, y) %>%
      mutate(varname = as.character(varname))
    
    return(tib)
  }
  
  
  # subset data loaded by pdftools
  data <- psoc12[[page]] # make this the second argument
  
  data_tib <- data %>%
    filter(x < 160 | x > 420) %>%
    mutate(str = str_detect(text, "[:alpha:]+$")) %>%
    filter(str == FALSE) %>%
    filter(y >= 90) %>% # remove page titles, if no data, no obs.
    select(x, y, text)
  
  
  
  # columns: return sub-function individually and bind
  el_minor <- col_info(data_tib, xmin = 91, xmax = 130, varname = "minor")
  el_unit <- col_info(data_tib, xmin = 130, xmax = 175, varname = "unit")
  
  el_psoc92 <- col_info(data_tib, xmin = 450, xmax = 495, varname = "psoc92")
  el_isco08 <- col_info(data_tib, xmin = 495, xmax = 9999, varname = "isco08")

  
  tib <- bind_rows(el_minor, el_unit, el_psoc92, el_isco08) %>%
    # filter out "partial" indicated by "p;"
    filter(!grepl("^p;", text)) %>% 
    group_by(y) %>%
    mutate(page_grp = cur_group_id(),
           page = page) %>%
    pivot_wider(names_from = "varname",
                values_from= "text")
  
  
  
  return(tib)
  
  
  
  
}



# function call ----
## first load psic data from pdftools 
psoc12 <- pdftools::pdf_data(psoc_path)

psoc_codes_raw <- lapply(102:540, read_isco_pdf)
psoc_codes_raw <- do.call(rbind, psoc_codes_raw)



# single page call
read_isco_pdf(259) %>% View() # example of two vector answer




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


# clean version ----
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




# save data checkpoint 1 ----
save(isco_codes, isco_leftover, isco_clean, read_isco_pdf, psoc_path,
     file = file.path(PHL, "PHL_data/isco_codes.Rdata") )


# export dta 
haven::write_dta(isco_clean,
                 path = file.path(PHL, "PHL_data/GLD/PHL_PSOC_ISCO_key.dta"),
                 version = 14)
