#' Determines most likely matches between two vectors of numer international_code  classif international_code ation codes.
#' @param df The tibble or data.frame object containing the two columns of data to match
#' @param country_code The name of the column that contains the country-specif international_code  code
#' @param international_code The name of the column that contains the international code
#' @param str_pad A boolean value to indicate if the resulting vectors should be padded to the right
#' @return a 3-element list object that contains the final match tibble, a results tibble, and a ggplot.

best_match <- function(df, 
                       country_code,
                       international_code,
                       str_pad = FALSE,
                       check_matches = FALSE
                       ) {
  
  # make string versions for easy subsetting later
  # cc <- as.character(country_code)
  # ic <- as.character(international_code)
  # vars <- c(cc, ic)
  
  # Drop columns we are not interest in, drop rows where int code is missing
  df <- df %>%
    select(c({{country_code}}, {{international_code}})) %>%
    filter(!is.na({{international_code}})) %>%
    filter(across(.cols = everything(), ~ !grepl("[A-Za-z]", .x)))
                      
  
  # For rows where SCIAN is NA, this is because they have the last code listed previously, fill down
  df <- df %>%
    tidyr::fill({{country_code}}, .direction = "down")



# Step 2 - Match at 4 digits ----------
  # Match if concordance is 100%
  match_1 <- df %>%
    count({{ country_code }}, {{ international_code }}) %>%
    rename(instance = n) %>%
    mutate(
      dist = stringdist::stringsim({{ country_code }}, {{ international_code }}),
      pct = round((dist)*100,1)) %>%
    filter(pct == 100)

  # Review
 done_1 <- match_1 %>% select({{country_code}}) %>% n_distinct() 
 
 df_dst <- df %>% select({{country_code}}) %>% n_distinct() # original no of distinct
 rest_1 <- df_dst - done_1



 # Step 3 - Match at 3 digits ------------------------------------
  list <- match_1 %>% 
   select({{country_code}}) %>% 
   pull()

 # Reduce df to cases not yet matched, reduce international code to 3 digits
   df_2 <- df %>%
     filter((!{{ country_code }} %in% list)) 


 # Match first 3 digits of country code correspond to first three of international code.
 # here, determine the distance on original 4 digit and filter based on 3 digit. This way 
 # we have a record of match to original isco code
 match_2 <- df_2 %>%
   count({{ country_code }}, {{ international_code }}) %>%
   rename(instance = n) %>%
   mutate(
    "{{international_code}}" := stringr::str_sub({{international_code}}, 1,3), #overwrite?
     cc3 = stringr::str_sub({{ country_code }}, 1, 3),
     dist_cc3 = stringdist::stringsim(cc3, {{ international_code }}),
     dist = stringdist::stringsim({{ country_code }}, {{ international_code }}),
     pct = round((dist)*100,1)
     ) %>%
   filter(dist_cc3 == 1) %>%
   select(-cc3, -dist_cc3)

 # Review
 done_2 <- select(match_2, {{country_code}}) %>% n_distinct()

 rest_2 <- df_dst - done_1 - done_2


  

# Step 4 - match at 2 digits ------------------------------------
  list2 <- match_2 %>% 
   select({{country_code}}) %>%
   pull()

# Reduce df to cases not yet matched, reduce international code to 2 digits
  df_3 <- df_2 %>%
    filter(!({{ country_code }} %in% list2)) 


 # Match by maximum, a country_code ount for cases where df_3 may be null
  if (dim(df_3)[1] > 0) {
    set.seed(61035)
    match_3 <- df_3 %>%
      count({{ country_code }}, {{ international_code }}) %>%
      rename(instance = n) %>%
      mutate(
        "{{international_code}}" := stringr::str_sub({{international_code}}, 1,2),
        cc2 = stringr::str_sub({{ country_code }}, 1, 2),
        dist_cc2 = stringdist::stringsim(cc2, {{ international_code }}),
        dist = stringdist::stringsim({{ country_code }}, {{ international_code }}),
        pct = round((dist)*100,1)) %>%
    group_by({{ country_code }}) %>%
      slice_max(pct) %>%
      sample_n(1)
  } else {
    set.seed(61035)
    match_3 <- df_3 %>%
      count({{ country_code }}, {{ international_code }}) %>%
      rename(instance = n) %>%
      mutate(
        "{{international_code}}" := stringr::str_sub({{international_code}}, 1,2),
        cc2 = stringr::str_sub({{ country_code }}, 1, 2),
        dist_cc2 = stringdist::stringsim(cc2, {{ international_code }}),
        dist = stringdist::stringsim({{ country_code }}, {{ international_code }}),
        pct = round((dist)*100,1))
  }


  # Review
  done_3 <- select(match_3, {{country_code}}) %>% n_distinct()

  rest_3 <- df_dst - done_1 - done_2 - done_3

  n_dist <- df %>% select({{ country_code }}) %>% n_distinct()
  

# Step 5 - append + ggplot ----------------------------------------------


concord <- bind_rows(match_1, match_2, match_3) %>%
  select( {{ country_code }}, {{ international_code }}, pct) %>%
  rename(match = pct)
  
  if (str_pad == TRUE) {
    concord <- concord %>%
      mutate( "{{ country_code }}" := str_pad({{ country_code }}, 
                                              4, pad = "0", side = "right"),
              "{{ international_code }}" := str_pad({{ international_code }}, 
                                                    4, pad = "0", side = "right"))
    
  }
  
  if (check_matches == TRUE) {
    
    # check that every unique value returned in country code is contained in input vector
    input.vector <- df %>% 
      select({{ country_code }}) %>%
      pull()
    
    concord_check <- concord %>%
      mutate(match_input = {{country_code}} %in% input.vector)
    
    assertthat::assert_that(sum(concord_check$match_input) == nrow(concord_check))
    
    # check that the number of unique values between innput and returned is the same
    n_out <- concord %>% select({{ country_code }}) %>% n_distinct()
    n_in  <- df %>% select({{ country_code }}) %>% n_distinct()
    
    assertthat::assert_that(n_in == n_out)
    
  }
  
results <- tibble(
  match_no = c(1,2,3),
  obs_matched = c(done_1, done_2, done_3),
  obs_remaining = c(rest_1, rest_2, rest_3),
  orig_n_distinct = c(n_dist, n_dist, n_dist)
)

gg <- ggplot(concord, aes(match)) +
  geom_density() +
  scale_x_continuous(n.breaks = 10, limits = c(0,100)) +
  theme_minimal() +
  labs(x = "Match Score", y = "Relative Density", title = "Distribution of Match Scores")

list <- list(concord, results, gg) 
   


return(list)


}
      
