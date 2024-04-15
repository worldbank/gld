#' Make wage time-series 
#' 
#' This function creates a DF with wage distribution over time from GLD surveys.
#'
#' @param df The data frame to be used (a GLD harmonized dataset)
#' @param wage_emp Binary indicator of whether the data should be
#'   reduced only to the wage-employed (default is TRUE)
#' @param drop_zeroes Binary indicator of whether the data should 
#'   drop cases when wage or whours are 0 (default is TRUE)
#' @param group String variable name for additional grouping variable.
#'   Default is to not add any (NULL).
#' @param country The ISO alpha 3 country code we are looking at.

make_wage_ts <- function(
  df, 
  wage_emp = TRUE, 
  drop_zeroes = TRUE,
  group = NULL,
  country) {
  
  #=========================================================================#
  # Step 1 - Reduce inputted DF to right form -------------------------------
  #=========================================================================#
  
  # A - Reduce data frame to relevant info
  
  # A1) Keep only employed, avoid those w/o wage
  df <- df %>% filter(as.numeric(lstatus)== 1 & as.numeric(empstat) != 2)
  
  # A2) Keep only those with information to make data
  df <- df %>% filter(!is.na(wage_no_compen) & 
                        !is.na(unitwage) & 
                        !is.na(weight) & 
                        !is.na(whours))
  
  # A3) Drop cases of unitwage 10, which exists as option, but cannot work with
  df <- df %>% filter(unitwage != 10)
  
  
  # B - Reduce data frame based on user input
  
  # B1 - Keep only wage employed if requested
  if (wage_emp) {
    df <- df %>% filter(as.numeric(empstat) == 1)
  }
  
  # B2 - Drop zeroes if requested
  if (drop_zeroes) {
    # Dropping if any one is 0 is equal to keeping if none is 0
    df <- df %>% filter(whours != 0 & wage_no_compen != 0)
  }
  
  
  #=========================================================================#
  # Step 2 - Create wage data frame -----------------------------------------
  #=========================================================================#
  
  wage_ts_df <- 
    
    # Start with trimmed data frame from Step 1
    df %>%
    
    mutate(
      
      # Convert to weeekwage
      weekwage = case_when(unitwage == 1 ~ wage_no_compen * 7,     # daily
                           unitwage == 2 ~ wage_no_compen,         # weekly
                           unitwage == 3 ~ wage_no_compen / 2,     # fortnightly
                           unitwage == 4 ~ wage_no_compen / 8.67,  # bi-monthly
                           unitwage == 5 ~ wage_no_compen / 4.33,  # monthly
                           unitwage == 6 ~ wage_no_compen / 13,    # trimester
                           unitwage == 7 ~ wage_no_compen / 26,    # semester
                           unitwage == 8 ~ wage_no_compen / 52),   # annual
      
      # Convert week to hours
      hourwage = ifelse(unitwage < 9,
                        weekwage / whours,   # If unitwage is not hourly, make weekwage hourly
                        wage_no_compen),     # If unitwage is hourly, enter it directly
      
    ) %>%
    
    # Want to winsorize by year, thus need to group by year
    group_by(year) %>%
    
    mutate(
      
      # Winsorize outliers at 1st, 99th percentile
      hwage_p1  = Hmisc::wtd.quantile(x = hourwage, probs = 0.01, weight = weight),
      hwage_p99 = Hmisc::wtd.quantile(x = hourwage, probs = 0.99, weight = weight),
      h_wage = case_when(hourwage <= hwage_p1                        ~ hwage_p1,
                         hourwage >  hwage_p1 & hourwage < hwage_p99 ~ hourwage,
                         hourwage >= hwage_p99                       ~ hwage_p99)
    )
  
  # Now, depending on the grouping, we need to group by year or by year and group
  if (is.null(group)) {
    
    wage_ts_df <- wage_ts_df %>%
      
      group_by(year) %>%
      
      # Summarise to obtain the weighted percentiles, mean, sample size
      summarise(
        
        w_10 = Hmisc::wtd.quantile(x = h_wage, probs = 0.1,  weights = weight),
        w_25 = Hmisc::wtd.quantile(x = h_wage, probs = 0.25, weights = weight),
        w_50 = Hmisc::wtd.quantile(x = h_wage, probs = 0.5,  weights = weight),
        w_75 = Hmisc::wtd.quantile(x = h_wage, probs = 0.75, weights = weight),
        w_90 = Hmisc::wtd.quantile(x = h_wage, probs = 0.9,  weights = weight),
        w_mean = stats::weighted.mean(h_wage, w = weight, na.rm = TRUE),
        sample = n()
      )
    
  } else {
    
    wage_ts_df <- wage_ts_df %>%
      
      group_by(year, .data[[group]]) %>%
      
      # Summarise to obtain the weighted percentiles, mean, sample size
      summarise(
        
        w_10 = Hmisc::wtd.quantile(x = h_wage, probs = 0.1,  weights = weight),
        w_25 = Hmisc::wtd.quantile(x = h_wage, probs = 0.25, weights = weight),
        w_50 = Hmisc::wtd.quantile(x = h_wage, probs = 0.5,  weights = weight),
        w_75 = Hmisc::wtd.quantile(x = h_wage, probs = 0.75, weights = weight),
        w_90 = Hmisc::wtd.quantile(x = h_wage, probs = 0.9,  weights = weight),
        w_mean = stats::weighted.mean(h_wage, w = weight, na.rm = TRUE),
        sample = n()
      )
    
  }
  
  # Rename secondary grouping from var name to "grouping"
  # Process does nothing if group is NULL
  names(wage_ts_df)[names(wage_ts_df) %in% group] <- "grouping"
  
  #=========================================================================#
  # Step 3 - Read in data for CPI -------------------------------------------
  #=========================================================================#
  
  # Need CPI data to deflate - Read API from <<FP.CPI.TOTL>> indicator
  # Set URl (instructions from here --> https://datahelpdesk.worldbank.org/knowledgebase/articles/898581-api-basic-call-structures)
  url <- glue::glue("https://api.worldbank.org/v2/country/{country}/indicator/FP.CPI.TOTL?per_page=999&format=json")
  # Will load a list of 2, first is info, second is DF
  cpi <- jsonlite::fromJSON(url)[[2]]
  
  # As of December 2022, the values are centred on 2010 (= 100) but this may change
  # Hence we loaded above all years, find which year has 100
  base_year <- cpi$date[cpi$value %in% 100]
  
  # Keep only relevant info so we do not add too much in Step 4, 
  # rename date to year to match, make numeric
  cpi <- cpi %>% select(year = date, value) %>% mutate(year = as.numeric(year))
  
  #=========================================================================#
  # Step 4 - Merge CPI to wage data frame -----------------------------------
  #=========================================================================#
  
  left_join(wage_ts_df, cpi, by = "year") %>%
    
    # Deflate all wage info vars (all start with <<w_>>)
    mutate(
      across(starts_with("w_"), ~.x/(value/100)),
      # Add CPI base year
      cpi_base = base_year,
      # Add variable of interest (wage)
      var = "Hourly wage"
    )
  
}

