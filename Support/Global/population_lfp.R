library(tidyverse)
library(magrittr)
source(file.path(code, "Global/import_surveys.R"))

# sample df 
df <- haven::read_dta(file.path(PHL, 
                                "PHL_2018_LFS/PHL_2018_LFS_v01_M_v01_A_GLD/Data/Harmonized/PHL_2018_LFS_v01_M_v01_A_GLD_ALL.dta"))

phl <- import_surveys(PHL, vars = c("weight", "lstatus", "wave", "age"))

if (TRUE) {
  save(phl, file = file.path(PHL, "PHL_data/GLD/population.Rdata"))
}

phl2 <- phl %>%
  mutate(
    partic = case_when( (lstatus == 1 | lstatus == 2) ~ TRUE,
                        (lstatus == 3) ~ FALSE )) 


sum.y <- phl2 %>%
  group_by(year) %>%
  summarize(pop = sum(weight),
            lfp = weighted.mean(partic, weight, na.rm = TRUE))

sum.q <- phl2 %>%
  group_by(year, wave) %>%
  summarize(lfp = weighted.mean(partic, weight, na.rm = TRUE))


# for ages 15 and older 
sum.15.y <- phl2 %>%
  filter(age >= 15) %>%
  group_by(year) %>%
  summarize(lfp_15up = weighted.mean(partic, weight, na.rm = TRUE))

sum.15.q <- phl2 %>%
  filter(age >= 15) %>%
  group_by(year, wave) %>%
  summarize(lfp_up = weighted.mean(partic, weight, na.rm = TRUE))


## merge 
sum.y %>% 
  left_join(sum.15.y, by = "year", na_matches = "never")

sum.q %>%
  left_join(sum.15.q, by = c("year", "wave"), na_matches = "never")



# expanded population 
## total
pop <- sum(df$weight)
## age 15 and above
pop.15 <- df %>%
  filter(age >= 15) %>%
  pull(weight) %>%
  sum

# labor force participation 
df <- df %>% 
  mutate(
    partic = case_when( (lstatus == 1 | lstatus == 2) ~ TRUE,
                        (lstatus == 3) ~ FALSE )) 
lfp <-  weighted.mean(df$partic, w = df$weight, na.rm = TRUE)
