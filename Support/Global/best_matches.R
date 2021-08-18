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
 df_2 <- df %>%
   filter(!({{cc}} %in% match_1[[country_code]]))

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
 rest_2 <- n_distinct(df[[country_code]]) - 
   n_distinct(match_1[[country_code]]) - 
   n_distinct(match_2[[country_code]])
 


# Step 4 - match at 2 digits ------------------------------------

# Reduce df to cases not yet matched
df_3 <- df_2 %>%
  filter(!({{cc}} %in% match_2[[country_code]]))

# Reduce ISIC code to two digits
df_3[[international_code]] <- substr(df_3[[international_code]],1,2)

# Match by maximum
set.seed(61035)
match_3 <- df_3 %>% 
  count({{cc}}, {{ic}}) %>% 
  rename(instance = n) %>%
  group_by({{cc}}) %>%
  mutate(sum = sum(instance)) %>%
  ungroup() %>%
  mutate(pct = round((instance/sum)*100,1)) %>%
  group_by({{cc}}) %>%
  slice_max(pct) %>%
  sample_n(1)

# Review
done_3 <- n_distinct(match_3[[country_code]])
rest_3 <- n_distinct(df[[country_code]]) - 
  n_distinct(match_1[[country_code]]) - 
  n_distinct(match_2[[country_code]]) - 
  n_distinct(match_3[[country_code]])


# Step 5 - append + ggplot ----------------------------------------------

concord <- bind_rows(match_1, match_2, match_3) %>%
  select( {{cc}}, {{ic}}, pct) %>%
  rename(match = pct) 
   mutate( cc = str_pad({{cc}}, 4, pad = "0", side = "right"),
           ic = str_pad({{ic}}, 4, pad = "0", side = "right"))

results <- tibble(
  match_no = c(1,2,3),
  obs_matched = c(done_1, done_2, done_3),
  obs_remaining = c(rest_1, rest_2, rest_3)
)

gg <- ggplot(concord, aes(match)) +
  geom_density() +
  scale_x_continuous(n.breaks = 10) +
  theme_minimal() +
  labs(x = "Match Score", y = "Density", title = "Distribution of Match Scores")

list <- list(concord, results, gg)
return(list)




}
                         

best_matches(isic09_clean)[[3]] 



