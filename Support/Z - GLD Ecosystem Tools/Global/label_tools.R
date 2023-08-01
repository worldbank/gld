# label_tools.R
# a working exploratory script to see what we can do with the metadata file
# using "region" as a working example.

library(tidyverse)
library(retroharmonize)
library(summarytools)

# load metadata
load("Y:/GLD-Harmonization/551206_TM/PHL/PHL_data/I2D2/Rdata/metadata.Rdata")
source(file.path(code, "Global/valtab.R"))

# functions ----

# pulling a single filter parameter from the label
valtab_label <- function(x, y) { 
                        y = NULL
  if (is.null(y)) {
    table <- metadata %>%
      filter( grepl(as.character(x), label_orig) )
  } else {
    table <- metadata %>%
      filter( grepl(as.character(x), label_orig) | grepl(as.character(y), label_orig) )
  }
  
  table <- table %>%
    filter(!is.na(labels)) %>%
    select(id, labels) %>%
    unnest_longer(labels, 
                  values_to = "value",
                  indices_to = "value_label") %>%
    group_by(value) %>% 
    mutate(n_labs = (n_distinct(value_label, na.rm = TRUE)),  # number of distinct labels per value (number)
           same = (n_labs == 1) # TRUE if all string values are the same (for labelled variables)
    ) %>%
    ungroup() %>%
    pivot_wider(names_from = id, values_from = value_label) %>%
    arrange(value)
  
  return(table)
}
    
 
  
#   metadata %>%
#     filter( grepl(as.character(x), label_orig) ) %>%
#     filter(!is.na(labels)) %>%
#     select(id, labels) %>%
#     unnest_longer(labels, 
#                   values_to = "value",
#                   indices_to = "value_label") %>%
#     group_by(value) %>% 
#     mutate(n_labs = (n_distinct(value_label, na.rm = TRUE)),  # number of distinct labels per value (number)
#            same = (n_labs == 1) # TRUE if all string values are the same (for labelled variables)
#     ) %>%
#     ungroup() %>%
#     pivot_wider(names_from = id, values_from = value_label) %>%
#     arrange(value)
# }

# pulling a single filter parameter from the name
valtab_name <- function(x, y) {
                        y = NULL
  if (is.null(y)) {
    table <- metadata %>%
      filter( grepl(as.character(x), var_name_orig) )
  } else {
    table <- metadata %>%
      filter( grepl(as.character(x), var_name_orig) | grepl(as.character(y), label_orig) )
  }
  
  table <- table %>%
    filter(!is.na(labels)) %>%
    select(id, labels) %>%
    unnest_longer(labels, 
                  values_to = "value",
                  indices_to = "value_label") %>%
    group_by(value) %>% 
    mutate(n_labs = (n_distinct(value_label, na.rm = TRUE)),  # number of distinct labels per value (number)
           same = (n_labs == 1) # TRUE if all string values are the same (for labelled variables)
    ) %>%
    ungroup() %>%
    pivot_wider(names_from = id, values_from = value_label) %>%
    arrange(value)
  
  return(table)
}




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




# create industry object
vallab_tab_industry <- metadata %>%
  filter( grepl("qkb", var_name_orig) | grepl("pkb", var_name_orig) ) %>%
  filter(!is.na(labels)) %>%
  select(id, labels) %>%
  unnest_longer(labels, 
                values_to = "value",
                indices_to = "value_label") %>%
  pivot_wider(names_from = id, values_from = value_label) %>%
  arrange(value)


vallabs_industry12 <- metadata %>%
  filter(grepl("12", id), grepl("qkb", var_name_orig) | grepl("pkb", var_name_orig) ) %>%
  select(labels, id) %>%
  filter(!is.na(labels)) %>%
  unnest_longer(labels, 
                values_to = "value",
                indices_to = "value_label") %>%
  arrange(value) %>%
  pivot_wider(names_from = id, 
              values_from = "value_label") %>%
  distinct() 


vallabs_industry18 <- metadata %>%
  filter(grepl("18", id), grepl("qkb", var_name_orig) | grepl("pkb", var_name_orig) ) %>%
  select(labels, id) %>%
  filter(!is.na(labels)) %>%
  unnest_longer(labels, 
                values_to = "value",
                indices_to = "value_label") %>%
  arrange(value) %>%
  pivot_wider(names_from = id, 
              values_from = "value_label") %>%
  distinct() 



# create family relationship variable tables 
vallab_tab_rel <- metadata %>%
  filter( grepl("rel", var_name_orig) ) %>%
  filter(!is.na(labels)) %>%
  select(id, labels) %>%
  unnest_longer(labels, 
                values_to = "value",
                indices_to = "value_label") %>%
  pivot_wider(names_from = id, values_from = value_label) %>%
  arrange(value)


# create household id variable tables 
vallab_tab_hhid <- metadata %>%
  filter( grepl("rel", var_name_orig) ) %>%
  filter(!is.na(labels)) %>%
  select(id, labels) %>%
  unnest_longer(labels, 
                values_to = "value",
                indices_to = "value_label") %>%
  pivot_wider(names_from = id, values_from = value_label) %>%
  arrange(value)


# create household id variable tables 
vallab_tab_curschool <- metadata %>%
  filter( grepl("currently attending", label_orig) ) %>%
  filter(!is.na(labels)) %>%
  select(id, labels) %>%
  unnest_longer(labels, 
                values_to = "value",
                indices_to = "value_label") %>%
  pivot_wider(names_from = id, values_from = value_label) %>%
  arrange(value)

# create employment status variable 
vallab_tab_employstat <- metadata %>%
  filter( grepl("empst", var_name_orig) ) %>%
  filter(!is.na(labels)) %>%
  select(id, labels) %>%
  unnest_longer(labels, 
                values_to = "value",
                indices_to = "value_label") %>%
  pivot_wider(names_from = id, values_from = value_label) %>%
  arrange(value)


# create marital status variable tables 
vallab_tab_marital <- metadata %>%
  filter( grepl("marital", label_orig) ) %>%
  filter(!is.na(labels)) %>%
  select(id, labels) %>%
  unnest_longer(labels, 
                values_to = "value",
                indices_to = "value_label") %>%
  group_by(value) %>% 
  mutate(n_labs = (n_distinct(value_label, na.rm = TRUE)),  # number of distinct labels per value (number)
         same = (n_labs == 1) # TRUE if all string values are the same (for labelled variables)
  ) %>%
  ungroup() %>%
  pivot_wider(names_from = id, values_from = value_label) %>%
  arrange(value)

save.image(file = file.path(PHL, "PHL_data/variable_label_tables.Rdata"))

class <- valtab_name("clas")
industry <- valtab_name("qkb", "pkb")

edu <- valtab(metadata = metadata, x = "grade", param = label_orig)




# summaries  ----

industry %>% 
  pivot_longer(cols = contains("LFS"), values_to = "label") %>%
  group_by("name") %>%
  dfSummary(varnumbers = F,
            labels.col = F, 
            valid.col = F, 
            na.col = F,
            graph.col = T,
            graph.magnif = 0.75,
            style = "grid")


# export ----
save.image(file = file.path(PHL, "PHL_data/variable_label_tables.Rdata"))


