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

### Factor ----
names <- metadata %>% 
  filter( grepl("prov", var_name_orig) | grepl("prv", var_name_orig), 
          class_orig == "haven_labelled" ) %>%
  pull(filename) 





import_prov_fct <- function(x) {
  
  
  
}
