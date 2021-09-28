library(tidyverse)
library(magrittr)
source(file.path(code, "Global/import_surveys.R"))

phl <- import_surveys(PHL,
                      vars = c("weight", "lstatus", "wave", "age",
                               "industrycat_isic", "occup_isco"))

# replace "" with NA
phl <- phl %>% 
  mutate(across(.cols = c("industrycat_isic", "occup_isco"), ~ na_if(., "")))

if (TRUE) {
  save(phl, file = file.path(PHL, "PHL_data/GLD/population.Rdata"))
}




phl2 <- phl %>%
  mutate(
    partic = case_when( (lstatus == 1 | lstatus == 2) ~ TRUE,
                        (lstatus == 3) ~ FALSE ),
    weight2= case_when( year <= 2007 ~ weight / 10000,
                        TRUE         ~ weight
          )) 


sum.y <- phl2 %>%
  group_by(year) %>%
  summarize(pop = sum(weight2),
            lfp = weighted.mean(partic, weight2, na.rm = TRUE))

# sum.q <- phl2 %>%
#   group_by(year, wave) %>%
#   summarize(lfp = weighted.mean(partic, weight, na.rm = TRUE))


# for ages 15 and older 
sum.15.y <- phl2 %>%
  filter(age >= 15) %>%
  group_by(year) %>%
  summarize(
    pop_15up = sum(weight2),
    lfp_15up = weighted.mean(partic, weight2, na.rm = TRUE)
    )

# add PSA data 
# Source: https://psa.gov.ph/statistics/survey/labor-and-employment/labor-force-survey
# Methodology:
#   In cases where PSA publishes singles figures for each year, those figures are used.
#   In cases where PSA does not publish figures for each year (ie, for each wave only),
#   the simple mean is used to estimate the Labor FOrce Participation; the October figure 
#   for population is used since the assumption is that it is most reflective of the final
#   year estimate for population. Note that LFP figures are recorded in descending order
#   ~ mean(Q4, Q3, Q2, Q1)
#   
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
      year == "2004" ~ mean(c( , , , )),
      year == "2003" ~ mean(c( , , , )),
      year == "2002" ~ mean(c( , , , )),
      year == "2001" ~ mean(c( , , , )),
      year == "2000" ~ mean(c( , , , )),
      year == "1999" ~ mean(c( , , , )),
      year == "1998" ~ mean(c( , , , )),
      year == "1997" ~ mean(c( , , , ))
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
      year == "2004" ~ ,
      year == "2003" ~ ,
      year == "2002" ~ ,
      year == "2001" ~ ,
      year == "2000" ~ ,
      year == "1999" ~ ,
      year == "1998" ~ ,
      year == "1997" ~ 
    )
  )

# sum.15.q <- phl2 %>%
#   filter(age >= 15) %>%
#   group_by(year, wave) %>%
#   summarize(lfp_up = weighted.mean(partic, weight, na.rm = TRUE))


## merge 
# sum.y %>% 
#   left_join(sum.15.y, by = "year", na_matches = "never")
# 
# sum.q %>%
#   left_join(sum.15.q, by = c("year", "wave"), na_matches = "never")


