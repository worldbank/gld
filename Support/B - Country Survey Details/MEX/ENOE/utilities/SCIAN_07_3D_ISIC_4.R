
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

path <- "C:/Users/wb529026/OneDrive - WBG/Documents/Country Work/MEX/SCIAN_07_ISIC_4"
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

# Match if concordance with at least absolute majority
match_2 <- df_2 %>% 
  count(SCIAN, ISIC) %>% 
  rename(instance = n) %>%
  group_by(SCIAN) %>%
  mutate(sum = sum(instance)) %>%
  ungroup() %>%
  mutate(pct = round((instance/sum)*100,1)) %>%
  filter(pct > 50)

# Step_3 has matched 60 codes, hence 17 are left to match
n_distinct(match_2$SCIAN)
n_distinct(df$SCIAN) - n_distinct(match_1$SCIAN) - n_distinct(match_2$SCIAN)


#=========================================================================#
# Step 4 - Concordance SCIAN2 to ISIC2 ------------------------------------
#=========================================================================#

# Reduce df to cases not yet matched
df_3 <- df_2[!(df_2$SCIAN %in% match_2$SCIAN),]
n_distinct(df_3$SCIAN)

# Create ISIC Sections
df_3 <- df_3 %>%
  mutate(
    ISIC_int = as.integer(ISIC),
    ISIC_S = case_when((ISIC_int >= 1 & ISIC_int <= 3) ~  "A",
                       (ISIC_int >= 5 & ISIC_int <= 9) ~  "B",
                       (ISIC_int >=10  & ISIC_int <= 33) ~  "C",
                       (ISIC_int >=35  & ISIC_int <= 35) ~  "D",
                       (ISIC_int >=36  & ISIC_int <= 39) ~  "E",
                       (ISIC_int >=41  & ISIC_int <= 43) ~  "F",
                       (ISIC_int >=45  & ISIC_int <= 47) ~  "G",
                       (ISIC_int >=49  & ISIC_int <= 53) ~  "H",
                       (ISIC_int >=55  & ISIC_int <= 56) ~  "I",
                       (ISIC_int >=58  & ISIC_int <= 63) ~  "J",
                       (ISIC_int >=64  & ISIC_int <= 66) ~  "K",
                       (ISIC_int >=68  & ISIC_int <= 68) ~  "L",
                       (ISIC_int >=69  & ISIC_int <= 75) ~  "M",
                       (ISIC_int >=77  & ISIC_int <= 82) ~  "N",
                       (ISIC_int >=84  & ISIC_int <= 84) ~  "O",
                       (ISIC_int >=85  & ISIC_int <= 85) ~  "P",
                       (ISIC_int >=86  & ISIC_int <= 88) ~  "Q",
                       (ISIC_int >=90  & ISIC_int <= 93) ~  "R",
                       (ISIC_int >=94  & ISIC_int <= 96) ~  "S",
                       (ISIC_int >=97  & ISIC_int <= 98) ~  "T",
                       (ISIC_int >=99  & ISIC_int <= 99) ~  "U"))


# Create evaluation help at ISIC-S
# Only keep cases where there is a single simple majority dominant section
eval_helper <- df_3 %>% 
  count(SCIAN, ISIC_S) %>% 
  rename(instance = n) %>%
  group_by(SCIAN) %>%
  mutate(sum = sum(instance),
         pct = round((instance/sum)*100,1),
         max_pct = max(pct),
         cases_with_max = ifelse(pct == max_pct,1,0),
         max_cases = sum(cases_with_max)) %>%
  filter(max_cases == 1) %>%
  filter(cases_with_max == 1)

# Check there is a single preferred option per code
stopifnot(n_distinct(eval_helper$SCIAN) == dim(eval_helper)[1])

# Set seed for slicing later
set.seed(61035)

# Create match by simple
match_3 <- df_3 %>%
  count(SCIAN, ISIC_S, ISIC) %>% 
  left_join(eval_helper %>% select(SCIAN, ISIC_S, instance), by = c("SCIAN", "ISIC_S")) %>%
  group_by(SCIAN) %>%
  # Let instance be NA only if there is a preferred group and it is not part of it
  mutate(merge_test = sum(instance, na.rm = T),
         instance = case_when(merge_test == 0 ~ sum(n),
                              T ~ instance)) %>%
  select(-merge_test) %>%
  # Drop cases from not preferred groups
  filter(!is.na(instance)) %>%
  group_by(SCIAN) %>%
  mutate(pct = round((n/instance)*100,1),
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
