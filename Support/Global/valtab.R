valtab <- function(x, y, param = "var_name_orig") {
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