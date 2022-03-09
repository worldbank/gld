
##################################
# Code to creat a concordance ####
# table between SCIAN 07 MEX  ####
# and ISIC Rev 4              ####
# ----------------------------####
# UPDATED TO 3 DIGIT SCIAN    ####
# ----------------------------####
##################################


#=========================================================================#
# Step 1 - Call libraries, read in data, reduce to relevant ---------------
#=========================================================================#

rm(list=ls())
library(readxl)
library(dplyr)
library(tidyr)
library(stringr)
library(haven)

path <- "C:/Users/wb529026/OneDrive - WBG/Documents/Country Work/MEX/Industry Classification"
df <- read_excel(path = paste0(path, "/SCIAN_07_ISIC_4.xlsx"), sheet = 1, skip = 2)

# Drop columns we are not interest in, 
df <- df[,c(1,5)]
names(df) <- c("SCIAN", "ISIC")

# Drop rows where ISIC is missing
indx <- is.na(df$ISIC)
df <- df[!indx,]

# Drop whre ISIC or SCIAN are text
isic_txt <- grepl("[A-Za-z]", df$ISIC)
scian_txt <- grepl("[A-Za-z]", df$SCIAN)
df <- df[!(scian_txt | isic_txt) ,]

# For rows where SCIAN is NA, this is because they have the last code listed previously, fill down
df <- df %>% fill(SCIAN, .direction = "down")

# Reduce SCIAN to three digits 
# Data in ENOE is 4 digits, but the fourth is an addendum, as (oddly) done by INEGI
df$SCIAN <- substr(df$SCIAN,1,3)
df$ISIC <- substr(df$ISIC,1,3)

# There are 94 distinct 4 digit codes
n_distinct(df$SCIAN)

#=========================================================================#
# Step 2 - Concordance SCIAN3 to ISIC3 ------------------------------------
#=========================================================================#

# Match if concordance is 100%
match_1 <- df %>% 
  count(SCIAN, ISIC) %>% 
  rename(instance = n) %>%
  group_by(SCIAN) %>%
  mutate(sum = sum(instance)) %>%
  ungroup() %>%
  mutate(pct = round((instance/sum)*100,1)) %>%
  filter(pct == 100)

# Step_2 has matched 17 codes, hence 77 are left to match
n_distinct(match_1$SCIAN)
n_distinct(df$SCIAN) - n_distinct(match_1$SCIAN)

#=========================================================================#
# Step 3 - Concordance SCIAN3 to ISIC2 ------------------------------------
#=========================================================================#

# Reduce df to cases not yet matched
df_2 <- df[!(df$SCIAN %in% match_1$SCIAN),]
n_distinct(df_2$SCIAN)

# Reduce ISIC code to two digits
df_2$ISIC <- substr(df_2$ISIC,1,2)

# Match if concordance in at least 75% of cases
match_2 <- df_2 %>% 
  count(SCIAN, ISIC) %>% 
  rename(instance = n) %>%
  group_by(SCIAN) %>%
  mutate(sum = sum(instance)) %>%
  ungroup() %>%
  mutate(pct = round((instance/sum)*100,1)) %>%
  filter(pct >= 75)

# Step_3 has matched 49 codes, hence 28 are left to match
n_distinct(match_2$SCIAN)
n_distinct(df$SCIAN) - n_distinct(match_1$SCIAN) - n_distinct(match_2$SCIAN)


#=========================================================================#
# Step 4 - Concordance SCIAN2 to ISIC2 ------------------------------------
#=========================================================================#

# Reduce df to cases not yet matched
df_3 <- df_2[!(df_2$SCIAN %in% match_2$SCIAN),]
n_distinct(df_3$SCIAN)

# Reduce SCIAN to two digits
df_3$SCIAN_2 <- substr(df_3$SCIAN,1,2)

# Set seed for slicing later
set.seed(61035)

# Match if concordance in at least 66.7% of cases
match_3 <- df_3 %>% 
  count(SCIAN, SCIAN_2, ISIC) %>% 
  rename(instance = n) %>%
  group_by(SCIAN) %>%
  mutate(sum = sum(instance)) %>%
  mutate(pct = round((instance/sum)*100,1),
         max_pct = max(pct)) %>%
  filter(pct >= max_pct) %>%
  slice_sample()

#=========================================================================#
# Step 5 - Unite all matches ----------------------------------------------
#=========================================================================#

concord <- bind_rows(match_1, match_2, match_3) %>%
  select(scian = SCIAN, isic = ISIC, match = pct) %>%
  mutate(isic  = str_pad(isic, 4, pad = "0", side = "right"))


write_dta(concord, paste0(path, "/SCIAN_07_3D_ISIC_4.dta"))
