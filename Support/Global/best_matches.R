best_matches <- function(df, 
                         country_code = "class",
                         international_code = "isic4"
                         ) {
  
  # 1. Load and Reduce df
  # determine colnames 
  cc <- as.symbol(country_code )
  ic <- as.symbol(international_code)
  vars <- c(as.character(country_code), as.character(international_code))
  
  # Drop columns we are not interest in, drop rows where int code is missing
  df <- df %>% 
    select(all_of(vars)) %>%
    filter(!is.na(international_code)) %>%
    filter(across(all_of(vars), ~ !grepl("[A-Za-z]", .x)))
                      
  
  # For rows where SCIAN is NA, this is because they have the last code listed previously, fill down
  df <- df %>% fill(all_of(country_code), .direction = "down")
  
  
  
  # Step 2 - Concordence Country_code to International Code ----------
  # Match if concordance is 100%
  match_1 <- df %>%
    count({{cc}}, {{ic}}) %>%
    rename(instance = n) %>%
    group_by({{cc}}) %>%
    mutate(sum = sum(instance)) %>%
    ungroup() %>%
    mutate(pct = round((instance/sum)*100,1)) %>%
    filter(pct == 100)

  # Review
 done_1 <- n_distinct(match_1[[country_code]])
 rest_1 <- n_distinct(df[[country_code]]) - n_distinct(match_1[[country_code]])

  return(rest_1)
}


