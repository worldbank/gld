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
data <- psic09_data[[47]] %>%
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

# how many distinct values of x are there 
n_distinct(data$x) # 127. makes sense, counts each word in text field

# what if we exclude the label field?
# I guess we have to filter by manually figuring out the 
# x position where the labels are?
data_nolabs <- data %>%
  filter(x < 155 | x > 430)

n_distinct(data_nolabs$x) # 17 distinct "columns" or x positions.


data_tib <- data_nolabs %>%
  filter(y > 100) %>% # remove page titles
  select(x, y, text) %>%
  group_by(x) %>%
  mutate(count = n(),
         x_grp = cur_group_id(),
         group = cur_group_id()) %>%
  pivot_wider(names_from = "group",
              names_prefix= "var",
              values_from = "text") %>%
  rename("group" = "var1",
         "class" = "var2",
         "subclass" = "var3",
         "psic1994" = "var4",
         "isic4" = "var5",
         "acic" = "var6") %>%
  select(x, y, x_grp,
         group, class, subclass, psic1994, isic4, acic) %>%
  arrange(y)

# almost there, but we need to vertically collapse. there are different
# x groups that have the same y value that should all be in the same row

sum <- data_tib %>% 
  ungroup() %>%
  group_by(y) %>%
  summarize(
    group = group[which(!is.na(group))[1]],
    class = class[which(!is.na(class))[1]],
    subclass = subclass[which(!is.na(subclass))[1]],
    psic1994 = psic1994[which(!is.na(psic1994))[1]],
    isic4 = isic4[which(!is.na(isic4))[1]],
    acic = acic[which(!is.na(acic))[1]]
  ) 
