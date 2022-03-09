
#================================#
# Code to create a concordance ==#
# table between SINCO MEX      ==#
# and CMO                      ==#
#================================#


#=========================================================================#
# Step 0 - User specific information --------------------------------------
#=========================================================================#

rm(list=ls())
path_in <- "C:/Users/wb582018/OneDrive - WBG/Documents/ISCO classification"
path_out <- NA # Leave NA if same as path in
nso_excel_file <- "tablas_comparativas.xlsx"

isco_version <- "ISCO_08"
cmo_version <- "CMO_09"

## From here on the code should run on its own, no further input needed.

#=========================================================================#
# Step 1 - Call libraries, read in data, reduce to relevant ---------------
#=========================================================================#

packages = c("haven", "readxl", "dplyr", "tidyr", "stringr")

for (package in packages){
  if (!require(package, character.only = TRUE)){ # If package not known, install and load
    install.packages(package, dependencies = TRUE)
    library(package, character.only = TRUE)
  }
}

if (is.na(path_out)){
  path_out <- paste0(path_in, "/", cmo_version, "_", isco_version, ".dta")  
} else {
  path_out <- paste0(path_out, "/", cmo_version, "_", isco_version, ".dta")
}
path_in <- paste0(path_in, "/", nso_excel_file)


df <- read_excel(path = path_in, sheet = 2, skip = 10, col_names = FALSE)

# Drop when entire row is NA
df <- df[!(rowSums(is.na(df)) == 4),]

# Drop when SINCO is not four digit
df <- df[!(df$...1 < 1000 & !is.na(df$...1)),]

# Drop columns we are not interest in, 
df <- df[,c(1,3)]
names(df) <- c("SINCO", "CMO")

# For rows where SINCO, CMO is NA, this is because they have the last code listed previously, fill down
df <- df %>% fill(SINCO, .direction = "down") %>% fill(CMO, .direction = "down") 

# Inver order, we are mapping from CMO to SINCO, convert to character
df <- df[,c(2,1)] %>% 
  mutate_all(as.character)

# There are 448 distinct 4 digit codes
n_distinct(df$CMO)

#=========================================================================#
# Step 2 - Concordance CMO4 to SINCO4 ------------------------------------
#=========================================================================#

# Match if concordance is 100%
match_1 <- df %>% 
  count(CMO, SINCO) %>% 
  rename(instance = n) %>%
  group_by(CMO) %>%
  mutate(sum = sum(instance)) %>%
  ungroup() %>%
  mutate(pct = round((instance/sum)*100,1)) %>%
  filter(pct == 100)

# Review
done <- n_distinct(match_1$CMO)
rest <- n_distinct(df$CMO) - n_distinct(match_1$CMO)
message(paste0("Step 2 has matched ", done, " codes, hence ", rest, " are left to match"))

#=========================================================================#
# Step 3 - Concordance CMO4 to SINCO3 ------------------------------------
#=========================================================================#

# Reduce df to cases not yet matched
df_2 <- df[!(df$CMO %in% match_1$CMO),]
n_distinct(df_2$CMO)

# Reduce SINCO codes to three digits
df_2$SINCO <- substr(df_2$SINCO,1,3)

# Match if perfect
match_2 <- df_2 %>% 
  count(CMO, SINCO) %>% 
  rename(instance = n) %>%
  group_by(CMO) %>%
  mutate(sum = sum(instance)) %>%
  ungroup() %>%
  mutate(pct = round((instance/sum)*100,1)) %>%
  filter(pct == 100)

# Review
done <- n_distinct(match_2$CMO)
rest <- n_distinct(df$CMO) - n_distinct(match_1$CMO) - n_distinct(match_2$CMO)
message(paste0("Step 3 has matched ", done, " codes, hence ", rest, " are left to match"))

#=========================================================================#
# Step 4 - Concordance CMO4 to SINCO2 ------------------------------------
#=========================================================================#

# Reduce df to cases not yet matched
df_3 <- df_2[!(df_2$CMO %in% match_2$CMO),]
n_distinct(df_3$CMO)

# Reduce SINCO code to two digits
df_3$SINCO <- substr(df_3$SINCO,1,2)

# Match by maximum
set.seed(61035)
match_3 <- df_3 %>% 
  count(CMO, SINCO) %>% 
  rename(instance = n) %>%
  group_by(CMO) %>%
  mutate(sum = sum(instance)) %>%
  ungroup() %>%
  mutate(pct = round((instance/sum)*100,1)) %>%
  filter(pct > 50)

# Review
done <- n_distinct(match_3$CMO)
rest <- n_distinct(df$CMO) - n_distinct(match_1$CMO) - n_distinct(match_2$CMO) - n_distinct(match_3$CMO)
message(paste0("Step 4 has matched ", done, " codes, hence ", rest, " are left to match"))

#=========================================================================#
# Step 5 - Concordance CMO4 to SINCO1 ------------------------------------
#=========================================================================#

# Reduce df to cases not yet matched
df_4 <- df_3[!(df_3$CMO %in% match_3$CMO),]
n_distinct(df_4$CMO)

# Reduce SINCO code to two digits
df_4$SINCO <- substr(df_4$SINCO,1,1)

# Match by maximum
set.seed(61035)
match_4 <- df_4 %>% 
  count(CMO, SINCO) %>% 
  rename(instance = n) %>%
  group_by(CMO) %>%
  mutate(sum = sum(instance)) %>%
  ungroup() %>%
  mutate(pct = round((instance/sum)*100,1)) %>%
  group_by(CMO) %>%
  slice_max(pct) %>%
  sample_n(1) %>%
  ungroup() 

# Review
done <- n_distinct(match_4$CMO)
rest <- n_distinct(df$CMO) - n_distinct(match_1$CMO) - n_distinct(match_2$CMO) - n_distinct(match_3$CMO) - n_distinct(match_4$CMO)
message(paste0("Step 5 has matched ", done, " codes, hence ", rest, " are left to match"))

#=========================================================================#
# Step 6 - Unite CMO to SINCO all matches ---------------------------------
#=========================================================================#

concord <- bind_rows(match_1, match_2, match_3, match_4) %>%
  select(cmo = CMO, sinco = SINCO, match_cs = pct)

#=========================================================================#
# Step 7 - Create matching functions so rest is more readable -------------
#=========================================================================#

# The logic applied in steps 2 to 5 is used for SINCO to ISIC at four digits, 
# then steps 3 to 5 at three digits and so forth. Wrapped in a function here
# for readibility.

create_match_4 <- function(df){
  
  # Step A.1 - Concordance SINCO4 to ISCO4 ------------------------------------
  
  # Match if concordance is 100%
  match_1 <- df %>% 
    count(SINCO, ISCO) %>% 
    rename(instance = n) %>%
    group_by(SINCO) %>%
    mutate(sum = sum(instance)) %>%
    ungroup() %>%
    mutate(pct = round((instance/sum)*100,1)) %>%
    filter(pct == 100)
  
  # Step A.2 - Concordance SINCO4 to ISCO3 ------------------------------------
  
  # Reduce df to cases not yet matched
  df_2 <- df[!(df$SINCO %in% match_1$SINCO),]
  
  # Reduce ISIC codes to three digits
  df_2$ISCO <- substr(df_2$ISCO,1,3)
  
  # Match if perfect
  match_2 <- df_2 %>% 
    count(SINCO, ISCO) %>% 
    rename(instance = n) %>%
    group_by(SINCO) %>%
    mutate(sum = sum(instance)) %>%
    ungroup() %>%
    mutate(pct = round((instance/sum)*100,1)) %>%
    filter(pct == 100)
  
  # Step A.3 - Concordance SINCO4 to ISCO2 ------------------------------------
  
  # Reduce df to cases not yet matched
  df_3 <- df_2[!(df_2$SINCO %in% match_2$SINCO),]
  
  # Reduce ISIC code to two digits
  df_3$ISCO <- substr(df_3$ISCO,1,2)
  
  # Match by maximum
  match_3 <- df_3 %>% 
    count(SINCO, ISCO) %>% 
    rename(instance = n) %>%
    group_by(SINCO) %>%
    mutate(sum = sum(instance)) %>%
    ungroup() %>%
    mutate(pct = round((instance/sum)*100,1)) %>%
    filter(pct > 50)
  
  # Step A.4 - Concordance SINCO4 to ISCO1 ------------------------------------
  
  # Reduce df to cases not yet matched
  df_4 <- df_3[!(df_3$SINCO %in% match_3$SINCO),]
  
  # Reduce ISIC code to two digits
  df_4$ISCO <- substr(df_4$ISCO,1,1)
  
  # Match by maximum
  set.seed(61035)
  match_4 <- df_4 %>% 
    count(SINCO, ISCO) %>% 
    rename(instance = n) %>%
    group_by(SINCO) %>%
    mutate(sum = sum(instance)) %>%
    ungroup() %>%
    mutate(pct = round((instance/sum)*100,1)) %>%
    group_by(SINCO) %>%
    slice_max(pct) %>%
    sample_n(1)
  
  # Step A.5 - Unite, return --------------------------------------------------
  
  concord <- bind_rows(match_1, match_2, match_3, match_4) %>%
    select(sinco = SINCO, isco = ISCO, match = pct) %>%
    mutate(sinco = str_pad(sinco, 4, pad = "0", side = "right"),
           isco  = str_pad(isco, 4, pad = "0", side = "right"))
  
  return(concord)
  
}

create_match_3 <- function(df){
  
  # Step B.1 - Concordance SINCO3 to ISCO3 ------------------------------------
  
  # Reduce ISIC codes to three digits
  df$ISCO <- substr(df$ISCO,1,3)
  
  # Match if perfect
  match_1 <- df %>% 
    count(SINCO, ISCO) %>% 
    rename(instance = n) %>%
    group_by(SINCO) %>%
    mutate(sum = sum(instance)) %>%
    ungroup() %>%
    mutate(pct = round((instance/sum)*100,1)) %>%
    filter(pct == 100)
  
  # Step B.2 - Concordance SINCO4 to ISCO2 ------------------------------------
  
  # Reduce df to cases not yet matched
  df_2 <- df[!(df$SINCO %in% match_1$SINCO),]
  
  # Reduce ISIC code to two digits
  df_2$ISCO <- substr(df_2$ISCO,1,2)
  
  # Match by maximum
  match_2 <- df_2 %>% 
    count(SINCO, ISCO) %>% 
    rename(instance = n) %>%
    group_by(SINCO) %>%
    mutate(sum = sum(instance)) %>%
    ungroup() %>%
    mutate(pct = round((instance/sum)*100,1)) %>%
    filter(pct > 50)
  
  # Step B.3 - Concordance SINCO4 to ISCO1 ------------------------------------
  
  # Reduce df to cases not yet matched
  df_3 <- df_2[!(df_2$SINCO %in% match_2$SINCO),]
  
  # Reduce ISIC code to two digits
  df_3$ISCO <- substr(df_3$ISCO,1,1)
  
  # Match by maximum
  set.seed(61035)
  match_3 <- df_3 %>% 
    count(SINCO, ISCO) %>% 
    rename(instance = n) %>%
    group_by(SINCO) %>%
    mutate(sum = sum(instance)) %>%
    ungroup() %>%
    mutate(pct = round((instance/sum)*100,1)) %>%
    group_by(SINCO) %>%
    slice_max(pct) %>%
    sample_n(1)
  
  # Step B.4 - Unite, return --------------------------------------------------
  
  concord <- bind_rows(match_1, match_2, match_3) %>%
    select(sinco = SINCO, isco = ISCO, match = pct) %>%
    mutate(sinco = str_pad(sinco, 4, pad = "0", side = "right"),
           isco  = str_pad(isco, 4, pad = "0", side = "right"))
  
  return(concord)
  
}

create_match_2 <- function(df){
  
  # Step C.1 - Concordance SINCO2 to ISCO2 ------------------------------------
  
  # Reduce ISIC code to two digits
  df$ISCO <- substr(df$ISCO,1,2)
  
  # Match by maximum
  match_1 <- df %>% 
    count(SINCO, ISCO) %>% 
    rename(instance = n) %>%
    group_by(SINCO) %>%
    mutate(sum = sum(instance)) %>%
    ungroup() %>%
    mutate(pct = round((instance/sum)*100,1)) %>%
    filter(pct > 50)
  
  # Step C.2 - Concordance SINCO4 to ISCO1 ------------------------------------
  
  # Reduce df to cases not yet matched
  df_2 <- df[!(df$SINCO %in% match_1$SINCO),]
  
  # Reduce ISIC code to two digits
  df_2$ISCO <- substr(df_2$ISCO,1,1)
  
  # Match by maximum
  set.seed(61035)
  match_2 <- df_2 %>% 
    count(SINCO, ISCO) %>% 
    rename(instance = n) %>%
    group_by(SINCO) %>%
    mutate(sum = sum(instance)) %>%
    ungroup() %>%
    mutate(pct = round((instance/sum)*100,1)) %>%
    group_by(SINCO) %>%
    slice_max(pct) %>%
    sample_n(1)
  
  # Step C.3 - Unite, return --------------------------------------------------
  
  concord <- bind_rows(match_1, match_2) %>%
    select(sinco = SINCO, isco = ISCO, match = pct) %>%
    mutate(sinco = str_pad(sinco, 4, pad = "0", side = "right"),
           isco  = str_pad(isco, 4, pad = "0", side = "right"))
  
  return(concord)
  
}

create_match_1 <- function(df){
  
  # Step D.1 - Concordance SINCO1 to ISCO1 ------------------------------------
  
  # Reduce ISIC code to two digits
  df$ISCO <- substr(df$ISCO,1,1)
  
  # Match by maximum
  set.seed(61035)
  match_1 <- df %>% 
    count(SINCO, ISCO) %>% 
    rename(instance = n) %>%
    group_by(SINCO) %>%
    mutate(sum = sum(instance)) %>%
    ungroup() %>%
    mutate(pct = round((instance/sum)*100,1)) %>%
    group_by(SINCO) %>%
    slice_max(pct) %>%
    sample_n(1)
  
  # Step D.2 - Unite, return --------------------------------------------------
  
  concord <- match_1 %>%
    select(sinco = SINCO, isco = ISCO, match = pct) %>%
    mutate(sinco = str_pad(sinco, 4, pad = "0", side = "right"),
           isco  = str_pad(isco, 4, pad = "0", side = "right"))
  
  return(concord)
  
}

#=========================================================================#
# Step 8 - Read in SINCO to ISIC correspondance, clean --------------------
#=========================================================================#

s2i <- read_excel(path = path_in, sheet = 1, skip = 11, col_names = FALSE)

# Drop when entire row is NA
s2i <- s2i[!(rowSums(is.na(s2i)) == 4),]

# Drop when SINCO is not four digit
s2i <- s2i[!(s2i$...1 < 1000 & !is.na(s2i$...1)),]

# Fill ISCO description down, Drop when SINCO has no correspondence with ISCO
s2i <- s2i %>% fill(...4, .direction = "down") 
s2i <- s2i[!(s2i$...4 %in% c("No tiene correspondencia", 
                          "Nota: clasifica a los supervisores junto a los trabajadores que supervisa")),]

# Drop columns we are not interest in, 
s2i <- s2i[,c(1,3)]
names(s2i) <- c("SINCO", "ISCO")

# For rows where SINCO, ISCO is NA, this is because they have the last code listed previously, fill down
s2i <- s2i %>% fill(SINCO, .direction = "down") %>% fill(ISCO, .direction = "down") %>%
  mutate(SINCO = as.character(SINCO))

#=========================================================================#
# Step 9 - Create separate frames for each combo of concord ---------------
#=========================================================================#

# First, create a data frame with the CMO to SINCO (c2s) correspondence at each length (# of digits)
c2s_4d <- concord %>% filter(nchar(sinco) == 4)
c2s_3d <- concord %>% filter(nchar(sinco) == 3) %>% mutate(sinco = str_pad(sinco, 4, pad = "0", side = "right"))
c2s_2d <- concord %>% filter(nchar(sinco) == 2) %>% mutate(sinco = str_pad(sinco, 4, pad = "0", side = "right"))
c2s_1d <- concord %>% filter(nchar(sinco) == 1) %>% mutate(sinco = str_pad(sinco, 4, pad = "0", side = "right"))

#=========================================================================#
# Step 10 - Make mappings of each SINCO level -----------------------------
#=========================================================================#

sinco_map_4 <- create_match_4(s2i)

s2i_3d <- s2i
s2i_3d$SINCO <- substr(s2i_3d$SINCO,1,3)
sinco_map_3 <- create_match_3(s2i_3d)

s2i_2d <- s2i
s2i_2d$SINCO <- substr(s2i_2d$SINCO,1,2)
sinco_map_2 <- create_match_2(s2i_2d)

s2i_1d <- s2i
s2i_1d$SINCO <- substr(s2i_1d$SINCO,1,1)
sinco_map_1 <- create_match_1(s2i_1d)

#=========================================================================#
# Step 11 - Join CMO to SINCO w/ SINCO to ISCO ----------------------------
#=========================================================================#

join_4 <- left_join(c2s_4d, sinco_map_4, by = "sinco")
join_3 <- left_join(c2s_3d, sinco_map_3, by = "sinco")
join_2 <- left_join(c2s_2d, sinco_map_2, by = "sinco")
join_1 <- left_join(c2s_1d, sinco_map_1, by = "sinco")

join <- bind_rows(join_4, join_3, join_2, join_1) %>% 
  rename(match_si = match) %>%
  mutate(match = round( ( (match_cs/100)*(match_si/100) ) * 100,0)) %>%
  select(cmo, isco, match)

#=========================================================================#
# Step 12 - Save ----------------------------------------------------------
#=========================================================================#

write_dta(join, path_out) 

