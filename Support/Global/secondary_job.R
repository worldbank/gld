# secondary job check

library(tidyverse)

# source main 
here::i_am("main.R")
source("main.R")
source(file.path(code, "Global/import_surveys.R"))

phl <- import_surveys(PHL,
                      vars = c("weight", "lstatus", "wave", "age",
                              "industrycat10", "industrycat10_2",
                              "occup", "occup_2"))

sum.nonmiss <- phl %>% 
  group_by(year) %>%
  summarize(across(c("industrycat10", "industrycat10_2","occup", "occup_2"),
                   ~ round((sum(!is.na(.x))/n() * 100), 1), .names = "pctNonMiss_{.col}" ))

            
sum.nonmiss.qtr <- phl %>% 
  group_by(year, wave) %>%
  summarize(across(c("industrycat10", "industrycat10_2","occup", "occup_2"),
                   ~ round((sum(!is.na(.x))/n() * 100), 1), .names = "pctNonMiss_{.col}" ))


save(
  sum.nonmiss, sum.nonmiss.qtr,
  file = file.path(PHL, "PHL_data/GLD/secondary_job.Rdata")
)
