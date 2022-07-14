

#================================#
# Code to create a concordance ==#
# table between NCO 68,        ==#
# NCO 2004, and ISCO-08        ==#
#================================#


#=========================================================================#
# Step 1 - Call libraries, read in data, reduce to relevant ---------------
#=========================================================================#

rm(list=ls())
path_in <- "C:/Users/wb529026/OneDrive - WBG/Documents/Country Work/IND/IND_1987_EUS/IND_1987_EUS_v01_M/Doc"
path_out <- NA # Leave NA if same as path in
correspondence_file <- "occupation_correspondences.xlsx"

packages = c("haven", "readxl", "dplyr", "tidyr", "stringr")

for (package in packages){
  if (!require(package, character.only = TRUE)){ # If package not known, install and load
    install.packages(package, dependencies = TRUE)
    library(package, character.only = TRUE)
  }
}

if (is.na(path_out)){
  path_out <- paste0(path_in, "/", "India_occup_correspondences.dta")  
} else {
  path_out <- paste0(path_out, "/", "India_occup_correspondences.dta")
}
path_in <- paste0(path_in, "/", correspondence_file)


nco_68_04  <- read_excel(path = path_in, sheet = 1) %>% 
  select(nco_68 = NCO_1968, nco_04 = NCO_2004) %>%
  mutate(nco_68 = str_pad(as.character(nco_68), 3, pad = "0", side = "left"),
         nco_04 = as.character(nco_04))

nco04_isco <- read_excel(path = path_in, sheet = 2) %>%
  na.omit() %>%
  mutate_all(as.character()) %>%
  rename(isco_88 = `ISCO 1988`, nco_04 = `NCO 2004`)


#=========================================================================#
# Step 2 - Join two table into pivot, clean -------------------------------
#=========================================================================#

pivot <- left_join(nco_68_04, nco04_isco, by = "nco_04")

# Note that nco 68 is not unique
n_distinct(pivot$nco_68)
nrow(pivot)

# This is because codes 159 and 301 match each 3 ISCO - 88 codes
table(pivot$nco_68) %>% 
  as.data.frame() %>% 
  arrange(desc(Freq)) %>%
  head()

pivot %>% filter(nco_68 %in% c("159", "301"))

# Drop redundant cases, reduce isco-88 to 230 for all cases
indx <- pivot$nco_68 %in% c("159", "301") & pivot$isco_88 %in% c("234", "235")
pivot <- pivot[!indx, ]
pivot$isco_88[pivot$nco_68 %in% c("159", "301")] <- "230"

# Pad isco to four digit
pivot <- pivot %>%
  mutate(isco_88 = str_pad(isco_88, 4, pad = "0", side = "right"))

#=========================================================================#
# Step 3 - Create straight NCO 04 to ISCO 88 ----------------------------
#=========================================================================#

# Only one case of non unique mapping
# Code 233 of NCO maps to ISCO 233, 234, and 235, map to 230 instead
straight_map <- nco04_isco
straight_map$isco_88[straight_map$nco_04 == "233"] <- 230
straight_map <- straight_map %>% 
  group_by(nco_04) %>%
  filter(row_number()==1)


#=========================================================================#
# Step 4 - Save file ------------------------------------------------------
#=========================================================================#

# Save pivot
write_dta(pivot, path_out)


# Save straigth nco04 to isco
write_dta(straight_map, "C:/Users/wb529026/OneDrive - WBG/Documents/Country Work/IND/IND_1987_EUS/IND_1987_EUS_v01_M/Doc/India_nco_04_to_isco_88.dta")


