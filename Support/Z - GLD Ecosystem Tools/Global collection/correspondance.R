#' Determines most likely matches between two vectors of numer international_code  classif international_code ation codes.
#' @param df The tibble or data.frame object containing the two columns of data to match
#' @param country_code The name of the column that contains the country-specif international_code  code
#' @param international_code The name of the column that contains the international code
#' @param pad_vars A quoted character vector of variables to pad, otherwise NULL
#' @return a 3-element list object that contains the final match tibble, a results tibble, and a ggplot.

corresp <- function(df, 
                   country_code,
                   international_code,
                   pad_vars = NULL,
                   check_matches = FALSE
                   ) {
  
  vars_quo <- rlang::quos(pad_vars)
  
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
    group_by({{ country_code }}) %>%
    mutate(sum = sum(instance)) %>%
    ungroup() %>%
    mutate(
      "{{international_code}}_orig"  := {{ international_code }},
      "{{country_code}}_orig"  := {{ country_code }},
      corresp_pct = round((instance/sum)*100,1),
      dist = stringdist::stringsim({{ country_code }}, {{ international_code }}),
      str_dist = round((dist)*100,1),
      match_stage = 4) %>%
    filter(corresp_pct == 100)

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
   mutate(
     "{{international_code}}" := stringr::str_sub({{international_code}}, 1,3)) %>%
   count({{ country_code }}, {{ international_code }}) %>%
   rename(instance = n) %>%
   group_by({{ country_code }}) %>%
   mutate(sum = sum(instance)) %>%
   ungroup() %>%
   mutate(
     corresp_pct = round((instance/sum)*100,1),
     match_stage = 3) %>%
   filter(corresp_pct == 100)

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


 # Match by maximum, a country_code count for cases where df_3 may be null
  if (dim(df_3)[1] > 0) {
    set.seed(61035)
    match_3 <- df_3 %>%
      mutate(
        "{{international_code}}" := stringr::str_sub({{international_code}}, 1,2)) %>%
      count({{ country_code }}, {{ international_code }}) %>%
      rename(instance = n) %>%
      group_by({{ country_code }}) %>%
      mutate(sum = sum(instance)) %>%
      ungroup() %>%
      mutate(
        corresp_pct = round((instance/sum)*100,1),
        match_stage = 2) %>%
    group_by({{ country_code }}) %>%
      slice_max(corresp_pct) %>%
      sample_n(1)
  } else {
    set.seed(61035)
    match_3 <- df_3 %>%
      mutate("{{international_code}}" := stringr::str_sub({{international_code}}, 1,2)) %>%
      count({{ country_code }}, {{ international_code }}) %>%
      rename(instance = n) %>%
      group_by({{ country_code }}) %>%
      mutate(sum = sum(instance)) %>%
      ungroup() %>%
      mutate(
        corresp_pct = round((instance/sum)*100,1),
        match_stage = 2) 
  }


  # Review
  done_3 <- select(match_3, {{country_code}}) %>% n_distinct()

  rest_3 <- df_dst - done_1 - done_2 - done_3

  n_dist <- df %>% select({{ country_code }}) %>% n_distinct()


# Step 5 - append + ggplot ----------------------------------------------



concord <- bind_rows(match_1, match_2, match_3) %>%
  select( {{ country_code }}, {{ international_code }}, corresp_pct, match_stage, contains("orig")) %>%
  rename(match = corresp_pct)

  if (!is.null(pad_vars)) {
  
    concord <- concord %>%
      mutate(across(all_of(!!!vars_quo), ~ str_pad( .x, 4, pad = "0", side = "right")))
    
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

gg_match <- ggplot(concord, aes(match)) +
  geom_density() +
  scale_x_continuous(n.breaks = 10, limits = c(0,100)) +
  theme_minimal() +
  labs(x = "Match Score", y = "Relative Density", title = "Distribution of Match Scores")

gg_stage <- ggplot(concord, aes(match_stage)) +
  geom_freqpoly() + 
  theme_minimal() +
  labs(x = "Match Stage", y = "Number of Matches", title = "Distribution of Matches in Match Stages")

list <- list(concord, results, gg_match, gg_stage)



return(list)


}
      
