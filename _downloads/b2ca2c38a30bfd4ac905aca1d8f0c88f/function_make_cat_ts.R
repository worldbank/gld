#' Make categorical time-series DF
#' 
#' This function creates a DF with shares by category over time from GLD surveys.
#'
#' @param df The data frame to be used (a GLD harmonized dataset)
#' @param var The variable (its name as a string) to be categorised
#' @param employed Binary indicator of whether the data should be 
#'   reduced only to those who are employed (default is FALSE)
#' @param wage_emp Binary indicator of whether the data should be
#'   reduced only to the wage-employed (default is FALSE)
#' @param drop_miss Binary indicator of whether the data should 
#'   drop cases when var is missing (default is TRUE)

make_cat_ts <- function(
    df, 
    var, 
    employed = FALSE, 
    wage_emp = FALSE, 
    drop_miss = TRUE) {
  
  # Keep only employed if requested (and var is not lstatus, since there it makes no sense)
  if (employed & var != "lstatus") {
    df <- df %>% filter(lstatus == 1)
  }
  
  # Keep only wage employed if requested
  if (wage_emp) {
    df <- df %>% filter(empstat == 1)
  }
  
  # Drop missing if requested
  if (drop_miss) {
    df <- df %>% filter(!is.na(.data[[var]]))
  }
  
  # Want to create the data frame with the shares by category over the time series
  cat_ts_df <- 
    
    # Start wit df
    df %>% 
    
    # Group over year and the variable of interest
    group_by(year, .data[[var]]) %>%
    
    # Get the number of responses per year/var category
    # which is equal to the sum of the weights by group
    summarise(var_cat_year_total = sum(weight, na.rm = TRUE)) %>%
    
    # Ungroup, group only by year
    ungroup() %>%
    group_by(year) %>%
    
    mutate(
      
      # Calculate the total by the year
      var_year_total = sum(var_cat_year_total),
      # Calculate the share per category of variable of interest
      var_cat_share  = var_cat_year_total / var_year_total,
      # Record the variable (its categories) as a factor
      var_cat_factor = haven::as_factor(.data[[var]]),
      # Store also the name of the variable
      var = var) %>%
    
    # Keep only the variables of interest
    select(year, var_cat_share, var_cat_factor, var)
  
}