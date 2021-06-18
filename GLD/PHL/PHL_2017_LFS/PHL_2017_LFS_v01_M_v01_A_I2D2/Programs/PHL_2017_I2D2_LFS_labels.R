# PHL_2017_I2D2_LFS_labels.R
# A helper script for PHL_2017_I2D2_LFS_labels.do that harmonizes data labels

# Note, this script assumes that you have already run PHL_2017_I2D2_LFS_labels.do and output an iecodebook xlsx file 
# and duplicated it manually and saved it under the suffix "-IN.xlsx". For more info, see README

library(tidyverse)
library(openxlsx)
library(readxl)

setwd("Y:/GLD-Harmonization/551206_TM/PHL/PHL_2017_LFS/PHL_2017_LFS_v01_M_v01_A_I2D2/Doc")

# Value Lable Harmonization ----
## Read in all choices ----
round1 <- read_xlsx(
  path = "PHL_2017_append_template-IN-R.xlsx",
  sheet = "choices_JAN2017",
  col_names = TRUE
)

round2 <- read_xlsx(
  path = "PHL_2017_append_template-IN-R.xlsx",
  sheet = "choices_APR2017",
  col_names = TRUE
)

round3 <- read_xlsx(
  path = "PHL_2017_append_template-IN-R.xlsx",
  sheet = "choices_JUL2017",
  col_names = TRUE
)

round4 <- read_xlsx(
  path = "PHL_2017_append_template-IN-R.xlsx",
  sheet = "choices_OCT2017",
  col_names = TRUE
)



## bind rows, keep distinct values ----
labs <- bind_rows(round1, round2, round3, round4) %>%
  distinct(
    list_name, value,     # determine duplicates only across these two varaibles
    .keep_all = TRUE      # keep the third variable 
    )




# Write the object to iecodebook output ----
## read in xlsx for editing ----
template <- loadWorkbook("PHL_2017_append_template-IN-R.xlsx")


## write data----
writeData(
  wb = template, 
  sheet = "choices",
  x = labs, 
  xy= c(1,1),
  colNames = TRUE # the names need to be there for iecodebook to work.
  
)


## save / export workbook ----
saveWorkbook(template, 
             file = "PHL_2017_append_template-IN-S.xlsx",
             overwrite = TRUE)

