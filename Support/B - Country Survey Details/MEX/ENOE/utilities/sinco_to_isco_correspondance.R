
##################################
# Code to create a concordance ###
# table between SINCO MEX     ####
# and ISCO                   ####
##################################


#=========================================================================#
# Step 0 - User specific information --------------------------------------
#=========================================================================#

rm(list=ls())
path_in <- "C:/Users/wb529026/OneDrive - WBG/Documents/Country Work/MEX/Occupation Classification"
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

# There are odd cases that require manual treatment, set them aside

# First when there is a note instead of a correspondence code
odd_nota <- df[(df$...4 %in% c("Nota: clasifica a los supervisores junto a los trabajadores que supervisa")),] %>%
  # Keep only four digit codes, three digit ones should go
  filter(...1 > 999)

# Then for cases defined as "without correspondence"
odd_no_correspond <- df[(df$...4 %in% c("No tiene correspondencia")),] %>%
  # Keep only four digit codes
  filter(...1 > 999)

# Once saved, focus df only on what has correspondence
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


#=========================================================================#
# Step 7 - Add manual matches ---------------------------------------------
#=========================================================================#

# We manually assign codes to the codes present in SINCO but for which the
# correspondence table gives us no information. This is based on SINCO 
# descriptions (1) and ISCO 08 ones (2)

# Links below as of 2024/11/06
# (1) http://internet.contenidos.inegi.org.mx/contenidos/productos/prod_serv/contenidos/espanol/bvinegi/productos/metodologias/est/sinco_2011.pdf
# (2) https://www.ilo.org/sites/default/files/wcmsp5/groups/public/@dgreports/@dcomm/@publ/documents/publication/wcms_172572.pdf

orphan_sinco_codes <- as.character(c(odd_nota$...1, odd_no_correspond$...1))
orphan_isco_codes <- c("5152", # Supervisors of housework, same as workers
                       "5410", # Supervisors of protective service workers (psw) as psw
                       "6100", # Agro/fish supervisor as market ag workers
                       "6200", # Fish/aquaculture supervisor as market forest, fish
                       "7200", # Metalwork supervisors as metalworkers
                       "",     # Don't have a good one, should be few people
                       "7510", # Food process (fp) supervisors as fp workers
                       "7310", # Handicraft supervisors as handicraft
                       "",     # Don't have a good one, should be few people
                       "1100", # Other presidents, CEO as Chie Executives
                       "1300", # Public utilities Managers as Production Managers
                       "1300", # Coordinator public utilities as Production Managers
                       "1300", # Other coordinators as Production Managers
                       "1300", # Other coordinators in ITC PM
                       "",     # Other directors, no code, should be few
                       "2654", # Set designers
                       "2300", # Alphabetisers as teachers
                       "2300", # Bilingual (indigenous) teacher as teacher
                       "2300", # Other teachers n.e.c. as teacher
                       "2200", # Biomedical engineers as health professionals
                       "",     # Don't have a good one, should be few people
                       "3130", # Electrical technician supervisors as process control techs
                       "7400", # Electrical tecs n.e.c.as Eletrical Workers
                       "5312", # Auxiliary teaching as teachers' aides
                       "",     # Too vague
                       "",     # Too vague
                       "5249", # Mobile goods rental as sales n.e.c. (example is rental salesperson)
                       "5200", # Other sales workers as generic sales workers
                       "6100", # Other ag workers as market ag workers
                       "6100", # Other ag workers as market ag workers
                       "6100", # Other ag workers as market ag workers
                       "6200", # Other fish sector workers as market fishery
                       "6200", # Other fishery, water workers as market fishery
                       "",     # Too vague
                       "8300", # Other drivers as drivers, mobile plant operators
                       "9100", # Car handler on tips as cleaners and helpers
                       "",     # Unclear
                       "")     # Too vague

orphan_df <- data.frame(sinco = orphan_sinco_codes, isco = orphan_isco_codes, match = 999) %>%
  filter(isco != "")

#=========================================================================#
# Step 8 - Combine manual, save -------------------------------------------
#=========================================================================#

concord <- bind_rows(concord, orphan_df)

write_dta(concord, path_out) 
