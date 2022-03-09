    
    ##################################
    # Code to create a comparison ####
    # table between SCIAN MEX     ####
    # and ISIC                    ####
    ##################################


#=========================================================================#
# Step 0 - User specific information --------------------------------------
#=========================================================================#

rm(list=ls())
scian_version <- "SCIAN_18"
isic_version <- "ISIC_4"

path <- "C:/Users/wb582018/OneDrive - WBG/Documents/Industry Classification"
nso_excel_file <- "SCIAN_18_ISIC_4.xlsx"

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
path_out <- paste0(path, "/", scian_version, "_", isic_version, ".dta")

df <- read_excel(path = path_in, sheet = 1, skip = 2)

# Drop columns we are not interest in, 
df <- df[,c(1,5)]
names(df) <- c("SCIAN", "ISIC")

# Drop rows where ISIC is missing
indx <- is.na(df$ISIC)
df <- df[!indx,]

# Drop one row where SCIAN is XXXXX, drop 2 cases where ISIC is XXXX 
isic_txt <- grepl("[A-Za-z]", df$ISIC)
scian_txt <- grepl("[A-Za-z]", df$SCIAN)
df <- df[!(scian_txt | isic_txt) ,]

# For rows where SCIAN is NA, this is because they have the last code listed previously, fill down
df <- df %>% fill(SCIAN, .direction = "down")

# Reduce SCIAN to four digits as this is the level we have in ENOE
df$SCIAN <- substr(df$SCIAN,1,4)

# There are 309 distinct 4 digit codes
n_distinct(df$SCIAN)

#=========================================================================#
# Step 2 - Concordence SCIAN4 to ISIC4 ------------------------------------
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

# Review
done <- n_distinct(match_1$SCIAN)
rest <- n_distinct(df$SCIAN) - n_distinct(match_1$SCIAN)
message(paste0("Step 2 has matched ", done, " codes, hence ", rest, " are left to match"))

#=========================================================================#
# Step 3 - Concordence SCIAN4 to ISIC3 ------------------------------------
#=========================================================================#

# Reduce df to cases not yet matched
df_2 <- df[!(df$SCIAN %in% match_1$SCIAN),]
n_distinct(df_2$SCIAN)

# Reduce ISIC codes to three digits
df_2$ISIC <- substr(df_2$ISIC,1,3)

# Match if perfect
match_2 <- df_2 %>% 
  count(SCIAN, ISIC) %>% 
  rename(instance = n) %>%
  group_by(SCIAN) %>%
  mutate(sum = sum(instance)) %>%
  ungroup() %>%
  mutate(pct = round((instance/sum)*100,1)) %>%
  filter(pct == 100)

# Review
done <- n_distinct(match_2$SCIAN)
rest <- n_distinct(df$SCIAN) - n_distinct(match_1$SCIAN) - n_distinct(match_2$SCIAN)
message(paste0("Step 3 has matched ", done, " codes, hence ", rest, " are left to match"))

#=========================================================================#
# Step 4 - Concordence SCIAN4 to ISIC2 ------------------------------------
#=========================================================================#

# Reduce df to cases not yet matched
df_3 <- df_2[!(df_2$SCIAN %in% match_2$SCIAN),]
n_distinct(df_3$SCIAN)

# Reduce ISIC code to two digits
df_3$ISIC <- substr(df_3$ISIC,1,2)

# Match by maximum
set.seed(61035)
match_3 <- df_3 %>% 
  count(SCIAN, ISIC) %>% 
  rename(instance = n) %>%
  group_by(SCIAN) %>%
  mutate(sum = sum(instance)) %>%
  ungroup() %>%
  mutate(pct = round((instance/sum)*100,1)) %>%
  group_by(SCIAN) %>%
  slice_max(pct) %>%
  sample_n(1)

# Review
done <- n_distinct(match_3$SCIAN)
rest <- n_distinct(df$SCIAN) - n_distinct(match_1$SCIAN) - n_distinct(match_2$SCIAN) - n_distinct(match_3$SCIAN)
message(paste0("Step 4 has matched ", done, " codes, hence ", rest, " are left to match"))

#=========================================================================#
# Step 5 - Concordence straight from SCIAN3 to ISIC2 ---------------------
#=========================================================================#

# Even if we may map SCIAN4 to ISIC (eg. map codes 1111, 1112, and 1113 to something)
# ENOE contains codes 1110 that are not in the mapping by the stats institute. Hence make it.

direct <- df %>% mutate(SCIAN = substr(SCIAN,1,3),
                        ISIC = substr(ISIC,1,3))

match_d <- direct %>% 
  count(SCIAN, ISIC) %>% 
  rename(instance = n) %>%
  group_by(SCIAN) %>%
  mutate(sum = sum(instance)) %>%
  ungroup() %>%
  mutate(pct = round((instance/sum)*100,1)) %>%
  filter(pct == 100)

#=========================================================================#
# Step 6 - Concordence straight from SCIAN3 to ISIC2 ---------------------
#=========================================================================#

# Reduce df to cases not yet matched
direct_2 <- direct[!(direct$SCIAN %in% match_d$SCIAN),]
n_distinct(direct_2$SCIAN)

# Reduce ISIC code to two digits
direct_2$ISIC <- substr(direct_2$ISIC,1,2)

match_d2 <- direct_2 %>% 
  count(SCIAN, ISIC) %>% 
  rename(instance = n) %>%
  group_by(SCIAN) %>%
  mutate(sum = sum(instance)) %>%
  ungroup() %>%
  mutate(pct = round((instance/sum)*100,1)) %>%
  group_by(SCIAN) %>%
  slice_max(pct) %>%
  sample_n(1)

#=========================================================================#
# Step 7 - Unite all matches ----------------------------------------------
#=========================================================================#

concord <- bind_rows(match_1, match_2, match_3, match_d, match_d2) %>%
  select(scian = SCIAN, isic = ISIC, match = pct) %>%
  mutate(scian = str_pad(scian, 4, pad = "0", side = "right"),
         isic  = str_pad(isic, 4, pad = "0", side = "right"))


write_dta(concord, path_out)
