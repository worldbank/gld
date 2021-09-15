# weights_analysis.R
# assume you run main.R

library(tidyverse)
library(retroharmonize)


# import all surveys 
## first, use the import function 
load(PHL_meta)

## import 
## pull the list of surveys (.Rds files we just generated)
surveys <- files_tib %>%
  pull(rpath)


## read in the surveys
waves <- read_surveys(surveys,
                      .f = "read_rds",
                      save_to_rds = FALSE)

## create a list of weight variables
weight_vars <- metadata %>% 
  filter(grepl("weight", label_orig)) %>%
  distinct(var_name_orig) %>%
  pull()


##filtering within a list...