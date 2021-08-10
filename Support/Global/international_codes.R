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





              ##### ISIC ####

# Import ISIC 3.0 data --------------------------------- 
# we know that only years 1997 - 2011 use this
UNisic3 <- read_delim(file = file.path(PHL, "PHL_data/GLD/international_codes/ISIC_Rev_3_english_structure.txt"))



# function ----
read_pdf <- function(page) {
  
  
  # define sub-function that extracts column info from partially-processed data
  col_info <- function(data_in, xmin, xmax, varname) {
    
    tib <- data_in %>%
      filter(x >= xmin & x < xmax) %>%
      select(text, y) %>%
      mutate(varname = as.character(varname))
    
    return(tib)
  }
    
    
  
  #final_vars <- c("y", "group", "class", "subclass", "psic1994", "isic4", "acic")
  
  #load data from PDF tools
  #psic_data <- pdftools::pdf_data(psic_path)
  
  
  # subset data loaded by pdftools
  data <- psic09[[page]] # make this the second argument
  
  data_nolabs <- data %>%
    filter(x < 155 | x > 420) %>%
    mutate(str = str_detect(text, "[:alpha:]+$")) %>%
    filter(str == FALSE)
  
  #x_min <- min(data_nolabs$x)
  
  
  data_tib <- data_nolabs %>%
    filter(y >= 98) %>% # remove page titles, if no data, no obs.
    select(x, y, text) %>%
    # manually generate group by range of x position,
    # assuming x is fixed.
    # should data already be tabular at this point?
    mutate(
      group = case_when(
        x < 90             ~ 1, # group
        x >=91  & x < 130  ~ 2, # class
        x >=131 & x < 175  ~ 3, # subclass
        x >=415 & x < 445  ~ 4, # psic1994
        x >=446 & x < 500  ~ 5, # isic4
        x >=501            ~ 6  # acic
      )
    )
  
  
  # columns: return sub-function individually and bind
  el_class <- col_info(data_tib, xmin = 91, xmax = 130, varname = "class")
  el_subclass <- col_info(data_tib, xmin = 131, xmax = 175, varname = "subclass")
  
  el_psic1994 <- col_info(data_tib, xmin = 415, xmax = 445, varname = "psic1994")
  el_isic4 <- col_info(data_tib, xmin = 446, xmax = 500, varname = "isic4")
  el_acic <- col_info(data_tib, xmin = 501, xmax = 9999, varname = "acic")
  
  
  tib <- bind_rows(el_class, el_subclass, el_psic1994, el_isic4, el_acic) %>%
    group_by(y) %>%
    mutate(page_grp = cur_group_id()) %>%
    pivot_wider(names_from = "varname",
                values_from= "text")
  
  
  
  return(tib)
  
  
  
  
}

# function call ----
## first load psic data from pdftools 
psic09 <- pdftools::pdf_data(psic_path)

isic_codes <- lapply(22:316, read_pdf)
isic_codes <- do.call(rbind, isic_codes)



# single page call
read_pdf(316)



# clean up result ----
table_vars_gc <- c("group", "class")
table_vars_spia<- c("psic1994", "isic4", "acic")
rowAny <- function(x) rowSums(x) > 0 


# this object has "leftotver stubs" that do not list any useful information.
# it only lists the structure of the group and class, which can be extracted 


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
  select(-y)
  
# check
assertthat::assert_that( (nrow(isic_clean) + nrow(isic_leftover)) == nrow(isic_codes)   )

# clean duplicates
isic_clean %>% janitor::get_dupes() # there is 1 pair of dups

isic_clean <- isic_clean %>%
  distinct()


sum(str_length(isic_clean$class) <= 3) # should be 0 or close to
sum(str_length(isic_clean$group) != 3) # should be 0 or close to

# save data checkpoint 1 ----
save(isic_codes, isic_leftover, isic_clean, read_pdf, psic_path,
     file = file.path(PHL, "PHL_data/isic_codes1.Rdata") )
