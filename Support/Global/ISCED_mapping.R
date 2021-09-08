# ISCED_mapping.R
# This assume you have run main.R with renv loaded 

# Startup ----

library(tidyverse)

# load functions 
load(PHL_meta) # for metadata
source(file.path(code, "Global/valtab.R")) # function



# Tables for each ISCED Group ----

# global edu tabulation 
edu <- valtab(metadata = metadata, x = "highest grade", param = label_orig)



# for each schema

psced97 <- metadata %>%
  filter(grepl("1997", id) | grepl("1998", id) | grepl("1999", id) | 
         grepl("2000", id) | grepl("2001", id) | grepl("2002", id) | 
         grepl("2003", id) | grepl("2004", id) | grepl("2005", id) | 
         grepl("2006", id) | grepl("2007", id) | grepl("2008", id) | 
         grepl("2009", id) | grepl("2010", id) | grepl("2011", id)) %>%
  valtab(metadata = ., x = "highest grade", y = NULL, param = label_orig)


psced08 <- metadata %>%
  filter(grepl("2012", id) | grepl("2013", id) | grepl("2014", id) | 
           grepl("2015", id) | grepl("2016", id) | grepl("2017", id) | 
           grepl("2018", id)) %>%
  valtab(metadata = ., x = "highest grade", y = NULL, param = label_orig)


psced17 <- metadata %>%
  filter(grepl("2019", id)) %>%
  valtab(metadata = ., x = "highest grade", y = NULL, param = label_orig)


# conclusion: the values differ so much even within each schema that a single "key" for each 
# schema probably doesn't make sense.

# save ----

save(
  edu, psced97, psced08, psced17, metadata, valtab,
  file = file.path(PHL, "PHL_data/isced.Rdata")
)
