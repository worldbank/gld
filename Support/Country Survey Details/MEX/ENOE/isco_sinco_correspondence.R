
##################################
# Code to create a concordance ###
# table between SINCO MEX     ####
# and ISCO                   ####
##################################


#=========================================================================#
# Step 0 - User specific information --------------------------------------
#=========================================================================#

rm(list=ls())
sinco_version <- "SINCO_11"
isco_version <- "ISCO_8"

path <- "C:/Users/wb582018/OneDrive - WBG/Documents/ISCO Classification"
nso_excel_file <- "sinco_tablas_comparativas.xlsx"

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

path_in <- paste0(path, "/", nso_excel_file)
path_out <- paste0(path, "/", sinco_version, "_", isco_version, ".dta")

df <- read_excel(path = path_in, sheet = 1, skip = 2)

# Drop columns we are not interest in, 
df <- df[,c(3,5)]
names(df) <- c("SINCO", "ISCO")

# Drop rows where ISCO is missing
indx <- is.na(df$ISCO)
df <- df[!indx,]

# Drop one row where SCIAN is XXXXX, drop 2 cases where ISIC is XXXX 
#isic_txt <- grepl("[A-Za-z]", df$ISIC)
#scian_txt <- grepl("[A-Za-z]", df$SCIAN)
#df <- df[!(scian_txt | isic_txt) ,]

# For rows where SINCO is NA, this is because they have the last code listed previously, fill down
df <- df %>% fill(SINCO, .direction = "down")

# Reduce SCIAN to four digits as this is the level we have in ENOE
#df$SCIAN <- substr(df$SCIAN,1,4)

# There are 396 distinct 4 digit codes
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
n_distinct(df_2$SCIAN)

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
  group_by(SINCO) %>%
  slice_max(pct) %>%
  sample_n(1)

# Review
done <- n_distinct(match_3$SINCO)
rest <- n_distinct(df$SINCO) - n_distinct(match_1$SINCO) - n_distinct(match_2$SINCO) - n_distinct(match_3$SINCO)
message(paste0("Step 4 has matched ", done, " codes, hence ", rest, " are left to match"))

#=========================================================================#
# Step 5 - Concordance straight from SINCO3 to ISCO2 ---------------------
#=========================================================================#

# Even if we may map SINCO4 to ISCO (eg. map codes 1111, 1112, and 1113 to something)
# ENOE contains codes 1110 that are not in the mapping by the stats institute. Hence make it.

#direct <- df %>% mutate(SCIAN = substr(SCIAN,1,3),
#                        ISIC = substr(ISIC,1,3))

#match_d <- direct %>% 
#  count(SCIAN, ISIC) %>% 
 # rename(instance = n) %>%
#  group_by(SCIAN) %>%
#  mutate(sum = sum(instance)) %>%
#  ungroup() %>%
#  mutate(pct = round((instance/sum)*100,1)) %>%
#  filter(pct == 100)

#=========================================================================#
# Step 6 - Concordance straight from SCIAN3 to ISIC2 ---------------------
#=========================================================================#

# Reduce df to cases not yet matched
#direct_2 <- direct[!(direct$SINCO %in% match_d$SINCO),]
#n_distinct(direct_2$SINCO)

# Reduce ISCO code to two digits
#direct_2$ISCO <- substr(direct_2$ISCO,1,2)

#match_d2 <- direct_2 %>% 
#  count(SINCO, ISCO) %>% 
#  rename(instance = n) %>%
# group_by(SINCO) %>%
# mutate(sum = sum(instance)) %>%
#  ungroup() %>%
#  mutate(pct = round((instance/sum)*100,1)) %>%
#  group_by(SINCO) %>%
#  slice_max(pct) %>%
#  sample_n(1)

#=========================================================================#
# Step 7 - Unite all matches ----------------------------------------------
#=========================================================================#
#match_d,match_d2
concord <- bind_rows(match_1, match_2, match_3) %>%
  select(sinco = SINCO, isco = ISCO, match = pct) %>%
  mutate(sinco = str_pad(sinco, 4, pad = "0", side = "right"),
         isco  = str_pad(isco, 4, pad = "0", side = "right"))


write_dta(concord, path_out)