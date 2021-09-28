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


#check isic and isco
sum(!is.na(phl$industrycat_isic))/nrow(phl) # 0.3520979 of cases are non missing
sum(!is.na(phl$occup_isco))/nrow(phl) # 0.3465874 of cases are nonmissing

sum.isic.isco <- phl %>%
  group_by(year) %>%
  summarize(industry_pct = sum(!is.na(industrycat_isic))/n(),
            occup_pct    = sum(!is.na(occup_isco))/n())


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
sum.15.y <- sum.15.y %>%
  mutate(
    psa_lfp_15up = case_when(
      year == "2019" ~ 61.3,
      year == "2018" ~ 60.9,
      year == "2017" ~ 61.2,
      year == "2016" ~ 63.4,
      year == "2015" ~ mean(),
      year == "2014" ~ 64.4,
      year == "2013" ~ 63.9,
      year == "2012" ~ 64.2,
      year == "2011" ~ 64.6,
      year == "2010" ~ 64.1,
      year == "2009" ~ 64.0,
      year == "2008" ~ 63.6,
      year == "2007" ~ ,
      year == "2006" ~ ,
      year == "2005" ~ ,
      year == "2004" ~ ,
      year == "2003" ~ ,
      year == "2002" ~ ,
      year == "2001" ~ ,
      year == "2000" ~ ,
      year == "1999" ~ ,
      year == "1998" ~ ,
      year == "1997" ~ 
    ),
    psa_pop_15up = case_when(
      year == "2019" ~ 72931000,
      year == "2018" ~ 71339000,
      year == "2017" ~ 69896000,
      year == "2016" ~ 68125000,
      year == "2015" ~ ,
      year == "2014" ~ 62189000,
      year == "2013" ~ 61176000,
      year == "2012" ~ 62985000,
      year == "2011" ~ 61882000,
      year == "2010" ~ 60717000,
      year == "2009" ~ 59237000,
      year == "2008" ~ 57848000,
      year == "2007" ~ ,
      year == "2006" ~ ,
      year == "2005" ~ ,
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


