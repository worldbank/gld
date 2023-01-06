#' Plot categorical time-series DF
#' 
#' This function plots the DF with shares by category over time from GLD surveys.
#'
#' @param ts_df The categorical shares over time data frame created by
#'   the <<make_cat_ts>> function.

plot_cat_ts <- function(ts_df) {
  
  # Extract the name of the variable the ts data frame looked at
  # so we can put it on the legend of the plot
  variable <- unique(ts_df$var)
  
  # Plot
  
  # Define data, years on the x axis, variables cat shares on the y axis,
  # colour the stacks per year by the variables categories (e.g., by employment status)
  ggplot(ts_df, aes(factor(year), var_cat_share, fill = var_cat_factor)) +
    
    # Build a barplot
    geom_col() +
    
    # Values on y axis as a neat percentage
    scale_y_continuous(labels = scales::label_percent()) +
    
    # Put the year info as text at 45 degrees angle
    theme(axis.text.x=element_text(angle=45,hjust=1,vjust=0.5)) + 
    
    # Set names to axes, legend
    labs(fill = variable, x = "Year", y = "Percentage share")
  
}