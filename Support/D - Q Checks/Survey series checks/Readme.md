# Guide to the GLD survey series quality checks

## Overview

The survey series checks help users inspect a set of GLD surveys for one country over time. The current workflow creates plots for categorical variables and wages so a reviewer can quickly spot breaks in a survey series.

The main file is [`process_time_series.R`](process_time_series.R). It sources the helper functions in this folder and runs seven steps:

1. Define user inputs.
2. Load packages and helper functions.
3. Load the latest harmonized GLD files.
4. Build categorical time-series summaries.
5. Build wage time-series summaries.
6. Create plots.
7. Save plots.

## Step 1 - Define user variables

Edit the country code, variables to inspect, and paths at the top of [`process_time_series.R`](process_time_series.R).

```r
# Enter country ISO Alpha 3 code
country <- "[CCC]"

# Enter categorical variables to analyse.
# Wage is included separately by default.
vars_to_study <- c(
  "empstat",
  "educat7",
  "educat4",
  "industrycat10",
  "industrycat4",
  "occup",
  "lstatus"
)

# Folder that contains the country survey folders, for example CCC_YYYY_SurveyName
path_in <- "C:/path/to/GLD/country/folder"

# Folder where plots should be saved
path_out <- "C:/path/to/output/folder"

# Folder where this code and the helper functions are stored
dir_w_functions <- "C:/path/to/Survey series checks"
```

## Step 2 - Load packages and functions

The script loads the packages and helper functions needed for the workflow.

The core script currently lists `Hmisc` and `tidyverse`. The helper functions also use package namespaces from `haven`, `glue`, `jsonlite`, and `scales`. These are often installed as part of the same R environment, but a clean setup should make sure they are available.

```r
pkgs <- c("Hmisc", "tidyverse")

pkgs_2_install <- pkgs[!(pkgs %in% installed.packages())]

for (pkg in pkgs_2_install) {
  install.packages(pkg)
}

for (pkg in pkgs) {
  library(pkg, character.only = TRUE)
}

purrr::walk(
  dir(dir_w_functions, pattern = "^function", full.names = TRUE),
  ~source(.x)
)
```

## Step 3 - Load harmonized data

[`function_load_df.R`](function_load_df.R) loads the latest amended GLD harmonization for each survey folder.

The loader expects:

- country survey folders named like `CCC_YYYY_SurveyName`;
- version folders ending in `_A_GLD`;
- one harmonized data file under `Data/Harmonized`.

It keeps core variables plus the requested variables, then filters to the requested age range.

```r
df <- load_df(
  path_in = path_in,
  age_min = 15,
  age_max = 64,
  vars_to_study = vars_to_study
)
```

## Step 4 - Build categorical time series

[`function_make_cat_ts.R`](function_make_cat_ts.R) creates weighted shares by year and category for each requested categorical variable.

When `employed = TRUE`, the function restricts to employed individuals (`lstatus == 1`) except when the variable itself is `lstatus`.

```r
summary_df_list <-
  purrr::map(
    vars_to_study,
    ~make_cat_ts(
      df = df,
      var = .x,
      employed = TRUE
    )
  )
```

## Step 5 - Build wage time series

[`function_make_wage_ts.R`](function_make_wage_ts.R) calculates hourly wage statistics for wage-employed workers, including weighted percentiles, weighted mean, and sample size by year.

The wage function converts wages to hourly values, winsorizes by year at the 1st and 99th weighted percentiles, and deflates wages using World Bank CPI data.

```r
wage_df <-
  make_wage_ts(
    df = df,
    country = country
  )
```

## Step 6 - Create plots

[`function_plot_cat_ts.R`](function_plot_cat_ts.R) creates stacked bar charts for categorical variables. [`function_plot_wage_ts.R`](function_plot_wage_ts.R) creates a wage distribution plot with sample size bars.

```r
summary_plots <- purrr::map(summary_df_list, ~plot_cat_ts(.x))

n_th <- length(vars_to_study) + 1
summary_plots[[n_th]] <- plot_wage_ts(wage_df = wage_df)
```

## Step 7 - Save plots

[`function_save_ts_plots.R`](function_save_ts_plots.R) saves all plots to a dated country folder under `path_out`.

```r
purrr::walk(
  summary_plots,
  ~save_ts_plots(
    .x,
    out_folder = path_out,
    country = country
  )
)
```

## Notes and known assumptions

- The workflow is designed for visual inspection, not for automatically deciding whether a harmonization is correct.
- The latest harmonized version is selected by alphanumeric folder order after filtering to folders ending `_A_GLD`.
- Wage deflation depends on live World Bank CPI API access.
