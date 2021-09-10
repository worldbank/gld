# unique_hh_ind_obs.R

library(tidyverse)

# 1. determine dir import files ----
# User to define which dta files should be analysed.
eval_directory <- ".../PHL" # replace this with top-level country directory path

# You may also chose the version of the files you want to compare for dynamic checking.
# That is, whether you want to look at all harmonized files, or only at those that are based
# on, for example, V02_M (the second version of the master data). 
version <- "v01_A"

# The default filled out below will look at all files. Unless you have knowledge of regular expressions
# it is recommended to leave this as is.
file_pattern <-  paste0("\\", version, "_GLD_ALL.dta$") 


files <- list.files(eval_directory,     
                    pattern = file_pattern, 
                    recursive = TRUE,   # search all sub folders
                    full.names = TRUE,  # list full file names
                    include.dirs = TRUE) %>% # include the full file path
  as_tibble() %>%
  rename(paths = value) %>%
  mutate(  # assume the filename is the 4-digit numeric value after the final "/"
    names = stringr::str_extract(basename(paths), "[:digit:]{4}")
  )

# key variables
variables <- c("countrycode", "year", "hhid", "pid")

# start with empty list
file_list <- list()


df <- map2(files$names, files$paths, 
           function(x, y) file_list[[x]] <<- haven::read_dta(y) %>%
             select(any_of(variables))
)


df <- bind_rows(df) 


# 2. Count obs ----

count <- df %>%
  group_by(countrycode, year) %>%
  summarise(
    n_hh = n_distinct(hhid),
    n_ind= n_distinct(pid)
  )
  

#3. save ----

save(count, file = file.path(eval_directory, "PHL_data/unique_ids_per_yr.Rdata"))
