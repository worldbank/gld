#' Save categorical time-series plots
#' 
#' This function saves the plots with shares by category over time from GLD surveys.
#'
#' @param plot The categorical shares over time plot created by
#'   the <<plot_cat_ts>> function.
#' @param out_folder The path to the folder where you may wish to store plots
#'   Note the function will create a subfolder with the date of execution
#'   inside the folder defined in <<out_folder>>.
#' @param country The ISO alpha 3 country code we are looking at

save_ts_plots <- function(
  plot, 
  out_folder, 
  country) {
  
  # Extract what var we are dealing with
  var <- unique(plot$data$var)
  
  # Save date, make a folder with the date
  date <- Sys.Date()
  folder <- glue::glue("{out_folder}/{country}_plots_{date}")
  if (!dir.exists(folder)) dir.create(folder)
  
  # Store plot as file in the aforementioned folder
  file <- glue::glue("{folder}/{country}_{var}.png")
  ggplot2::ggsave(filename = file,
                  plot = plot)
  
}