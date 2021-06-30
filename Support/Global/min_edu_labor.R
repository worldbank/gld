# min_edu_labor.R
# A file to systematically identify the minimum labor and education data 
# note, this file assumes you have the metadata files preloaded

library(tidyverse)


jan97 <- readRDS(files_tib$rpath[1])

min(jan97$age[!is.na(jan97$grade)])
min(jan97$age[!is.na(jan97$class)])

jan97 %>%
  select(age, grade) %>%
  filter(!is.na(age) & !is.na(grade)) %>%
  summarise(min_edu   = min(age))
  

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


min97jan <- min_age(file = files_tib$rpath[1], age = age, edu = grade, labor = class)

