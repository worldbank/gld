# Survey series check

## Overview

The series checks aims to help users inspect graphically a set of surveys for a country over time to ensure they are coherent and consistent.

The only file the user needs to use is the `process_time_series.R` file, consisting of seven steps, that are detailed here in the following.

## Step 1 - Define user variables

Step 1 is the only section requiring user input. The user ought to input the country [ISO alpha-3 code](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3) as well as the variables that they want to inspect, provided they are categorical (as are the variables listed below). Note that the wage information is automatically included and thus needs not to be listed.

Subsequently the user defines three paths, the first (`path_in`) points to the folder that contains all the surveys for that country. That is, the path to folder that contains the top level survey folders (i.e., folders of the "CCC_YYYY_[Survey_Name]" level). The second is to the folder where the user wants to store the graphs created for their inspection. The last path points to where the functions are stored (i.e., where all the files listed in this GLD directory starting with "function" are stored on the user's system).

```
# Enter country ISO Alpha 3 code
country <- "[CCC]"

# Enter variables that ought to be analysed (or leave standard variables)
vars_to_study <- c("empstat", "educat7", "educat4", "industrycat10", "industrycat4", "occup", "lstatus")
# Note that wage will be included by default, no need to include here

# Define the path to the folder holding the series
path_in <- "[For example: Z:/GLD-Harmonization/573465_JT/ZAF]"

# Define the path to the folder where the graphs ought to be stored in
path_out <- "[Path to output folder]"

# Define the path to the folder where this code and the other functions of the survey series checks are stored
dir_w_functions <- "[Path to folder with functions]"
```

## Step 2 - Call libraries, functions

Step 2 defines the packages that are needed, ensures they are installed and loads them. It then runs the GLD functions for the survey series checks.

```
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
```

## Step 3 - Load DF

Step 3 uses the function defined in `function_load_df.R`. It uses as input the path defined at the start. The function will enter the path and extract the latest harmonized dataset for each folder. That is, if the BRA_2018_PNADC folder has four harmonized versions (from V01_A to V04_A), the function will select the latest (here V04_A). It then will extract the necessary variables (e.g., age, weight, unitwage, ...) plus the variables defined at the start to inspect and append all data files into a single dataset. If the option `wap_only` is set to TRUE (as shown below) the data will be restricted to the working age population.

```
df <- load_df(path_in = path_in,
              wap_only = TRUE,
              vars_to_study = vars_to_study)
```

## Step 4 - Make time series data frames

Step 4 makes a list of aggregated data for each variable in the vector `vars_to_study` provided by the user in Step 1 using the function defined in `function_make_cat_ts.R`. For each variable the shares per year and variable category (excluding NAs), so that the shares sum to 1 for each year.

If the option `employed` is set to `TRUE` (as shown below), the calculations apply only to those who are employed (i.e., for those with `lstatus == 1`). Note that the function automatically will not apply this reduction to the employed sub-sample if the variable passed is `lstatus` (as otherwise there would be no information value).

```
summary_df_list <-
  purrr::map(
    vars_to_study,
    ~make_cat_ts(df = df,
                 var = .x,
                 employed = TRUE))
```

## Step 5 - Make wage time series data frame

Step 5 uses the function defined in `function_make_wage_ts_R` to calculate for the wage employed (`empstat == 1`) the mean and median hourly wages as well as the 10th, 25th, 75th, and 90th percentile for each year. It also stores the sample size of respondents for which there are answers for all variables used to calculate the hourly wage (`unitwage`, `whours`, and `wage_no_compen`)

```
wage_df <-
  make_wage_ts(
    df = df,
    country = country)
```

## Step 6 - Make time series plots

Step 6 creates a list of plots. Firstly, the list of shares over the categorical variables from Step 4 is run to create a graph for each, using the function defined in `function_plot_cat_ts.R`. Then, an additional plot for the wage information created in Step 5 is added using the function defined in `function_plot_wage_ts.R`.

```
summary_plots <- purrr::map(summary_df_list, ~plot_cat_ts(.x))

# Add wage plot as the n_th plot
n_th <- length(vars_to_study) + 1
summary_plots[[n_th]] <- plot_wage_ts(wage_df = wage_df)
```

## Step 7 - Save all summary plots

Step 7, the last step, simply takes the list of plots from Step 6 and stores them in the folder defined by `path_out` given by the user in Step 1 using the function defined in `function_save_ts_plots.R`.

```
purrr::walk(summary_plots,
            ~save_ts_plots(.x,
                           out_folder = path_out,
                           country = country))
```
