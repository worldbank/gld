# min_edu_labor.R
# A file to systematically identify the minimum labor and education data 
# note, this file assumes you have the metadata files preloaded
 
library(tidyverse)
library(tsibble)

load(file.path(PHL, "PHL_data/I2D2/Rdata/metadata.Rdata"))

# define function ----  
# from https://community.rstudio.com/t/passing-df-column-name-to-function/37293
min_age <- function(file, age, edu, labor) {
  # file = file path
  # age = age var 
  # edu = edu var, 
  # labor = labor var
  
  
  # import file 
  object <- readRDS(file)
  
  # find min edu age 
  min.edu <- 
    object %>%
    select({{ age }}, {{ edu }}) %>%
    filter(!is.na({{ age }}) & !is.na({{ edu }})) %>%
    summarise(min_edu   = min({{ age }}))
  
  # fine min labor age 
  min.labor <- 
    object %>%
    select({{ age }}, {{ labor }}) %>%
    filter(!is.na({{ age }}) & !is.na({{ labor }})) %>%
    summarise(min_labor   = min({{ age }}))
  
  
  # merge 
  mins <- bind_cols(min.edu, min.labor)
  
  rm(object)

  return(mins)

  
}

# function call for each year ----

files_tib <- arrange(files_tib, row_number()) # ensure same order

min97jan <- min_age(file = files_tib$rpath[1], age = age, edu = grade, labor = class) %>% mutate(year=1997, month=1)
min97apr <- min_age(file = files_tib$rpath[2], age = age, edu = grade, labor = class) %>% mutate(year=1997, month=4)
min97jun <- min_age(file = files_tib$rpath[3], age = age, edu = grade, labor = class) %>% mutate(year=1997, month=7)
min97jul <- min_age(file = files_tib$rpath[4], age = age, edu = grade, labor = class) %>% mutate(year=1997, month=10)

min98 <- min_age(file = files_tib$rpath[5], age = age, edu = grade, labor = class) %>% mutate(year=1998, month=1)

min99 <- min_age(file = files_tib$rpath[6], age = age, edu = grade, labor = class) %>% mutate(year=1999, month=1 )

min00 <- min_age(file = files_tib$rpath[7], age = age, edu = grade, labor = class) %>% mutate(year=2000, month= 1)

min01 <- min_age(file = files_tib$rpath[8], age = c05_age, edu = c07_grade, labor = c17_pclass) %>% mutate(year=2001, month=1)

min02jan <- min_age(file = files_tib$rpath[9], age = c05_age, edu = c07_grade, labor = c17_pclass) %>% mutate(year=2002, month=1)
min02apr <- min_age(file = files_tib$rpath[10], age = c05_age, edu = c07_grade, labor = c17_pclass) %>% mutate(year=2002, month=4)
min02jul <- min_age(file = files_tib$rpath[11], age = c05_age, edu = c07_grade, labor = c17_pclass) %>% mutate(year=2002, month=7)
min02oct <- min_age(file = files_tib$rpath[12], age = c05_age, edu = c07_grade, labor = c17_pclass)  %>% mutate(year=2002, month=10)

min03jan <- min_age(file = files_tib$rpath[13], age = c05_age, edu = c07_grade, labor = c17_pclass)  %>% mutate(year=2003, month=1)
min03apr <- min_age(file = files_tib$rpath[14], age = c05_age, edu = c07_grade, labor = c17_pclass)  %>% mutate(year=2003, month=4)
min03jul <- min_age(file = files_tib$rpath[15], age = cc07_age, edu = cc09_grade, labor = cc19_pclass)  %>% mutate(year=2003, month=7)
min03oct <- min_age(file = files_tib$rpath[16], age = cc07_age, edu = cc09_grade, labor = cc19_pclass) %>% mutate(year=2003, month=10)

min04jan <- min_age(file = files_tib$rpath[17], age = c07_age, edu = c09_grd, labor = c19pclas)  %>% mutate(year=2004, month=1)
min04apr <- min_age(file = files_tib$rpath[18], age = c07_age, edu = c09_grd, labor = c19pclas)  %>% mutate(year=2004, month=4)
min04jul <- min_age(file = files_tib$rpath[19], age = c07_age, edu = c09_grd, labor = c19pclas)  %>% mutate(year=2004, month=7)
min04oct <- min_age(file = files_tib$rpath[20], age = cc07_age, edu = cc09_grade, labor = cc19_pclass) %>% mutate(year=2004, month=10)

min05jan <- min_age(file = files_tib$rpath[21], age = c07_age, edu = c09_grd, labor = c19pclas)  %>% mutate(year=2005, month=1)
min05apr <- min_age(file = files_tib$rpath[22], age = c07_age, edu = c09_grd, labor = c19pclas)  %>% mutate(year=2005, month=4)
min05jul <- min_age(file = files_tib$rpath[23], age = c07_age, edu = c09_grd, labor = c19pclas)  %>% mutate(year=2005, month=7)
min05oct <- min_age(file = files_tib$rpath[24], age = c07_age, edu = c09_grade, labor = c24_pclass) %>% mutate(year=2005, month=10)

min06jan <- min_age(file = files_tib$rpath[25], age = c07_age, edu = c09_grade, labor = c24_pclass)  %>% mutate(year=2006, month=1)
min06apr <- min_age(file = files_tib$rpath[26], age = c07_age, edu = c09_grade, labor = c24_pclass)  %>% mutate(year=2006, month=4)
min06jul <- min_age(file = files_tib$rpath[27], age = cc07_age, edu = cc09_grade, labor = cc19_pclass)  %>% mutate(year=2006, month=7)
min06oct <- min_age(file = files_tib$rpath[28], age = cc07_age, edu = cc09_grade, labor = cc19_pclass) %>% mutate(year=2006, month=10)

min07jan <- min_age(file = files_tib$rpath[30], age = lc07_age, edu = lc09_grade, labor = lc24_pclass)  %>% mutate(year=2007, month=1)
min07apr <- min_age(file = files_tib$rpath[29], age = c07_age, edu = c09_grd, labor = c19pclas)  %>% mutate(year=2007, month=4)
min07jul <- min_age(file = files_tib$rpath[31], age = c07_age, edu = c09_grd, labor = c19pclas)  %>% mutate(year=2007, month=7)
min07oct <- min_age(file = files_tib$rpath[32], age = c07_age, edu = c09_grd, labor = c19pclas) %>% mutate(year=2007, month=10)

min08jan <- min_age(file = files_tib$rpath[34], age = c07_age, edu = c09_grd, labor = c19pclas)  %>% mutate(year=2008, month=1)
min08apr <- min_age(file = files_tib$rpath[33], age = c07_age, edu = c09_grd, labor = c19pclas)  %>% mutate(year=2008, month=4)
min08jul <- min_age(file = files_tib$rpath[35], age = c07_age, edu = c09_grd, labor = c19pclas)  %>% mutate(year=2008, month=7)
min08oct <- min_age(file = files_tib$rpath[36], age = c07_age, edu = c09_grd, labor = c19pclas) %>% mutate(year=2008, month=10)

min09jan <- min_age(file = files_tib$rpath[38], age = c07_age, edu = c09_grd, labor = c19pclas)  %>% mutate(year=2009, month=1)
min09apr <- min_age(file = files_tib$rpath[37], age = c07_age, edu = c09_grd, labor = c19pclas)  %>% mutate(year=2009, month=4)
min09jul <- min_age(file = files_tib$rpath[39], age = c07_age, edu = c09_grd, labor = c19pclas)  %>% mutate(year=2009, month=7)
min09oct <- min_age(file = files_tib$rpath[40], age = c07_age, edu = c09_grd, labor = c19pclas) %>% mutate(year=2009, month=10)

min10jan <- min_age(file = files_tib$rpath[42], age = c07_age, edu = c09_grd, labor = c19pclas)  %>% mutate(year=2010, month=1)
min10apr <- min_age(file = files_tib$rpath[41], age = c07_age, edu = c09_grd, labor = c19pclas)  %>% mutate(year=2010, month=4)
min10jul <- min_age(file = files_tib$rpath[43], age = c07_age, edu = c09_grd, labor = c19pclas)  %>% mutate(year=2010, month=7)
min10oct <- min_age(file = files_tib$rpath[44], age = c07_age, edu = c09_grd, labor = c19pclas) %>% mutate(year=2010, month=10)

min11jan <- min_age(file = files_tib$rpath[46], age = c07_age, edu = c09_grd, labor = c19pclas)  %>% mutate(year=2011, month=1)
min11apr <- min_age(file = files_tib$rpath[45], age = c07_age, edu = c09_grd, labor = c19pclas)  %>% mutate(year=2011, month=4)
min11jul <- min_age(file = files_tib$rpath[47], age = c07_age, edu = c09_grd, labor = c19pclas)  %>% mutate(year=2011, month=7)
min11oct <- min_age(file = files_tib$rpath[48], age = c07_age, edu = c09_grd, labor = c19pclas) %>% mutate(year=2011, month=10)

min12jan <- min_age(file = files_tib$rpath[51], age = c07_age, edu = j12c09_grade, labor = c19_pclass)  %>% mutate(year=2012, month=1)
min12apr <- min_age(file = files_tib$rpath[50], age = c07_age, edu = j12c09_grade, labor = c19_pclass)  %>% mutate(year=2012, month=4)
min12jul <- min_age(file = files_tib$rpath[52], age = c07_age, edu = j12c09_grade, labor = c19_pclass)  %>% mutate(year=2012, month=7)
min12oct <- min_age(file = files_tib$rpath[49], age = c07_age, edu = j12c09_grade, labor = c19_pclass) %>% mutate(year=2012, month=10)

min13jan <- min_age(file = files_tib$rpath[55], age = c07_age, edu = j12c09_grade, labor = c19_pclass)  %>% mutate(year=2013, month=1)
min13apr <- min_age(file = files_tib$rpath[54], age = c07_age, edu = j12c09_grade, labor = c19_pclass)  %>% mutate(year=2013, month=4)
min13jul <- min_age(file = files_tib$rpath[56], age = c07_age, edu = j12c09_grade, labor = c19_pclass)  %>% mutate(year=2013, month=7)
min13oct <- min_age(file = files_tib$rpath[53], age = c07_age, edu = j12c09_grade, labor = c19_pclass) %>% mutate(year=2013, month=10)

min14jan <- min_age(file = files_tib$rpath[58], age = c07_age, edu = j12c09_grade, labor = c19pclas)  %>% mutate(year=2014, month=1)
min14apr <- min_age(file = files_tib$rpath[57], age = c07_age, edu = j12c09_grade, labor = c19pclas)  %>% mutate(year=2014, month=4)
min14jul <- min_age(file = files_tib$rpath[59], age = c07_age, edu = j12c09_grade, labor = c19pclas)  %>% mutate(year=2014, month=7)
min14oct <- min_age(file = files_tib$rpath[60], age = c07_age, edu = j12c09_grade, labor = c19pclas) %>% mutate(year=2014, month=10)

min15jan <- min_age(file = files_tib$rpath[62], age = c07_age, edu = j12c09_grade, labor = c19pclas)  %>% mutate(year=2015, month=1)
min15apr <- min_age(file = files_tib$rpath[61], age = c07_age, edu = j12c09_grade, labor = c19pclas)  %>% mutate(year=2015, month=4)
min15jul <- min_age(file = files_tib$rpath[63], age = c07_age, edu = j12c09_grade, labor = c19pclas)  %>% mutate(year=2015, month=7)
min15oct <- min_age(file = files_tib$rpath[64], age = c07_age, edu = j12c09_grade, labor = c19pclas) %>% mutate(year=2015, month=10)

min16jan <- min_age(file = files_tib$rpath[66], age = c07_age, edu = j12c09_grade, labor = c19pclas)  %>% mutate(year=2016, month=1)
min16apr <- min_age(file = files_tib$rpath[65], age = pufc05_age, edu = pufc07_grade, labor = pufc23_pclass)  %>% mutate(year=2016, month=4)
min16jul <- min_age(file = files_tib$rpath[67], age = pufc05_age, edu = pufc07_grade, labor = pufc23_pclass)  %>% mutate(year=2016, month=7)
min16oct <- min_age(file = files_tib$rpath[68], age = pufc05_age, edu = pufc07_grade, labor = pufc23_pclass) %>% mutate(year=2016, month=10)

min17jan <- min_age(file = files_tib$rpath[70], age = pufc05_age, edu = pufc07_grade, labor = pufc23_pclass)  %>% mutate(year=2017, month=1)
min17apr <- min_age(file = files_tib$rpath[69], age = lc05_age, edu = lc07_grade, labor = lc23_pclass)  %>% mutate(year=2017, month=4)
min17jul <- min_age(file = files_tib$rpath[71], age = pufc05_age, edu = pufc07_grade, labor = pufc23_pclass)  %>% mutate(year=2017, month=7)
min17oct <- min_age(file = files_tib$rpath[72], age = pufc05_age, edu = pufc07_grade, labor = pufc23_pclass) %>% mutate(year=2017, month=10)

min18jan <- min_age(file = files_tib$rpath[74], age = pufc05_age, edu = pufc07_grade, labor = pufc23_pclass)  %>% mutate(year=2018, month=1)
min18apr <- min_age(file = files_tib$rpath[73], age = pufc05_age, edu = pufc07_grade, labor = pufc23_pclass)  %>% mutate(year=2018, month=4)
min18jul <- min_age(file = files_tib$rpath[75], age = pufc05_age, edu = pufc07_grade, labor = pufc23_pclass)  %>% mutate(year=2018, month=7)
min18oct <- min_age(file = files_tib$rpath[76], age = pufc05_age, edu = pufc07_grade, labor = pufc23_pclass) %>% mutate(year=2018, month=10)

min19jan <- min_age(file = files_tib$rpath[78], age = pufc05_age, edu = pufc07_grade, labor = pufc23_pclass)  %>% mutate(year=2019, month=1)
min19apr <- min_age(file = files_tib$rpath[77], age = pufc05_age, edu = pufc07_grade, labor = pufc23_pclass)  %>% mutate(year=2019, month=4)
min19jul <- min_age(file = files_tib$rpath[79], age = pufc05_age, edu = pufc07_grade, labor = pufc23_pclass)  %>% mutate(year=2019, month=7)
min19oct <- min_age(file = files_tib$rpath[80], age = pufc05_age, edu = pufc07_grade, labor = pufc23_pclass) %>% mutate(year=2019, month=10)

min20jan <- min_age(file = files_tib$rpath[82], age = pufc05_age, edu = pufc07_grade, labor = pufc23_pclass)  %>% mutate(year=2020, month=1)
min20apr <- min_age(file = files_tib$rpath[81], age = pufc05_age, edu = pufc07_grade, labor = pufc23_pclass)  %>% mutate(year=2020, month=4)
min20jul <- min_age(file = files_tib$rpath[83], age = pufc05_age, edu = pufc07_grade, labor = pufc23_pclass)  %>% mutate(year=2020, month=7)




# append ----

## make list of objects to append
tibs <- Filter(function(x) is(x, "data.frame"), mget(ls()[grepl('min', ls())]))

## ensure that number of objects to append == number of waves
assertthat::assert_that(length(tibs) == nrow(documented_waves))

## call function to append
age_min <- do.call(rbind, tibs) %>%
  rownames_to_column("id") %>%
  arrange(year, month)

## make into tsibble 
age_ts <- age_min %>%
  mutate(ym = paste(year, month),
         yearmo = yearmonth(ym)) %>%
  as_tsibble(index = yearmo)


# edit and graph ----

a = 0.3
gg_age <- ggplot(age_ts) +
  geom_point(aes(yearmo, min_edu), color = 'blue', alpha = a, size = 2) +
  geom_point(aes(yearmo, min_labor), color = 'red', alpha = a, size = 2) +
  scale_y_continuous(limits = c(0,20)) +
  scale_x_yearmonth(breaks = "1 year") + 
  guides(colour = "legend") +
  labs(x = "Year - Month", y = "Min. Age for Edu/Labor Module",
    title="Age minimums in data across rounds and years", 
    subtitle="Education data in blue, labor data in orange, overlap in purple") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust=0.5, hjust=1))
gg_age


save(gg_age, age_ts, tibs,
     file = file.path(PHL, "PHL_data/I2D2/Rdata/min_age.Rdata"))
