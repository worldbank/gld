#' Determines most likely matches between two vectors of numer international_code  classif international_code ation codes.
#' @param df The tibble or data.frame object containing the two columns of data to match
#' @param country_code The name of the column that contains the country-specif international_code  code
#' @param international_code The name of the column that contains the international code
#' @return a 3-element list object that contains the final match tibble, a results tibble, and a ggplot.

best_match <- function(df, 
                       country_code,
                       international_code
                       ) {
  
  # make string versions for easy subsetting later
  cc <- as.character(country_code)
  ic <- as.character(international_code)
  
  # Drop columns we are not interest in, drop rows where int code is missing
  # df <- df %>% 
  #   select(c({{country_code}}, {{international_code}})) %>%
  #   filter(!is.na({{international_code}})) %>%
  #   filter(across(.cols = everything(), ~ !grepl("[A-Za-z]", .x)))
                      
  
  # For rows where SCIAN is NA, this is because they have the last code listed previously, fill down
  df <- df %>% tidyr::fill(minor, .direction = "down")



  # Step 2 - Match at 4 digits ----------
  # Match if concordance is 100%
  match_1 <- df %>%
    count({{ country_code }}, {{ international_code }}) %>%
    rename(instance = n) %>%
    group_by({{ country_code }}) %>%
    mutate(sum = sum(instance)) %>%
    ungroup() %>%
    mutate(pct = round((instance/sum)*100,1)) %>%
    filter(pct == 100)

  # Review
 done_1 <- n_distinct(match_1[[cc]])
 rest_1 <- n_distinct(df[[cc]]) - n_distinct(match_1[[cc]])



 # Step 3 - Match at 3 digits ------------------------------------

 # Reduce df to cases not yet matched
 df_2 <- df %>%
   filter(!({{ country_code }} %in% match_1[[cc]]))

 # Reduce IS international_code  codes to three digits
 df_2[[international_code]] <- substr(df_2[[international_code]],1,3)

 # Match if perfect
 match_2 <- df_2 %>%
   count({{ country_code }}, {{ international_code }}) %>%
   rename(instance = n) %>%
   group_by({{ country_code }}) %>%
   mutate(sum = sum(instance)) %>%
   ungroup() %>%
   mutate(pct = round((instance/sum)*100,1)) %>%
   filter(pct == 100)

 # Review
 done_2 <- n_distinct(match_2[[cc]])
 rest_2 <- n_distinct(df[[cc]]) -
   n_distinct(match_1[[cc]]) -
   n_distinct(match_2[[cc]])



# Step 4 - match at 2 digits ------------------------------------

# Reduce df to cases not yet matched
df_3 <- df_2 %>%
  filter(!({{ country_code }} %in% match_2[[country_code]]))


  # Reduce IS international_code  code to two digits
  df_3[[international_code]] <- substr(df_3[[international_code]],1,2)

  # Match by maximum, a country_code ount for cases where df_3 may be null
  if (dim(df_3)[1] > 0) {
    set.seed(61035)
    match_3 <- df_3 %>%
      count({{ country_code }}, {{ international_code }}) %>%
      rename(instance = n) %>%
      group_by({{ country_code }}) %>%
      mutate(sum = sum(instance)) %>%
      ungroup() %>%
      mutate(pct = round((instance/sum)*100,1))
    group_by({{ country_code }}) %>%
      slice_max(pct) %>%
      sample_n(1)
  } else {
    set.seed(61035)
    match_3 <- df_3 %>%
      count({{ country_code }}, {{ international_code }}) %>%
      rename(instance = n) %>%
      group_by({{ country_code }}) %>%
      mutate(sum = sum(instance)) %>%
      ungroup() %>%
      mutate(pct = round((instance/sum)*100,1))
  }


  # Review
  done_3 <- n_distinct(match_3[[cc]])
  rest_3 <- n_distinct(df[[cc]]) -
    n_distinct(match_1[[cc]]) -
    n_distinct(match_2[[cc]]) -
    n_distinct(match_3[[cc]])




# Step 5 - append + ggplot ----------------------------------------------


concord <- bind_rows(match_1, match_2, match_3) %>%
  select( {{ country_code }}, {{ international_code }}, pct) %>%
  rename(match = pct) %>%
   mutate( "{{ country_code }}" := str_pad({{ country_code }}, 4, pad = "0", side = "right"),
           "{{ international_code }}" := str_pad({{ international_code }}, 4, pad = "0", side = "right"))

results <- tibble(
  match_no = c(1,2,3),
  obs_matched = c(done_1, done_2, done_3),
  obs_remaining = c(rest_1, rest_2, rest_3)
)

gg <- ggplot(concord, aes(match)) +
  geom_freqpoly() +
  scale_x_continuous(n.breaks = 10, limits = c(0,100)) +
  theme_minimal() +
  labs(x = "Match Score", y = "Density", title = "Distribution of Match Scores")

list <- list(concord, results, gg) # match_1, match_2, match_3, df_2, df_3
return(list)




}
      
