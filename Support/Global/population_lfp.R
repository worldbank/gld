library(tidyverse)
library(here)

# directory
here::i_am("main.R")

source(here("main.R"))
source(file.path(code, "Global/import_surveys.R"))

if (FALSE) {
  # import all surveys
  phl <- import_surveys(PHL,
                        vars = c("weight", "lstatus", "wave", "age",
                                 "industrycat_isic", "occup_isco"))
  
  # replace "" with NA
  phl <- phl %>% 
    mutate(across(.cols = c("industrycat_isic", "occup_isco"), ~ na_if(., "")))
  
  # save
  # warning! careful to not overwrite original weight file.
  if (FALSE) {
    save(phl, file = file.path(PHL, "PHL_data/GLD/population_unscaled_weights.Rdata"))
  }
}

# load data
if (TRUE) {
  load(file = file.path(PHL, "PHL_data/GLD/population_unscaled_weight.Rdata"))
}



# determine when to scale weight 
#   years 1997-2007(Q1) need to be scaled down by 10000, 
#   excpet for 2005 Q3 and 2005 Q4
sum.w.a <- phl %>%
  group_by(year, wave) %>%
  summarise(weight_median = median(weight, na.rm = TRUE),
            weight_mean   = mean(weight, na.rm = TRUE))




# create a weight-adjusted objected
phl2 <- phl %>%
  mutate(
    partic = case_when( (lstatus == 1 | lstatus == 2) ~ TRUE,
                        (lstatus == 3) ~ FALSE ),
    weight2= case_when( year <= 2004 ~ weight / 10000,
                        year == 2005 & (wave == "Q1" | wave == "Q2") ~ weight / 10000,
                        year == 2006 ~ weight / 10000,
                        year == 2007 & (wave == "Q1") ~ weight / 10000,
                        TRUE         ~ weight
          )) 

# update sum.w
weight.adj <- phl2 %>%
  group_by(year, wave) %>%
  summarise(weight_median_corrected = round(median(weight2, na.rm = TRUE)),
            weight_mean_corrected   = round(mean(weight2, na.rm = TRUE)))

sum.w <- sum.w.a %>%
  left_join(weight.adj, by = c("year", "wave")) %>%
  mutate(weight_median_corrected = weight_median_corrected,
         weight_mean_corrected   = weight_mean_corrected)



# for full population
sum.y <- phl2 %>%
  group_by(year) %>%
  summarize(
    pop = sum(weight2),
    lfp = weighted.mean(partic, weight2, na.rm = TRUE) * 100 
    )


# for ages 15 and older 
sum.15.y <- phl2 %>%
  filter(age >= 15) %>%
  group_by(year) %>%
  summarize(
    pop_15up = sum(weight2),
    lfp_15up = weighted.mean(partic, weight2, na.rm = TRUE) * 100 
    )

# add PSA data 
# Source: https://psa.gov.ph/statistics/survey/labor-and-employment/labor-force-survey
# https://psa.gov.ph/sites/default/files/attachments/hsd/pressrelease/Table%2057%20Philipine%20Concept%20vs.%20ILO%20Concept.pdf
# 
# Methodology:
#   In cases where PSA publishes singles figures for each year, those figures are used.
#   In cases where PSA does not publish figures for each year (ie, for each wave only),
#   the simple mean is used to estimate the Labor FOrce Participation; the October figure 
#   for population is used since the assumption is that it is most reflective of the final
#   year estimate for population. Note that LFP figures are recorded in descending order
#   ~ mean(Q4, Q3, Q2, Q1)
#   
#   All data use the variables that use the "ILO concept"
  
sum.15.y <- sum.15.y %>%
  mutate(
    psa_lfp_15up = case_when(
      year == "2019" ~ 61.3,
      year == "2018" ~ 60.9,
      year == "2017" ~ 61.2,
      year == "2016" ~ 63.4,
      year == "2015" ~ mean(c(63.3, 62.9, 64.6, 63.8)),
      year == "2014" ~ 64.4,
      year == "2013" ~ 63.9,
      year == "2012" ~ 64.2,
      year == "2011" ~ 64.6,
      year == "2010" ~ 64.1,
      year == "2009" ~ 64.0,
      year == "2008" ~ 63.6,
      year == "2007" ~ mean(c(63.2, 63.6, 64.5, 64.8)),
      year == "2006" ~ mean(c(63.8, 64.6, 64.8, 63.6)),
      year == "2005" ~ mean(c(64.8, 64.6, 64.8, 63.2)),
      year == "2004" ~ mean(c(63.8, 64.1, 65.4, 64.1)),
      year == "2003" ~ mean(c(64.5, 63.5, 64.0, 63.3)),
      year == "2002" ~ mean(c(63.9, 64.4, 66.3, 64.3)),
      year == "2001" ~ mean(c(62.6)), #only use Q1
      year == "2000" ~ mean(c(62.7)), #only use Q1
      year == "1999" ~ mean(c(63.1)), #only use Q1
      year == "1998" ~ mean(c(62.7)), #only use Q1
      year == "1997" ~ mean(c(63.1, 63.2, 65.5, 63.3))
    ),
    psa_pop_15up = case_when(
      year == "2019" ~ 72931000,
      year == "2018" ~ 71339000,
      year == "2017" ~ 69896000,
      year == "2016" ~ 68125000,
      year == "2015" ~ 66622000,
      year == "2014" ~ 62189000,
      year == "2013" ~ 61176000,
      year == "2012" ~ 62985000,
      year == "2011" ~ 61882000,
      year == "2010" ~ 60717000,
      year == "2009" ~ 59237000,
      year == "2008" ~ 57848000,
      year == "2007" ~ 56864000,
      year == "2006" ~ 55638000,
      year == "2005" ~ 54797000,
      year == "2004" ~ 53562000,
      year == "2003" ~ 52305000,
      year == "2002" ~ 50841000,
      year == "2001" ~ 48413000, #Q1 population data
      year == "2000" ~ 47185000, #Q1 population data
      year == "1999" ~ 45852000, #Q1 population data
      year == "1998" ~ 44517000, #Q1 population data
      year == "1997" ~ 44143000
    ),
    dif_pop_15up = pop_15up - psa_pop_15up,
    dif_lfp_15up = lfp_15up - psa_lfp_15up,
    err_pop_15up = (dif_pop_15up/pop_15up),
    err_lfp_15up = (dif_lfp_15up/lfp_15up),
    flag_pop_5pct= (err_pop_15up >= 0.05),
    flag_lfp_2pct= (err_lfp_15up >= 0.05)
  ) 

# export summary objects only
save(
  sum.15.y, sum.y, sum.w,
  file = file.path(PHL, "PHL_data/GLD/population_summary.Rdata")
)
