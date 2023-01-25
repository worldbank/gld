#' Plot wage time series data frame
#' 
#' This function plots a data frame with wage info over time from GLD surveys.
#'
#' @param wage_df The wage information over time data frame created by
#'   the <<make_wage_ts>> function.

plot_wage_ts <- function(wage_df) {
  

  # Step 1 - Prep data, axis names ------------------------------------------

  # Calcualte coefficient we are going to use for second axis
  avg_wage_value <- (min(wage_df$w_90) + max(wage_df$w_90)) / 2
  max_sample <- max(wage_df$sample)
  coeff <- max_sample/avg_wage_value
  
  # Define text for axes
  base_year <- unique(wage_df$cpi_base)
  y_ax_1 <- glue::glue("Hourly wage in local currency, deflated to base {base_year} = 100\n")
  y_ax_2 <- "\nSample size (shown as bars)"
  x_ax <- "Year"
  

  # Step 2 - Plot standard --------------------------------------------------

  plot <- 
    ggplot(wage_df, aes(x = factor(year))) +
    
    # Add boxplot
    geom_boxplot(
      stat = "identity", 
      width=.6,
      aes(lower  = w_25,
          upper  = w_75,
          middle = w_50,
          ymin   = w_10,
          ymax   = w_90)) +
    
    # Add mean as a point
    geom_point(aes(y =  w_mean), shape = 18, size = 5, colour = "red") +
    
    geom_col(aes(y = sample/coeff), fill = "darkgreen", width = 0.2, 
             alpha = 0.2, position = position_nudge(x = 0.45))  +
    
    scale_y_continuous(
      
      # Features of the first axis
      name = y_ax_1,
      
      # Add a second axis and specify its features
      sec.axis = sec_axis(~.*coeff, name=y_ax_2)
    ) +
    
    # Put the year info as text at 45 degrees angle
    theme(axis.text.x=element_text(angle=45,hjust=1,vjust=0.5))  +
    
    labs(x = "\nYear")
  

  # Step 3 - Plot faceted by group if passed group -------------------------
  
  if ("grouping" %in% names(wage_df)) {
    
    plot <- plot +
      
      facet_wrap(~grouping)
    
  }
  
  return(plot)
  
}
