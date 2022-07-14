#' imports all surveys in a given directory; returns an appended dataframe of all years
#' @param eval_directory the top level directory folder 
#' @param vars additional quoted variables to be included beyond standard survey identifiers
#' @param version a quoted expression that indicates the file version to import 
#' @param file_pattern a quoted regex expression to match file patterns in the directory

import_surveys <- function(eval_directory, 
                           vars = NULL,
                           version = "v01_A",
                           file_pattern = paste0("\\", version, "_GLD_ALL.dta$")
                           ) {
  
  
  
  files <- list.files(eval_directory,     
                      pattern = file_pattern, 
                      recursive = TRUE,   # search all sub folders
                      full.names = TRUE,  # list full file names
                      include.dirs = TRUE) %>% # include the full file path
    as_tibble() %>%
    rename(paths = value) %>%
    mutate(  
      # assume the filename is the 4-digit numeric value after the final "/"
      names = stringr::str_extract(basename(paths), "[:digit:]{4}")
    )
  
  # key variables
  variables <- c("countrycode", "year", "hhid", "pid")
  if (!is.null(vars)) {
    variables <- c(variables, vars)
  }
  
  # start with empty list
  file_list <- list()
  
  
  df <- map2(files$names, files$paths, 
             function(x, y) file_list[[x]] <<- haven::read_dta(y) %>%
               select(any_of(variables))
  )
  
  
  df <- bind_rows(df) 
  
  return(df)
}
