#' Load country's latest GLD harmonizations
#' 
#' This function loads the latest GLD harmonizations for a country
#'
#' @param path_in The string (quoted) path to the folder containing all surveys
#'   of country X. 
#' @param age_min The (numeric) age minimum to be in the data. If, for example,
#'   a user wants people 15+ or 15-64, the minimum age should be set to 15.
#'   The default value is 0.
#' @param age_max The (numeric) age maximum to be the data. For interest in 
#'   interest in people up to 64 years of age (e.g., for 15-64) age_max would be
#'   set to 64. Default is 199 - biblical ages.
#' @param vars_to_study String vector of variables (or single string of variable)
#'   to be kept and later looked ate. All other variables (other than countrycode, 
#'   year, vermast, veralt, age, weight, unitwage, whours, and wage_no_compen) 
#'   are dropped if no vars to study are requested (default is NULL)

load_df <- function(
    path_in, 
    age_min = 0,
    age_max = 199,
    vars_to_study = NULL) {
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#  
  # Step 1 - Find, define paths to latest files -----------------------------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
  
  # Goal:   Create a list of path files to all the latest harmonized surveys
  
  # Need to have a list to store the paths, create
  latest_files_list <- list()
  
  # Need to establish which surveys are in the top country folder, only those that are CCC_YYYY_[Something]
  ptrn_csf <- "^[A-Z]{3}_[0-9]{4}_.+"
  survey_folders <- dir(path_in, pattern = ptrn_csf)
  
  # Loop through each survey folder (through e.g., VNM_LFS_2000, VNM_LFS_2001, ...)
  for (survey_folder in survey_folders) {
    
    # Want to know what versions stored for that survey (VNM_LFS_2000_v01_M or VNM_LFS_2000_v02_M_V03_A)
    version_folders  <- dir(glue::glue("{path_in}/{survey_folder}"))
    
    # Want to keep only amended versions (i.e., not raw data version folders)
    version_folders <- version_folders[grepl("_A_GLD$", version_folders)]
    
    # Since the order of folders in any directory is alphanumeric, 
    # because of the folder naming convention, the last in order is also the latest.
    # Want to keep only this latest folder.
    latest_folder <- version_folders[length(version_folders)]
    
    # Within that folder, want to extract the data file
    latest_file <- dir(glue::glue("{path_in}/{survey_folder}/{latest_folder}/Data/Harmonized"), full.names = T)
    
    # Want to ensure, there is but one file, tell user if not true
    if (length(latest_file) != 1) {
      stop(glue::glue("In folder {path_in}/{survey_folder}/{latest_folder}/Data/Harmonized there is more than one file"))
    }
    
    # Add to the path to this latest file to the list of paths
    # so we can go through it to load these files in Step 2
    latest_files_list[[latest_folder]] <- latest_file
    
  } # End loop through survey folders
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
  # Step 2 - Load all files, bind, output ----------------------------------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
  
  # Goal:   Go through list of Step 1, loading all files, keeping only needed, bind row-wise
  
  # In order to do things in one step, we built on the haven::read_dta function
  # Our function (i) reads, (ii) keeps the relevant vars, (iii) keeps only ages desired
  expand_read_dta <- function(path, vars_to_study, age_min, age_max) {
    
    # Read in single data set
    output <- haven::read_dta(path)
    
    # Reduce to (a) vars we always want (always_vars) and (b) vars requested by user (vars_to_study)
    always_vars <- c("countrycode", "year", "vermast", "veralt", "age", "weight", "unitwage", "whours", "wage_no_compen")
    cols_to_keep <- names(output) %in% c(vars_to_study, always_vars)
    output <- output[ , cols_to_keep]
    
    # Reduce to desired age range
    output %>% filter(age >= age_min & age <= age_max)
    
  }
  
  # Read in all files w/ our function
  # purrr::map's first element is what we will loop over, every item of it is passed
  # to the function that makes up the second element (as ".x")
  harmonized_data <- 
    purrr::map(latest_files_list, 
               ~expand_read_dta(path = .x, vars_to_study = vars_to_study, age_min = age_min, age_max = age_max)) 
  
  
  # Bind rows
  # Not assigned to any names as we want R to return this.
  # In R, a function will returns the result of the last evaluated expression
  bind_rows(harmonized_data)
  
}