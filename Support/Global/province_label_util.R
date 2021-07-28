# prov_label_util.R
# combines string and labeled data to create a harmonized object by value/label for provinces 
# 
# the goal of this script is to harmonize the 2nd-level administrative level labels. It is conducted for PHL 
# but is meant to be somewhat generalize-able if needed since it is run from the metadata file, which is 
# generalized. The task is somewhat different that the 1-st level administrative regions because of the data
# are stored differently and docuemented differently. The main product will be a table objects with a value and 
# either 1 or two columns for the province/admin2 label. There may be 2 columns because there is at least 1 aministrative 
# change in or around 2003, and so names may change. 


              # Introduction ----
                
# note, run main.R first 

library(tidyverse)
library(retroharmonize)


# load metadata and files tibble 
load(PHL_meta)


# we know that the province data fall into one of three cases:
# 1. haven_labelled/factor
# 2. numeric, with no label
# 3. numeric, with a separate prov_name variable encoded as string
# All three of these data types will need to be harmonized




# Import the data ----
# I think the best way to do this is to create a function that imports only the variabl we
# need based on the data type in each year 

## Identify data files for each type ----
## we need to know which data files have data that fall under each variable type


## Factor ---- 
## retroharmonize has a function for doing most of the work for us, using the metadata 
prov_labs_fct <- metadata %>%
  filter( grepl("prov", var_name_orig) | grepl("prv", var_name_orig), class_orig == "haven_labelled" ) %>%
  filter(!is.na(labels)) %>%
  select(id, labels) %>%
  unnest_longer(labels, 
                values_to = "value",
                indices_to = "value_label") %>%
  group_by(value) %>%
  mutate(n_vals_fct = (n_distinct(value_label)), # generates the number of unique values for each value label
         same_fct = (n_vals_fct == 1), # TRUE if all string values are the same (for fact labelled variables)
         ) %>%  
  ungroup() %>%
  mutate(id = str_replace(id, " ", "_")) %>%
  pivot_wider(names_from = id, values_from = value_label) %>%
  arrange(value)



## numeric with string ----
## these variables are not in the metadata, so we have import the files and extract this for
## each file 


# make a list of file names that have character data
files_chr <- metadata %>% 
  filter( grepl("prov_name", var_name_orig), 
          class_orig == "character" ) %>%
  pull(id) 

# filter the files tibble
files_tib_import <- files_tib %>%
  mutate(name = str_sub(filename, 2),
         obname = str_replace(name, " ", "_")) %>%
  filter(name %in% files_chr )


# import all of them 

import_labs_str <- function(x, y) {
  
  file <- readRDS(x) %>%
    select(any_of(c(contains("prov"), contains("prv"), contains("_name")))) %>%
    distinct() %>%
    mutate( survey = as.character(y),
            label  = snakecase::to_title_case(prov_name),
            value  = prov)
  
  if (y == "LFS_JAN2007" | y == "LFS_JAN2017") {
    file <- file %>%
      distinct(prov, prov_name, .keep_all = TRUE)
  }
  
  file <- file %>%
    select(survey, label, value) %>%
    distinct()
  
  return(file)
  
}


chr_survey_list <- map2(
  .x = files_tib_import$rpath,
  .y = files_tib_import$obname,
  .f = import_labs_str
)

prov_labs_chr <- bind_rows(chr_survey_list) %>%
  group_by(value) %>%
  mutate(n_vals_str = (n_distinct(label)), # generates the number of unique values for each value label
          same_str = (n_vals_str == 1) # TRUE if all string values are the same (for string labelled variables)
          ) %>%
  ungroup() %>%
  pivot_wider(names_from = survey,
              values_from= label)



## Join String and Factor Data
## The goal here is to join the two haven labelled and string labelled objects by value to see if we can
## harmonize the province labels

# pivot
prov_labs_chr_long <- prov_labs_chr %>%
  pivot_longer(cols = starts_with("LFS"), names_to = "survey", values_to = "label")

prov_labs_fct_long <- prov_labs_fct %>%
  pivot_longer(cols = starts_with("LFS"), names_to = "survey", values_to = "label")


# append 
prov_labs_long <- bind_rows(prov_labs_chr_long, prov_labs_fct_long)

prov_labs <- prov_labs_long %>%
  mutate(label_norm = val_label_normalize(label)) %>% # normalize the label
  group_by(value) %>%
  mutate(n_vals = (n_distinct(label_norm)), # generates the number of unique values for each value label
         same = (n_vals == 1) # TRUE if all string values are the same (for labelled variables)
        ) %>%
  ungroup() 

# what do to from here?
  filter(!is.na(label_norm)) %>%
  distinct(value, label_norm) %>%
  pivot_wider(names_from = survey,
              values_from= label_norm)
