# label_tools.R
# a working exploratory script to see what we can do with the metadata file
# using "region" as a working example.

renv::activate()

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


vallabs_edu14 <- metadata %>%
  filter(grepl("14", id), grepl("grade", var_name_orig)) %>%
  select(labels, id) %>%
  unnest_longer(labels, 
           values_to = "value",
           indices_to = "value_label") %>%
  arrange(value) %>%
  pivot_wider(names_from = id, 
              values_from = "value_label") %>%
  distinct() 


vallabs_edu18 <- metadata %>%
  filter(grepl("18", id), grepl("pufc07", var_name_orig)) %>%
  select(labels, id) %>%
  unnest_longer(labels, 
                values_to = "value",
                indices_to = "value_label") %>%
  arrange(value) %>%
  pivot_wider(names_from = id, 
              values_from = "value_label") %>%
  distinct() 


vallabs_edu19 <- metadata %>%
  filter(grepl("19", id), grepl("pufc07", var_name_orig)) %>%
  select(labels, id) %>%
  filter(!is.na(labels)) %>%
  unnest_longer(labels, 
                values_to = "value",
                indices_to = "value_label") %>%
  arrange(value) %>%
  pivot_wider(names_from = id, 
              values_from = "value_label") %>%
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
  

vallab_table_edu_nolab <- metadata %>%
  filter( grepl("grade", label_orig) ) %>%
  filter(!is.na(labels)) %>%
  select(id, labels) %>%
  unnest_longer(labels, 
                values_to = "value",
                indices_to = "value_label") %>%
  pivot_wider(names_from = id, values_from = value_label) %>%
  arrange(value)


# identify "intvw" variable across years 
intv <- metadata %>%
  filter( grepl("intvw", var_name_orig)) %>%
  filter(!is.na(labels)) %>%
  select(id, labels, label_orig) %>%
  unnest_longer(labels, 
                values_to = "value",
                indices_to = "value_label") 


# create region object
vallab_tab_reg <- metadata %>%
  filter( grepl("reg", label_orig) ) %>%
  filter(!is.na(labels)) %>%
  select(id, labels) %>%
  unnest_longer(labels, 
                values_to = "value",
                indices_to = "value_label") %>%
  pivot_wider(names_from = id, values_from = value_label) %>%
  arrange(value)


vallabs_reg16 <- metadata %>%
  filter(grepl("16", id), grepl("reg", var_name_orig)) %>%
  filter(!is.na(labels)) %>%
  select(labels, id) %>%
  unnest_longer(labels, 
                values_to = "value",
                indices_to = "value_label") %>%
  arrange(value) %>%
  pivot_wider(names_from = id, 
              values_from = "value_label") %>%
  distinct()



# create province object
vallab_tab_prov <- metadata %>%
  filter( grepl("prov", var_name_orig) | grepl("prv", var_name_orig) ) %>%
  filter(!is.na(labels)) %>%
  select(id, labels) %>%
  unnest_longer(labels, 
                values_to = "value",
                indices_to = "value_label") %>%
  pivot_wider(names_from = id, values_from = value_label) %>%
  arrange(value)


