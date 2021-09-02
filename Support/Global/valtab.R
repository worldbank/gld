#' extracts value labels from metadata and tabulates across survey waves
#' @param x a character vector of length 1 to match in the parameter column
#' @param y an optional second character vector of length 1 to match in the parameter column
#' @param param the unquoted name of the variable to perform the matching in the metadata file

valtab <- function(metadata, x, y, param = var_name_orig) {
                      y = NULL
  if (is.null(y)) {
    table <- metadata %>%
      filter( grepl(as.character({{ x }}), {{ param }}) )
  } else {
    table <- metadata %>%
      filter( grepl(as.character({{ x }}), {{ param }}) | grepl(as.character({{ y }}), {{ param }}) )
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
    pivot_wider(names_from = id, 
                values_from = value_label,
                values_fn = list) %>%
    arrange(value) 
  
  
  # determine unique values across each row 
  table %<>% 
    unnest(cols = starts_with("LFS")) %>% 
    rowwise() %>%
    mutate(
      unique_labs = list(unique(c_across(starts_with("LFS"))))
    ) %>%
    select(value, n_labs, same, unique_labs, everything())
  
  return(table)
}
