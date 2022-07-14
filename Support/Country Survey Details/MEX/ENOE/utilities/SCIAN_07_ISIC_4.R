
##################################
# Code to creat a concordance ####
# table between SCIAN 07 MEX  ####
# and ISIC Rev 4              ####
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

# Reduce SCIAN to four digits as this is the level we have in ENOE
df$SCIAN <- substr(df$SCIAN,1,4)

# There are 304 distinct 4 digit codes
n_distinct(df$SCIAN)

#=========================================================================#
# Step 2 - Concordance SCIAN4 to ISIC4 ------------------------------------
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

# Step_2 has matched 109 codes, hence 195 are left to match
n_distinct(match_1$SCIAN)
n_distinct(df$SCIAN) - n_distinct(match_1$SCIAN)

#=========================================================================#
# Step 3 - Concordance SCIAN3 to ISIC3 ------------------------------------
#=========================================================================#

# Reduce df to cases not yet matched
df_2 <- df[!(df$SCIAN %in% match_1$SCIAN),]
n_distinct(df_2$SCIAN)

# Reduce SCIAN, ISIC codes to three digits
df_2$SCIAN_3 <- substr(df_2$SCIAN,1,3)
df_2$ISIC <- substr(df_2$ISIC,1,3)

# Match if concordance in at least 75% of cases
match_2 <- df_2 %>% 
  count(SCIAN, SCIAN_3, ISIC) %>% 
  rename(instance = n) %>%
  group_by(SCIAN) %>%
  mutate(sum = sum(instance)) %>%
  ungroup() %>%
  mutate(pct = round((instance/sum)*100,1)) %>%
  filter(pct >= 75)

# Step_3 has matched 60 codes, hence 135 are left to match
n_distinct(match_2$SCIAN)
n_distinct(df$SCIAN) - n_distinct(match_1$SCIAN) - n_distinct(match_2$SCIAN)


#=========================================================================#
# Step 4 - Concordance SCIAN3 to ISIC2 ------------------------------------
#=========================================================================#

# Reduce df to cases not yet matched
df_3 <- df_2[!(df_2$SCIAN %in% match_2$SCIAN),]
n_distinct(df_3$SCIAN)

# Reduce ISIC code to two digits
df_3$SCIAN_3 <- substr(df_3$SCIAN,1,3)
df_3$ISIC <- substr(df_3$ISIC,1,2)

# Match if concordance in at least 66.7% of cases
match_3 <- df_3 %>% 
  count(SCIAN, SCIAN_3, ISIC) %>% 
  rename(instance = n) %>%
  group_by(SCIAN) %>%
  mutate(sum = sum(instance)) %>%
  ungroup() %>%
  mutate(pct = round((instance/sum)*100,1)) %>%
  filter(pct >= 66.7)

# Step_4 has matched 95 codes, hence 40 are left to match
n_distinct(match_3$SCIAN)
n_distinct(df$SCIAN) - n_distinct(match_1$SCIAN) - n_distinct(match_2$SCIAN) - n_distinct(match_3$SCIAN)

#=========================================================================#
# Step 5 - Concordance SCIAN2 to ISIC2 ------------------------------------
#=========================================================================#

# Reduce df to cases not yet matched
df_4 <- df_3[!(df_3$SCIAN %in% match_3$SCIAN),]
n_distinct(df_4$SCIAN)

# Reduce SCIAN, ISIC codes to two digits
df_4$SCIAN_2 <- substr(df_4$SCIAN,1,2)
df_4$ISIC <- substr(df_4$ISIC,1,2)

# Match if concordance is over 50%
match_4 <- df_4 %>% 
  count(SCIAN, SCIAN_2, ISIC) %>% 
  rename(instance = n) %>%
  group_by(SCIAN) %>%
  mutate(sum = sum(instance)) %>%
  ungroup() %>%
  mutate(pct = round((instance/sum)*100,1)) %>%
  filter(pct > 50)

# Step_4 has matched 9 codes, hence 31 are left to match
n_distinct(match_4$SCIAN)
n_distinct(df$SCIAN) - n_distinct(match_1$SCIAN) - n_distinct(match_2$SCIAN) - n_distinct(match_3$SCIAN) - n_distinct(match_4$SCIAN)

#=========================================================================#
# Step 6 - Concordance SCIAN2 to ISIC1 ------------------------------------
#=========================================================================#

# Reduce df to cases not yet matched
df_5 <- df_4[!(df_4$SCIAN %in% match_4$SCIAN),]
n_distinct(df_5$SCIAN)

# Reduce SCIAN, ISIC codes to two digits
df_5$SCIAN_2 <- substr(df_5$SCIAN,1,2)
df_5$ISIC <- substr(df_5$ISIC,1,1)

# Match if concordance is over 50%
match_5 <- df_5 %>% 
  count(SCIAN, SCIAN_2, ISIC) %>% 
  rename(instance = n) %>%
  group_by(SCIAN) %>%
  mutate(sum = sum(instance)) %>%
  ungroup() %>%
  mutate(pct = round((instance/sum)*100,1)) %>%
  filter(pct > 50)

# Step_4 has matched 17 codes, hence 14 are left to match
n_distinct(match_5$SCIAN)
n_distinct(df$SCIAN) - n_distinct(match_1$SCIAN) - n_distinct(match_2$SCIAN) - n_distinct(match_3$SCIAN) - n_distinct(match_4$SCIAN) - n_distinct(match_5$SCIAN)

#=========================================================================#
# Step 7 - Concordance straight from SCIAN3 to ISIC2 ---------------------
#=========================================================================#

# Even if we may map SCIAN4 to ISIC (eg. map codes 1111, 1112, and 1113 to something)
# ENOE contains codes 1110 that are not in the mapping by the stats institute. Hence make it.

direct <- df %>% mutate(SCIAN = substr(SCIAN,1,3),
                        ISIC = substr(ISIC,1,2))

match_d <- direct %>% 
  count(SCIAN, ISIC) %>% 
  rename(instance = n) %>%
  group_by(SCIAN) %>%
  mutate(sum = sum(instance)) %>%
  ungroup() %>%
  mutate(pct = round((instance/sum)*100,1)) %>%
  filter(pct > 50)

#=========================================================================#
# Step 8 - Concordance straight from SCIAN3 to ISIC1 ---------------------
#=========================================================================#

# Reduce df to cases not yet matched
direct_2 <- direct[!(direct$SCIAN %in% match_d$SCIAN),]
n_distinct(direct_2$SCIAN)

# Reduce ISIC to one code
direct_2$ISIC <- substr(direct_2$ISIC,1,1)

match_d2 <- direct_2 %>% 
  count(SCIAN, ISIC) %>% 
  rename(instance = n) %>%
  group_by(SCIAN) %>%
  mutate(sum = sum(instance)) %>%
  ungroup() %>%
  mutate(pct = round((instance/sum)*100,1)) %>%
  filter(pct > 50)

#=========================================================================#
# Step 9 - Unite all matches ----------------------------------------------
#=========================================================================#

concord <- bind_rows(match_1, match_2, match_3, match_4, match_5, match_d, match_d2) %>%
  select(scian = SCIAN, isic = ISIC, match = pct) %>%
  mutate(scian = str_pad(scian, 4, pad = "0", side = "right"),
         isic  = str_pad(isic, 4, pad = "0", side = "right"))


write_dta(concord, paste0(path, "/SCIAN_07_ISIC_4.dta"))
