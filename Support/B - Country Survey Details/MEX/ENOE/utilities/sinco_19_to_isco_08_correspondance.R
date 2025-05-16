
##################################
# Code to create a concordance ###
# table between SINCO MEX     ####
# and ISCO                   ####
##################################


#=========================================================================#
# Step 0 - User specific information --------------------------------------
#=========================================================================#

rm(list=ls())
path_general <- "Y:/GLD-Harmonization/529026_MG/Countries/MEX/Occupation Classification"
path_input   <- paste0(path_general, "/Input")
path_output  <- paste0(path_general, "/Output")
nso_excel_file <- "SINCO_2019_Tablas_Comparativas.xlsx"

## From here on the code should run on its own, no further input needed.
sinco_version <- "SINCO_19"
isco_version  <- "ISCO_08"

output_file <- paste(path_output, "SINCO_19_ISCO_08.dta", sep = "/")

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

# Read in file - SINCO to ISCO sheet
df <- read_excel(path = paste(path_input, nso_excel_file, sep = "/"), 
                 sheet = 1, skip = 1, col_names = TRUE)


# There are 35 cases defined as "without correspondence"
# Require manual treatment, set them aside
odd_no_correspond <- df[is.na(df[[3]]), ]

# Once saved, focus df only on what has correspondence
df <- df[!is.na(df[[3]]), ]

# Drop columns we are not interest in, 
df <- df[,c(1,3)]
names(df) <- c("SINCO", "ISCO")

# There are 455 distinct 4 digit codes
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

#=========================================================================#
# Step 7 - Add manual matches ---------------------------------------------
#=========================================================================#

# We manually assign codes to the codes present in SINCO but for which the
# correspondence table gives us no information. This is based on SINCO 
# descriptions (1) and ISCO 08 ones (2)

# Links below as of 2024/11/06
# (1) See documentation on server shared by INEGI
# (2) https://www.ilo.org/sites/default/files/wcmsp5/groups/public/@dgreports/@dcomm/@publ/documents/publication/wcms_172572.pdf

orphan_sinco_codes <- as.character(c(
  1319, 1329, 1619, 1629, 1999, 2334, 2399,
  2639, 2640, 2649, 2991, 2992, 3999, 4999,
  5201, 5299, 5301, 6101, 6117, 6119, 6128,
  6129, 6201, 6999, 7299, 7399, 7599, 8301, 
  8349, 8999, 9213, 9311, 9599, 9733, 9999))

orphan_isco_codes <- c(
  "1300", "1300", "1300", "1300", "1300", "2300",
  "2300", "7230", "3130", "7400", "", "", "",
  "5200", "5152", "5200", "5410", "6100", "6100", 
  "6100", "6200", "6100", "6200", "", "7210", "", "",
  "8300", "8300", "", "9300", "9300", "9500", "9600", "9600")
  
orphan_df <- data.frame(sinco = orphan_sinco_codes, isco = orphan_isco_codes, match = 999) %>%
  filter(isco != "")

#=========================================================================#
# Step 8 - Combine manual, save -------------------------------------------
#=========================================================================#

concord <- bind_rows(concord, orphan_df)

write_dta(concord, output_file) 
