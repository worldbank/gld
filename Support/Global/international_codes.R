# international_codes.R
# matches isic, isco, isced codes to PHL LFS survey data
# 
# 
# This script assumes you've run main.R first 
# 
# The main purpose of this script is to match isic (industry), 
# isco (occupation) and isced (education) codes to produce 
# either 
#   - tables, or 
#   - easily-writable in-script code that covnerts the raw data to ISIC/ISCO etc 
# 
# Most of the findings here will be docuements in "Industry_Occupation Codes.md" in 
# the "Country Survey Details" Folder for the Philippines

library(tidyverse)
library(stringr)
library(pdftools)



# load network data
load(PHL_meta)
load(PHL_labels)

# pdf file path
psic_path <- file.path(PHL, "PHL_docs/International Codes/PSA_PSIC_2009.pdf")





              ##### ISIC ####

# Import ISIC 3.0 data --------------------------------- 
# we know that only years 1997 - 2011 use this
UNisic3 <- read_delim(file = file.path(PHL, "PHL_data/GLD/international_codes/ISIC_Rev_3_english_structure.txt"))


# pdf import 
psic09_info <- pdf_info(psic_path)
psic09_data <- pdf_data(psic_path)
psic09_toc  <- pdf_toc(psic_path)
psic09_text <- pdf_text(psic_path)

# use page 47 as an example page 
data <- psic09_data[[32]] %>%
  arrange()


# align data ----
#   
#   we want to take the information that should go 
#   in the same "row" in a tibble that is contained in the
#   same "row" in the pdf. But "row" is quote because the
#   information isn't always at the same y position on the page
#   
#   Assumptions:
#     1. text values with same x value should be in the same column
#     2. text values with same y value should be in the same row
#       2a. sub-groups will refer will have empty values for "sub-class"
#           or "group" but should pull from the previous non-missing value
#     3. 

# what if we exclude the label field?
# I guess we have to filter by manually figuring out the 
# x position where the labels are?
final_vars <- c("y", "group", "class", "subclass", "psic1994", "isic4", "acic")

data_nolabs <- data %>%
  filter(x < 155 | x > 420) %>%
  mutate(str = str_detect(text, "[:alpha:]+$")) %>%
  filter(str == FALSE)

x_min <- min(data_nolabs$x)

data_tib <- data_nolabs %>%
  filter(y >= 98) %>% # remove page titles, if no data, no obs.
  select(x, y, text) %>%
  # manually generate group by range of x position,
  # assuming x is fixed 
  mutate(
    group = case_when(
      x < 90             ~ 1, # group
      x >=91  & x < 130  ~ 2, # class
      x >=131 & x < 175  ~ 3, # subclass
      x >=415 & x < 445  ~ 4, # psic1994
      x >=446 & x < 500  ~ 5, # isic4
      x >=501            ~ 6  # acic
    )
  ) %>%
  group_by(group) %>%
  mutate(count = n(),
         #x_grp = cur_group_id(),
         group = cur_group_id()) %>%
  arrange(group) %>%
  pivot_wider(names_from = "group",
              names_prefix= "var",
              values_from = "text") 
# if x_min < 90, then there will only be 5 variables, 
# so generate an empty variable for "group". This means there
# was no "group" data on the page and every variable number is
# shifted down 1/

if (x_min > 89) {
  data_tib2 <- data_tib %>%
    mutate(var0 = NA_character_) %>%
    rename_with(matches("var0"), .fn = ~paste0("group")) %>%
    rename_with(matches("var1"), .fn = ~tolower("class")) %>%
    rename_with(matches("var2"), .fn = ~paste0("subclass")) %>%
    rename_with(matches("var3"), .fn = ~paste0("psic1994")) %>%
    rename_with(matches("var4"), .fn = ~paste0("isic4")) %>%
    rename_with(matches("var5"), .fn = ~paste0("acic")) %>%
    select(x, y, any_of(final_vars)) %>%
    arrange(y)
} else {
  data_tib2 <- data_tib %>%
    rename_with(matches("var1"), .fn = ~paste0("group")) %>%
    rename_with(matches("var2"), .fn = ~tolower("class")) %>%
    rename_with(matches("var3"), .fn = ~paste0("subclass")) %>%
    rename_with(matches("var4"), .fn = ~paste0("psic1994")) %>%
    rename_with(matches("var5"), .fn = ~paste0("isic4")) %>%
    rename_with(matches("var6"), .fn = ~paste0("acic")) %>%
    select(x, y, any_of(final_vars)) %>%
    arrange(y)
    
}
  
# generate empty variables if NA
names_data_tib2 <- names(data_tib2)

data_tib3 <- add_column(data_tib2, !!!cols[setdiff(final_vars, names(data_tib2))])

sum <- data_tib3 %>% 
  ungroup() %>%
  group_by(y) 
  summarize(
    group = if_else(is.na(data_tib3$group), NA_character_, group[which(!is.na(group))[1]]),
    class = class[which(!is.na(class))[1]],
    subclass = subclass[which(!is.na(subclass))[1]],
    psic1994 = psic1994[which(!is.na(psic1994))[1]],
    isic4 = isic4[which(!is.na(isic4))[1]],
    acic = acic[which(!is.na(acic))[1]]
  ) %>%
  mutate(
    class = case_when(is.na(class) ~ replace_na(stringr::str_sub(subclass, 1,3)),
                      TRUE ~ class),
    group = case_when(is.na(group) ~ replace_na(stringr::str_sub(class, 1,3)),
                           TRUE ~ group))

# here group is missing, but we know that group is just 
# the first three digits of class


# function ----
read_pdf <- function(page) {
  
  data_nolabs <- page %>%
    filter(x < 155 | x > 420) %>%
    mutate(str = str_detect(text, "[:alpha:]+$")) %>%
    filter(str == FALSE)
  
  
  x_min <- min(data_nolabs$x)
  
  
  
  # if the page is "blank" in terms of table data, return nothing
  if (nrow(data_nolabs) == 0) {
    return(NULL)
  
    } else {
    
      data_tib <- data_nolabs %>%
        filter(y >= 98) %>% # remove page titles, if no data, no obs.
        select(x, y, text) %>%
        # manually generate group by range of x position,
        # assuming x is fixed 
        mutate(
          group = case_when(
            x < 90             ~ 1, # group
            x >=91  & x < 130  ~ 2, # class
            x >=131 & x < 175  ~ 3, # subclass
            x >=415 & x < 445  ~ 4, # psic1994
            x >=446 & x < 500  ~ 5, # isic4
            x >=501            ~ 6  # acic
          )
        ) %>%
        group_by(group) %>%
        mutate(count = n(),
               #x_grp = cur_group_id(),
               group = cur_group_id()) %>%
        arrange(group) %>%
        pivot_wider(names_from = "group",
                    names_prefix= "var",
                    values_from = "text") 
      # if x_min < 90, then there will only be 5 variables, 
      # so generate an empty variable for "group". This means there
      # was no "group" data on the page.
      
      if (x_min > 89) {
        data_tib2 <- data_tib %>%
          mutate(var0 = NA_character_) %>%
          rename("group" = "var0",
                 "class" = "var1",
                 "subclass" = "var2",
                 "psic1994" = "var3",
                 "isic4" = "var4",
                 "acic" = "var5") %>%
          select(x, y,
                 group, class, subclass, psic1994, isic4, acic) %>%
          arrange(y)
      } else {
        data_tib2 <- data_tib %>%
          rename("group" = "var1",
                 "class" = "var2",
                 "subclass" = "var3",
                 "psic1994" = "var4",
                 "isic4" = "var5",
                 "acic" = "var6") %>%
          select(x, y,
                 group, class, subclass, psic1994, isic4, acic) %>%
          arrange(y)
        
      }
    
    # almost there, but we need to vertically collapse. there are different
    # x groups that have the same y value that should all be in the same row
    
    sum <- data_tib2 %>% 
      ungroup() %>%
      group_by(y) %>%
      summarize(
        group = group[which(!is.na(group))[1]],
        class = class[which(!is.na(class))[1]],
        subclass = subclass[which(!is.na(subclass))[1]],
        psic1994 = psic1994[which(!is.na(psic1994))[1]],
        isic4 = isic4[which(!is.na(isic4))[1]],
        acic = acic[which(!is.na(acic))[1]]
      ) %>%
      mutate(
        class = case_when(is.na(class) ~ replace_na(stringr::str_sub(subclass, 1,3)),
                          TRUE ~ class),
        group = case_when(is.na(group) ~ replace_na(stringr::str_sub(class, 1,3)),
                          TRUE ~ group))
    
    
    return(sum)
    
  }  
  
}


test <- lapply(psic09_data[22:316], read_pdf)

read_pdf(psic09_data[[31]])
