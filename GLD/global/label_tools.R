# label_tools.R
# find unique label vector
val_region <- collect_val_labels(metadata %>% 
                                   filter(label_orig == "region")
  
)

# find value/label tibble
vallabs_region <- metadata %>%
  filter(label_orig == "region") %>%
  filter(!is.na(labels)) %>%
  select(labels) %>%
  unnest_longer(labels, 
                values_to = "value",
                indices_to = "value_label") %>%
  distinct()


# make a table to labels across time 
vallab_table_region <- metadata ## %>%
  