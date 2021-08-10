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
  
  final_vars <- c("y", "group", "class", "subclass", "psic1994", "isic4", "acic")
  
  data <- psic09_data[[page]] 
  
  data_nolabs <- data %>%
    filter(x < 155 | x > 420) %>%
    mutate(str = str_detect(text, "[:alpha:]+$")) %>%
    filter(str == FALSE)
  
  x_min <- min(data_nolabs$x)
  
  
  
  # if the page is "blank" in terms of table data, return nothing
  if (nrow(data_nolabs) == 0) {
    return(NULL)
  
    } else {
    
      data_tib <- data_nolabs %>%
        filter(y >= 98) %>% # remove page titles, if no data, no obs.
        select(x, y, text) %>%
        # manually generate group by range of x position,
        # assuming x is fixed 
        mutate(
          group = case_when(
            x < 90             ~ 1, # group
            x >=91  & x < 130  ~ 2, # class
            x >=131 & x < 175  ~ 3, # subclass
            x >=415 & x < 445  ~ 4, # psic1994
            x >=446 & x < 500  ~ 5, # isic4
            x >=501            ~ 6  # acic
          )
        ) %>%
        group_by(group) %>%
        mutate(count = n(),
               #x_grp = cur_group_id(),
               group = cur_group_id()) %>%
        arrange(group) %>%
        pivot_wider(names_from = "group",
                    names_prefix= "var",
                    values_from = "text") 
      # if x_min < 90, then there will only be 5 variables, 
      # so generate an empty variable for "group". This means there
      # was no "group" data on the page.
      
      if (x_min > 89) {
        data_tib2 <- data_tib %>%
          mutate(var0 = NA_character_) %>%
          rename_with(matches("var0"), .fn = ~paste0("group")) %>%
          rename_with(matches("var1"), .fn = ~paste0("class")) %>%
          rename_with(matches("var2"), .fn = ~paste0("subclass")) %>%
          rename_with(matches("var3"), .fn = ~paste0("psic1994")) %>%
          rename_with(matches("var4"), .fn = ~paste0("isic4")) %>%
          rename_with(matches("var5"), .fn = ~paste0("acic")) %>%
          select(x, y, any_of(final_vars)) %>%
          arrange(y)
      } else {
        data_tib2 <- data_tib %>%
          rename_with(matches("var1"), .fn = ~paste0("group")) %>%
          rename_with(matches("var2"), .fn = ~paste0("class")) %>%
          rename_with(matches("var3"), .fn = ~paste0("subclass")) %>%
          rename_with(matches("var4"), .fn = ~paste0("psic1994")) %>%
          rename_with(matches("var5"), .fn = ~paste0("isic4")) %>%
          rename_with(matches("var6"), .fn = ~paste0("acic")) %>%
          select(x, y, any_of(final_vars)) %>%
          arrange(y)
        
      }
    
    # almost there, but we need to vertically collapse. there are different
    # x groups that have the same y value that should all be in the same row
      # generate empty variables if NA
      
      final_cols <- c(group = NA_character_,
                      class = NA_character_,
                      subclass = NA_character_,
                      psic1994 = NA_character_,
                      isic4 = NA_character_,
                      acic = NA_character_)
      
      sum <- data_tib2 %>% 
        ungroup() %>%
        add_column(!!!final_cols[!names(final_cols) %in% names(.)]) %>%
        group_by(y) %>%
        summarize(
          group = group[which(!is.na(group))[1]],
          class = class[which(!is.na(class))[1]],
          subclass = subclass[which(!is.na(subclass))[1]],
          psic1994 = psic1994[which(!is.na(psic1994))[1]],
          isic4 = isic4[which(!is.na(isic4))[1]],
          acic = acic[which(!is.na(acic))[1]]
        ) %>%
        mutate(
          class = case_when(is.na(class) ~ replace_na(stringr::str_sub(subclass, 1,3)),
                            TRUE ~ class),
          group = case_when(is.na(group) ~ replace_na(stringr::str_sub(class, 1,3)),
                            TRUE ~ group))
    
    
    return(sum)
    
  }  
  
}

# function call ----
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
