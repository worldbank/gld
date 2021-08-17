best_matches <- function(df, 
                         country_code = "class",
                         international_code = "isic4"
                         ) {
  
  # 1. Load and Reduce df
  # determine colnames + symbols
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
  
  
  
  # Step 2 - Match at 4 digits ----------
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

  
 
 # Step 3 - Match at 3 digits ------------------------------------

 # Reduce df to cases not yet matched
 # df[!(df$SCIAN %in% match_1$SCIAN),]
 df_2 <- df %>%
   filter(!({{cc}} %in% match_1[[country_code]]))
# df_2 <- df[!(df[[country_code]] %in% match_1[[country_code]] )]

 # Reduce ISIC codes to three digits
 df_2[[international_code]] <- substr(df_2[[international_code]],1,3)

 # Match if perfect
 match_2 <- df_2 %>% 
   count({{cc}}, {{ic}}) %>% 
   rename(instance = n) %>%
   group_by({{cc}}) %>%
   mutate(sum = sum(instance)) %>%
   ungroup() %>%
   mutate(pct = round((instance/sum)*100,1)) %>%
   filter(pct == 100)
 
 # Review
 done_2 <- n_distinct(match_2[[country_code]])
 rest_2 <- n_distinct(df[[country_code]]) - n_distinct(match_1[[country_code]]) - n_distinct(match_2[[country_code]])
 
}

best_matches(isic09_clean)


