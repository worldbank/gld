# label_tools.R
# a working exploratory script to see what we can do with the metadata file
# using "region" as a working example.

library(tidyverse)
library(retroharmonize)

# load metadata
load("Y:/GLD-Harmonization/551206_TM/PHL/PHL_data/I2D2/Rdata/metadata.Rdata")


# find unique label vector
val_region <- collect_val_labels(metadata %>% 
                                   filter(label_orig == "region"))

# find value/label tibble
vallabs_region <- metadata %>%
  filter(label_orig == "region") %>%
  filter(!is.na(labels)) %>%
  select(labels) %>%
  unnest_longer(labels, 
                values_to = "value",
                indices_to = "value_label") %>%
  distinct()


# make a table to labels across time: edu 
vallab_table_edu <- metadata %>%
  filter( grepl("grade", label_orig) ) %>%
  filter(!is.na(labels)) %>%
  select(id, labels, label_orig) %>%
  unnest_longer(labels, 
                values_to = "value",
                indices_to = "value_label") %>%
  pivot_wider(names_from = id, values_from = value_label)
  

