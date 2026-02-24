#' Example usage of the GLD survey update process
#'
#' This script shows how to run the update pipeline.
#'
#' INPUT FILE FORMAT
#' -----------------
#' CSV or Excel with these columns:
#'
#'   country  | year | survey | var_name | lines
#'   ---------+------+--------+----------+---------------------------
#'   ZAF      | 2020 | QLFS   | survey   | gen survey = "QLFS-Q1"
#'   ZAF      | 2020 | QLFS   | survey   | label var survey "Survey type"
#'   ZAF      | 2020 | QLFS   | lstatus  | gen lstatus = .
#'
#' Each row is one line of Stata code. All rows for the same
#' (country, year, survey, var_name) together replace the block currently
#' between *<_varname_> and *</_varname_> in the .do file.
#'
#' FOLDER STRUCTURE EXPECTED
#' -------------------------
#' base_path/
#'   ZAF/
#'     ZAF_2020_QLFS/
#'       ZAF_2020_QLFS_V01_M/
#'       ZAF_2020_QLFS_V01_M_V01_A_GLD/   <- latest GLD folder (source)
#'         Data/
#'           Harmonized/
#'         Doc/
#'         Programs/
#'           ZAF_2020_QLFS_V01_M_V01_A_GLD.do
#'         Work/
#'
#' The script will create:
#'   ZAF_2020_QLFS_V01_M_V02_A_GLD/
#'     Data/Harmonized/   (empty initially, running do file will fill)
#'     Programs/          (contains updated .do file)
#'     Doc/               (copied from V01)
#'     Work/              (copied from V01)

# Load libraries
library(tidyverse)
library(readxl)
library(readr)
library(tools)
library(glue)



# ----------------------------------------------------------------------- #
# Define paths
# ----------------------------------------------------------------------- #

input_file  <- "C:/Users/wb529026/WBG/GLD - Focal Point/Countries/PAK/pak_tza_updates.xlsx"   # xlsx or csv
base_path   <- "C:/Users/wb529026/WBG/GLD - Focal Point/Countries"
source_path <- "C:/Users/wb529026/WBG/GLD - Focal Point/Scripts/gld_code_updating/R/Version 2"
  
# ----------------------------------------------------------------------- #
# Source functions
# ----------------------------------------------------------------------- #

source(file.path(source_path, "helper_utilities.R"))
source(file.path(source_path, "validate_survey_combination.R"))
source(file.path(source_path, "execute_survey_updates.R"))
source(file.path(source_path, "orchestrate_updates.R"))

# ----------------------------------------------------------------------- #
# Run the complete update process
# ----------------------------------------------------------------------- #

results <- orchestrate_updates(
  input_file = input_file,
  base_path  = base_path,
  stata_path = "C:/Program Files/Stata18/StataMP-64.exe"  # optional
)

# Inspect results
results
