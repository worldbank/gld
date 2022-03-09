
##################################
# Code to create a concordance ###
# table between SINCO MEX     ####
# and ISCO                   ####
##################################


#=========================================================================#
# Step 0 - User specific information --------------------------------------
#=========================================================================#

rm(list=ls())
path_in <- "C:/Users/wb582018/OneDrive - WBG/Documents/ISCO classification"
path_out <- NA # Leave NA if same as path in
nso_excel_file <- "tablas_comparativas.xlsx"

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

sinco_version <- "SINCO_11"
isco_version <- "ISCO_08"

if (is.na(path_out)){
  path_out <- paste0(path_in, "/", sinco_version, "_", isco_version, ".dta")  
} else {
  path_out <- paste0(path_out, "/", sinco_version, "_", isco_version, ".dta")
}
path_in <- paste0(path_in, "/", nso_excel_file)


df <- read_excel(path = path_in, sheet = 1, skip = 11, col_names = FALSE)

# Drop when entire row is NA
df <- df[!(rowSums(is.na(df)) == 4),]

# Drop when SINCO is not four digit
df <- df[!(df$...1 < 1000 & !is.na(df$...1)),]

# Fill ISCO description down, Drop when SINCO has no correspondence with ISCO
df <- df %>% fill(...4, .direction = "down") 
df <- df[!(df$...4 %in% c("No tiene correspondencia", 
                          "Nota: clasifica a los supervisores junto a los trabajadores que supervisa")),]

# Drop columns we are not interest in, 
df <- df[,c(1,3)]
names(df) <- c("SINCO", "ISCO")

# For rows where SINCO, ISCO is NA, this is because they have the last code listed previously, fill down
df <- df %>% fill(SINCO, .direction = "down") %>% fill(ISCO, .direction = "down") 

# There are 430 distinct 4 digit codes
#there is actually smth wrong here bc some 3 digits appear in the list...
n_distinct(df$SINCO)

#=========================================================================#
# Step 2 - Concordance SINCO4 to ISCO4 ------------------------------------
#=========================================================================#

# Match if concordance is 100%
match_1 <- df %>% 
  count(SINCO, ISCO) %>% 
  rename(instance = n) %>%
  group_by(SINCO) %>%
  mutate(sum = sum(instance)) %>%
  ungroup() %>%
  mutate(pct = round((instance/sum)*100,1)) %>%
  filter(pct == 100)

# Review
done <- n_distinct(match_1$SINCO)
rest <- n_distinct(df$SINCO) - n_distinct(match_1$SINCO)
message(paste0("Step 2 has matched ", done, " codes, hence ", rest, " are left to match"))

#=========================================================================#
# Step 3 - Concordance SINCO4 to ISCO3 ------------------------------------
#=========================================================================#

# Reduce df to cases not yet matched
df_2 <- df[!(df$SINCO %in% match_1$SINCO),]
n_distinct(df_2$SINCO)

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

# Review
done <- n_distinct(match_2$SINCO)
rest <- n_distinct(df$SINCO) - n_distinct(match_1$SINCO) - n_distinct(match_2$SINCO)
message(paste0("Step 3 has matched ", done, " codes, hence ", rest, " are left to match"))

#=========================================================================#
# Step 4 - Concordance SINCO4 to ISCO2 ------------------------------------
#=========================================================================#

# Reduce df to cases not yet matched
df_3 <- df_2[!(df_2$SINCO %in% match_2$SINCO),]
n_distinct(df_3$SINCO)

# Reduce ISIC code to two digits
df_3$ISCO <- substr(df_3$ISCO,1,2)

# Match by maximum
set.seed(61035)
match_3 <- df_3 %>% 
  count(SINCO, ISCO) %>% 
  rename(instance = n) %>%
  group_by(SINCO) %>%
  mutate(sum = sum(instance)) %>%
  ungroup() %>%
  mutate(pct = round((instance/sum)*100,1)) %>%
  filter(pct > 50)

# Review
done <- n_distinct(match_3$SINCO)
rest <- n_distinct(df$SINCO) - n_distinct(match_1$SINCO) - n_distinct(match_2$SINCO) - n_distinct(match_3$SINCO)
message(paste0("Step 4 has matched ", done, " codes, hence ", rest, " are left to match"))

#=========================================================================#
# Step 5 - Concordance SINCO4 to ISCO1 ------------------------------------
#=========================================================================#

# Reduce df to cases not yet matched
df_4 <- df_3[!(df_3$SINCO %in% match_3$SINCO),]
n_distinct(df_4$SINCO)

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

# Review
done <- n_distinct(match_4$SINCO)
rest <- n_distinct(df$SINCO) - n_distinct(match_1$SINCO) - n_distinct(match_2$SINCO) - n_distinct(match_3$SINCO) - n_distinct(match_4$SINCO)
message(paste0("Step 5 has matched ", done, " codes, hence ", rest, " are left to match"))

#=========================================================================#
# Step 6 - Unite all matches ----------------------------------------------
#=========================================================================#

concord <- bind_rows(match_1, match_2, match_3, match_4) %>%
  select(sinco = SINCO, isco = ISCO, match = pct) %>%
  mutate(sinco = str_pad(sinco, 4, pad = "0", side = "right"),
         isco  = str_pad(isco, 4, pad = "0", side = "right"))


write_dta(concord, path_out) 
