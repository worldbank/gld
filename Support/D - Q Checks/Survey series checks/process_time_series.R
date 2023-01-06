rm(list=ls())

#=========================================================================#
# Step 1 - Define user variables ------------------------------------------
#=========================================================================#

# Enter country ISO Alpha 3 code
country <- "[CCC]"

# Enter variables that ought to be analysed (or leave standard variables)
vars_to_study <- c("empstat", "educat7", "educat4", "industrycat10", "industrycat4", "occup", "lstatus")
# Note that wage will be included by default, no need to include here

# Define the path to the folder holding the series
path_in <- "[For example: Z:/GLD-Harmonization/123456_AZ/CCC]"

# Define the path to the folder where the graphs ought to be stored in
path_out <- "[Path to output folder]"

# Define the path to the folder where this code and the other functions of the survey series checks are stored
dir_w_functions <- "[Path to folder with functions]"


#=========================================================================#
# Step 2 - Call libraries, functions --------------------------------------
#=========================================================================#

# List packages that we need
pkgs <- c("Hmisc", "tidyverse")

# Check they are installed
pkgs_2_install <- pkgs[!(pkgs %in% installed.packages())]

# Install if not on system
for (pkg in pkgs_2_install) {
  install.packages(pkg)
}

# Load packages
for (pkg in pkgs) {
  library(pkg,character.only=TRUE)
}

purrr::walk(dir(dir_w_functions, pattern = "^function", full.names = T), ~source(.x))


#=========================================================================#
# Step 3 - Load DF --------------------------------------------------------
#=========================================================================#

df <- load_df(path_in = path_in,
              wap_only = TRUE,
              vars_to_study = vars_to_study)


#=========================================================================#
# Step 4 - Make time series data frames -----------------------------------
#=========================================================================#

summary_df_list <-
  purrr::map(
    vars_to_study,
    ~make_cat_ts(df = df,
                 var = .x,
                 employed = TRUE))


#=========================================================================#
# Step 5 - Make wage time series data frame -------------------------------
#=========================================================================#

wage_df <-
  make_wage_ts(
    df = df,
    country = country)


#=========================================================================#
# Step 6 - Make time series plots -----------------------------------------
#=========================================================================#

summary_plots <- purrr::map(summary_df_list, ~plot_cat_ts(.x))

# Add wage plot as the n_th plot
n_th <- length(vars_to_study) + 1
summary_plots[[n_th]] <- plot_wage_ts(wage_df = wage_df)


#=========================================================================#
# Step 7 - Save all summary plots -----------------------------------------
#=========================================================================#

purrr::walk(summary_plots,
            ~save_ts_plots(.x,
                           out_folder = path_out,
                           country = country))
