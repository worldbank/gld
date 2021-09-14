# weights_per_HH.R
# assume you run main.R

library(tidyverse)


# import all surveys 
## first, use the import function 
source(file.path(code,"Global/import_surveys.R"))


## import using function
test <- import_surveys(eval_directory = PHL, vars = "weight") # this takes 15 min or so


## create a difference variable, TRUE means weight is same in each household
sum <- test %>% 
  group_by(countrycode, year, hhid) %>%
  summarize(
    wgt_dif = (n() == n_distinct(weight))
  )


## percent of households with same weight in each household
sum(sum$wgt_dif)/nrow(sum) # .428


## summary per year
sum_yr <- sum %>% 
  group_by(countrycode, year) %>% 
  summarise(
    pct_wgt_same = sum(wgt_dif)/n()
  ) 


# save 
save(test, sum, sum_yr, import_surveys,
     file = file.path(PHL, "PHL_data/GLD/weights.Rdata"))
