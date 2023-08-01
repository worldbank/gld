# weights_per_HH.R
# assume you run main.R

library(tidyverse)
library(survey)


# import all surveys 
## first, use the import function 
source(file.path(code,"Global/import_surveys.R"))

## maybe, load data
if (TRUE) {load(file.path(PHL, "PHL_data/GLD/weights.Rdata"))}
  

## import using function
test <- import_surveys(eval_directory = PHL, vars = "weight") # this takes 15 min or so
#test <- test %>% filter(!is.na(weight))

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

sum_pop <- test %>%
  ungroup() %>%
  mutate(one = 1) %>%
  group_by(countrycode, year) %>%
  summarise(
    one          = mean(one),
    population   = weighted.mean(one, weight)
  ) %>%
  select(-one)


phl97 <- test %>% filter(year == 1997) %>% mutate(one = 1)

weighted.mean(phl97$one, phl97$weight)

## expanded population 

svy <- svydesign(ids = ~countrycode + year + hhid + pid ,
                 weights = ~weight, 
                 data = test) ## wont' run, missing values in weights?

summary(svy)


# save 
save(test, sum, sum_yr, import_surveys,
     file = file.path(PHL, "PHL_data/GLD/weights.Rdata"))
