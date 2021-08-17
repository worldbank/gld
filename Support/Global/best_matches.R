best_matches <- function(df, 
                         country_code = "class",
                         international_code = "isic4"
                         ) {
  
  # 1. Load and Reduce df
  # determine colnames 
  vars <- c(country_code, international_code)
  
  # Drop columns we are not interest in, drop rows where int code is missing
  df <- df %>% 
    select(all_of(vars)) %>%
    filter(!is.na(international_code)) %>%
    filter(across(all_of(vars), ~ !grepl("[A-Za-z]", .x)))
                      
  
  # For rows where SCIAN is NA, this is because they have the last code listed previously, fill down
  df <- df %>% fill(all_of(country_code), .direction = "down")
  
  return(df)
  
}
