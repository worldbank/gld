# zwe_edu_attain.R
# determines highest education level attained in ZWE 

library(tidyverse)
library(forcats)
library(summarytools)

# opening ----
here::i_am("main.R")
source("main.R")

load(ZWE_sum)


# create parsimonious edu hierarchy ----

edu <- hl %>%
  select(contains("ED")) 

# here are the gld labels and levels for reference
# 
#   1 "No education" ///
#   2 "Primary incomplete" ///
#   3 "Primary complete" ///
#   4 "Secondary incomplete" ///
#   5 "Secondary complete" ///
#   6 "Higher than secondary but not university" ///
#   7 "University incomplete or complete"
#   
#   Assumption for years of school:
#   Primary: 6
#   Lower Secondary: 4
#   Upper Secondary: 2


# ahh, need to include ED5 for completion
edu.lvls <- edu %>%
  select("ED4A", "ED4B", "ED5") %>%
  mutate(complete = (ED5 == 1)) %>% # make a boolean variable for completed grade level
  group_by(ED4A, ED4B, complete) %>%
  summarise(count = n()) %>%
  # note that these labels are taken directly from the .dta labels, they differ 
  # slightly from the codebook.
  mutate(
    type = case_when(
      ED4A == 0 ~ "Early Childhood Education",
      ED4A == 1 ~ "Primary",
      ED4A == 2 ~ "Other Primary",
      ED4A == 3 ~ "Lower Secondary",
      ED4A == 4 ~ "Upper Secondary",
      ED4A == 5 ~ "Tertiary"),
    attend_educat7 = case_when(
      type == "Early Childhood Education"  ~ 2,
      type == "Primary" & ED4B < 6         ~ 2,
      type == "Primary" & ED4B >= 6        ~ 3,
      type == "Other Primary" & ED4B < 6   ~ 2,
      type == "Other Primary" & ED4B >= 6  ~ 3,
      type == "Lower Secondary"            ~ 4, # any lower secondary = incomplete secondary
      type == "Upper Secondary" & ED4B < 2 ~ 4,
      type == "Upper Secondary" & ED4B >= 2~ 5,
      type == "Tertiary"                   ~ 7), # no vocational school data recorded.
    attain_educat7 = case_when(
      complete == TRUE                     ~ attend_educat7,
      complete == FALSE                    ~ case_when(
        type == "Early Childhood Education" ~ 2, # always is primary incomplete,
        type == "Primary"                  ~ 2,
        type == "Other Primary"             ~ 2, 
        type == "Lower Secondary"           ~ 4, # then you attended secondary for at least 1 day
        type == "Upper Secondary"           ~ 4, # then you attended secondary for at least 1 day
        type == "Tertiary"                  ~ 7)) # this level doesn't care about completion
  )
  
# when complete == TRUE, then attain == attend. But if compete == FALSE, then we must 
# infer that the highest attained is 1 level below where currently attending.

save(
  edu.lvls,
  file = file.path(ZWE, "ZWE_data/GLD/Rdata/education_attain_educat7.Rdata")
)

haven::write_dta(edu.lvls, 
                 path = file.path(ZWE, "ZWE_2019_LFS/ZWE_2019_LFS_v01_M/Data/Stata/ZWE_key_educat7.dta"))
