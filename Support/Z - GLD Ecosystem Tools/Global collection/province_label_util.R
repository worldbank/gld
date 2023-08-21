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
library(haven)


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



## Join String and Factor Data -----
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
  # generate the number of distinct labels per value (number), use the normalized label.
  group_by(value) %>% 
  mutate(n_vals = (n_distinct(label_norm, na.rm = TRUE)), 
         same = (n_vals == 1) # TRUE if all string values are the same (for labelled variables)
         ) %>%
  ungroup() %>%
  mutate(
    source = case_when( !is.na(n_vals_str) ~ "string",
                        !is.na(n_vals_fct) ~ "factor")
  ) %>%
  filter(!is.na(label_norm)) %>%
  arrange(label_norm) 

# filter workflow: ----
# goal here is to present different labels to come to concensus manually, so we'll 
# separate out into labels that are unique vs labels that have multiple labels per value

# create the label replace function 
discrep_lab_replace <- function(value) {
  case_when(
    as.numeric(value) == 2       ~ "agusan_del_norte",
    as.numeric(value) == 23      ~ "davao_del_norte",
    as.numeric(value) == 24      ~ "davao_del_sur",
    as.numeric(value) == 39      ~ "national_capital_region_1st_district",
    as.numeric(value) == 44      ~ "mountain_province",
    as.numeric(value) == 47      ~ "north_cotabato",
    as.numeric(value) == 50      ~ "nueva_vizcaya",
    as.numeric(value) == 51      ~ "occidental_mindoro",
    as.numeric(value) == 52      ~ "oriental_mindoro",
    as.numeric(value) == 60      ~ "western_samar",
    as.numeric(value) == 70      ~ "tawi_tawi",
    as.numeric(value) == 74      ~ "national_captial_region_2nd_district",
    as.numeric(value) == 75      ~ "national_captial_region_3rd_district",
    as.numeric(value) == 76      ~ "national_captial_region_4th_district",
    as.numeric(value) == 80      ~ "sarangani",
    as.numeric(value) == 98      ~ "marawi_city_and_cotabato_city",
    TRUE             ~ NA_character_
  )
}

# create the "discrepancy" tibble
prov_lab_discrep <- prov_labs %>%
  filter(n_vals > 1, !is.na(label_norm)) %>%
  distinct(value, label_norm, .keep_all = TRUE) %>%
  pivot_wider(values_from = label_norm,
              names_from = survey,
              id_cols = value) %>%
  arrange(value) %>%
  # replace labels manually 
  mutate(label_replace = discrep_lab_replace(value = value))


# create the "same" table where labels are same within each value 

# determine list of LFS variables 
lfs_vars <- as.character(unique(prov_labs$survey))

prov_labs_same <- prov_labs %>%
  filter(n_vals == 1) %>%
  distinct(value, label_norm, .keep_all = TRUE) %>%
  pivot_wider(values_from = label_norm,
              names_from = survey,
              id_cols = value) %>%
  arrange(value) %>%
  mutate(label = coalesce(LFS_OCT2002, LFS_JAN2007, LFS_OCT2016))



## create the final label table

### Assemble the pieces 

prov_lab_discrep_assemble <- prov_lab_discrep %>%
  nest(labels_raw = any_of(lfs_vars)) %>%
  mutate(value = as.numeric(value),
         change = TRUE) %>%
  rename(label_norm = label_replace)

prov_lab_same_assemble <- prov_labs_same %>%
  nest(labels_raw = any_of(lfs_vars)) %>%
  mutate(value = as.numeric(value),
         change = FALSE) %>%
  rename(label_norm = label)

prov_lab_final <- bind_rows(
  prov_lab_discrep_assemble, 
  prov_lab_same_assemble
  ) %>%
  arrange(value) %>%
  # a few manual adjustments to to_title_case()
  mutate(label = snakecase::to_title_case(label_norm),
         label = case_when(
           as.numeric(value) == 39      ~ "National Capital Region: 1st District",
           as.numeric(value) == 74      ~ "National Capital Region: 2nd District",
           as.numeric(value) == 75      ~ "National Capital Region: 3rd District",
           as.numeric(value) == 76      ~ "National Capital Region: 4th District",
           TRUE ~ label
           ),
         label_gld = paste0(as.character(value), " - ", label)
         ) %>%
  select(value, change, label, label_gld, label_norm, everything())


# checks
assertthat::assert_that( nrow(prov_lab_final) == n_distinct(prov_lab_final$value) )
assertthat::assert_that( nrow(prov_lab_final) == n_distinct(prov_lab_final$label_norm) )



# create a .dta friendly object and save .Rdata ----
prov_lab_final_export <- select(prov_lab_final, -labels_raw, -change )

## export to each year's directory
for (i in seq(from=1997,to=2019)) {
  haven::write_dta(prov_lab_final_export,
                   path = file.path(PHL, 
                                    paste0("PHL_",as.character(i),"_LFS"), 
                                    paste0("PHL_",as.character(i),"_LFS",
                                           "_v01_M/Data/Stata/GLD_PHL_admin2_labels.dta")),
                   version = 14)
}

## export a main version
haven::write_dta(prov_lab_final_export, 
                 file.path(PHL, "PHL_data/GLD/GLD_PHL_admin2_labels.dta"),
                 version = 14)

## export Rdata
save(prov_labs,
     prov_labs_chr, 
     prov_labs_fct,
     prov_lab_final,
     prov_lab_final_export,
     file = file.path(PHL, "PHL_data/GLD/GLD_PHL_admin2_labels.Rdata"))
