
###==========================================================================###
###==========================================================================###
###                                                                          ###
###  Collection of helper files to be used in validation and execution       ###
###                                                                          ###
###==========================================================================###
###==========================================================================###


#' Utility functions for the GLD update process
#' These support the main orchestration, validation, and execution functions

#' Read and standardize input from CSV or Excel
#'
#' @param input_file Path to CSV or Excel file
#' @return A tibble with columns: country, year, survey, var_name, lines
read_updates <- function(input_file) {
  
  ext <- tolower(tools::file_ext(input_file))
  
  if (ext == "csv") {
    readr::read_csv(input_file, col_types = readr::cols())
  } else if (ext %in% c("xlsx", "xls")) {
    readxl::read_excel(input_file)
  } else {
    stop("Input file must be CSV or Excel (.xlsx/.xls)")
  }
}

#' Pivot updates from long format to wide format (one entry per variable)
#'
#' @param updates_df Tibble with columns var_name and lines
#' @return Named list: variable name -> character vector of code lines
pivot_updates_to_wide <- function(updates_df, tab = TRUE) {
  
  updates_df |>
    dplyr::group_by(var_name) |>
    dplyr::summarize(
      lines = list({
        x <- replace(lines, is.na(lines), "")
        if(tab) paste0("\t", x) else x}), 
      .groups = "drop"
    ) |>
    tibble::deframe()
  
}

# --------------------------------------------------------------------------#
# Folder navigation
# --------------------------------------------------------------------------#

#' Build the survey-level folder path
#'
#' @param base_path Base path where country folders are stored
#' @param country   Three-letter country code, e.g. "ZAF"
#' @param year      Survey year as numeric or character, e.g. 2020
#' @param survey    Survey abbreviation, e.g. "QLFS"
#' @return Character path, e.g. "base_path/ZAF/ZAF_2020_QLFS"
build_survey_folder <- function(base_path, country, year, survey) {
  survey_dir <- paste(country, year, survey, sep = "_")
  file.path(base_path, country, survey_dir)
}

#' Find all _A_GLD folders within a survey-level folder
#'
#' Lists the direct children of the survey folder and returns those
#' whose names end in "_A_GLD".
#'
#' @param survey_folder Path returned by build_survey_folder()
#' @return Character vector of full paths to _A_GLD folders (may be empty)
find_gld_folders <- function(survey_folder) {
  
  all_dirs <- list.dirs(survey_folder, recursive = FALSE, full.names = TRUE)
  all_dirs[grepl("_A_GLD$", basename(all_dirs))]
}

#' Identify the latest (source) _A_GLD folder
#'
#' Takes the alphanumerically last entry from find_gld_folders(), which
#' corresponds to the highest A-version number given the naming convention.
#'
#' @param gld_folders Character vector from find_gld_folders()
#' @return Single character path to the latest GLD folder
latest_gld_folder <- function(gld_folders) {
  
  sort(gld_folders) |> tail(1)
}

#' Derive the name of the next _A_GLD folder
#'
#' Parses the A-version number (V## between _M_ and _A_GLD) from the source
#' folder name, increments it by 1, and returns the new folder name.
#'
#' @param source_folder_name Basename of the source GLD folder,
#'   e.g. "ZAF_2020_QLFS_V01_M_V02_A_GLD"
#' @return Character: new folder basename,
#'   e.g. "ZAF_2020_QLFS_V01_M_V03_A_GLD"
next_gld_folder_name <- function(source_folder_name) {
  
  # Match the A-version segment: _V##_A_GLD at the end
  m <- regmatches(
    source_folder_name,
    regexpr("_V(\\d+)_A_GLD$", source_folder_name, perl = TRUE)
  )
  
  if (length(m) == 0 || nchar(m) == 0) {
    stop(glue::glue("Cannot parse A-version number from folder name: {source_folder_name}"))
  }
  
  # Extract the numeric part
  current_v <- as.integer(sub("_V(\\d+)_A_GLD$", "\\1", m, perl = TRUE))
  next_v    <- current_v + 1
  
  # Replace the A-version segment with the incremented value
  prefix <- sub("_V\\d+_A_GLD$", "", source_folder_name)
  paste0(prefix, "_V", sprintf("%02d", next_v), "_A_GLD")
}

# --------------------------------------------------------------------------#
# .do file location
# --------------------------------------------------------------------------#

#' Find the single .do file in the Programs subfolder of a GLD folder
#'
#' @param gld_folder Full path to a _A_GLD folder
#' @return Full path to the .do file, or an error/warning is raised
#'   (validation should have caught problems before this is called)
find_do_file <- function(gld_folder) {
  
  programs_dir <- file.path(gld_folder, "Programs")
  
  if (!dir.exists(programs_dir)) {
    stop(glue::glue("Programs folder does not exist: {programs_dir}"))
  }
  
  do_files <- list.files(programs_dir, pattern = "\\.do$",
                         full.names = TRUE, recursive = FALSE)
  do_files
}

# --------------------------------------------------------------------------#
# Code section extraction and replacement
# --------------------------------------------------------------------------#

#' Extract the current code block for a variable
#'
#' Looks for the markers *<_varname_> and *</_varname_> and returns the
#' lines between them (excluding the markers themselves).
#'
#' @param code_lines Character vector of lines read from a .do file
#' @param var_name   Variable name, e.g. "survey"
#' @return Character vector of lines between the markers, or NA if not found
extract_current_code_for_variable <- function(code_lines, var_name) {
  
  start_marker <- paste0("*<_", var_name, "_>")
  end_marker   <- paste0("*</_", var_name, "_>")
  
  start_idx <- grep(start_marker, code_lines, fixed = TRUE)
  end_idx   <- grep(end_marker,   code_lines, fixed = TRUE)
  
  if (length(start_idx) == 0 || length(end_idx) == 0) {
    return(NA)
  }
  
  code_lines[(start_idx + 1):(end_idx - 1)]
}

#' Replace the code block for a variable between its markers
#'
#' @param code_lines     Character vector of lines from a .do file
#' @param var_name       Variable name whose block should be replaced
#' @param new_code_lines Replacement lines (not including the markers)
#' @return Updated character vector
update_code_between_tags <- function(code_lines, var_name, new_code_lines) {
  
  start_marker <- paste0("*<_", var_name, "_>")
  end_marker   <- paste0("*</_", var_name, "_>")
  
  start_idx <- grep(start_marker, code_lines, fixed = TRUE)
  end_idx   <- grep(end_marker,   code_lines, fixed = TRUE)
  
  if (length(start_idx) != 1) {
    stop(glue::glue("Expected 1 start marker for '{var_name}', found {length(start_idx)}"))
  }
  if (length(end_idx) != 1) {
    stop(glue::glue("Expected 1 end marker for '{var_name}', found {length(end_idx)}"))
  }
  
  c(
    code_lines[1:start_idx],
    new_code_lines,
    code_lines[end_idx:length(code_lines)]
  )
}

# --------------------------------------------------------------------------#
# Do file header updates
# --------------------------------------------------------------------------#

#' Update the local veralt line to the new A-version number
#'
#' Finds any line matching `local <whitespace> veralt <whitespace> "V##"`
#' and replaces the version token with the new A-version extracted from the
#' new GLD folder name (e.g. "V06").
#'
#' @param code_lines   Character vector of lines from a .do file
#' @param new_gld_name Basename of the new GLD folder,
#'   e.g. "PAK_2020_LFS_V01_M_V06_A_GLD"
#' @return Updated character vector
update_veralt <- function(code_lines, new_gld_name) {

  # Extract the new A-version number from the folder name (_V##_A_GLD at end)
  m <- regmatches(
    new_gld_name,
    regexpr("_V(\\d+)_A_GLD$", new_gld_name, perl = TRUE)
  )
  if (length(m) == 0 || nchar(m) == 0) {
    stop(glue::glue("Cannot parse A-version number from folder name: {new_gld_name}"))
  }
  new_v_str <- sub("_V(\\d+)_A_GLD$", "V\\1", m, perl = TRUE)

  # Match lines of the form: local[ws]veralt[ws]"V##..."
  # Replace only the version token inside the quotes
  gsub(
    pattern     = "^(\\s*local\\s+veralt\\s+\")V[0-9]+(\".*)",
    replacement = paste0("\\1", new_v_str, "\\2"),
    x           = code_lines,
    perl        = TRUE
  )
}

#' Update the <_Program name_> header line to the new do file name
#'
#' Finds the line containing `<_Program name_>` and `</_Program name_>` and
#' replaces whatever is between the tags (excluding surrounding whitespace)
#' with the new do file name.
#'
#' @param code_lines      Character vector of lines from a .do file
#' @param new_do_filename New do file name, e.g. "PAK_2020_LFS_V01_M_V06_A_GLD_ALL.do"
#' @return Updated character vector
update_program_name <- function(code_lines, new_do_filename) {

  gsub(
    pattern     = "(<_Program name_>)\\s+.*?\\s+(</_Program name_>)",
    replacement = paste0("\\1\t\t\t\t", new_do_filename, " \\2"),
    x           = code_lines,
    perl        = TRUE
  )
}

# --------------------------------------------------------------------------#
# Version control block
# --------------------------------------------------------------------------#

#' Append a new dated entry to the Version Control block
#'
#' Finds the <_Version Control_> ... </_Version Control_> block and inserts
#' a new "* Date: YYYY-MM-DD - update [vars]" line immediately before the
#' closing tag, preserving all existing entries.
#'
#' @param code_lines Character vector of lines from a .do file
#' @param var_names  Character vector of variable names that were updated
#' @return Updated character vector
update_version_control <- function(code_lines, var_names) {
  
  start_marker <- "<_Version Control_>"
  end_marker   <- "</_Version Control_>"
  
  start_idx <- grep(start_marker, code_lines, fixed = TRUE)
  end_idx   <- grep(end_marker,   code_lines, fixed = TRUE)
  
  if (length(start_idx) == 0 || length(end_idx) == 0) {
    stop("Version Control block not found in .do file. ",
         "Expected markers: <_Version Control_> and </_Version Control_>")
  }
  if (length(start_idx) != 1 || length(end_idx) != 1) {
    stop("Multiple Version Control blocks found; expected exactly one.")
  }
  
  date_str  <- format(Sys.Date(), "%Y-%m-%d")
  vars_str  <- paste(var_names, collapse = ", ")
  new_entry <- paste0("* Date: ", date_str, " - update ", vars_str)
  
  # Insert the new entry and a blank line just before the closing tag
  c(
    code_lines[1:(end_idx - 1)],
    new_entry,
    "",
    code_lines[end_idx:length(code_lines)]
  )
}

# --------------------------------------------------------------------------#
# Stata execution
# --------------------------------------------------------------------------#

#' Execute a Stata .do file (Windows only)
#'
#' @param do_file_path Full path to the .do file
#' @param stata_path   Path to the Stata executable; if NULL, searches PATH
execute_stata_do_file <- function(do_file_path, stata_path = NULL) {
  
  if (.Platform$OS.type != "windows") {
    stop("Stata execution is only supported on Windows")
  }
  
  if (is.null(stata_path)) {
    stata_path <- Sys.which("stata")
    if (stata_path == "") {
      stop("Stata not found in PATH. Please supply the stata_path argument.")
    }
  }
  
  cmd <- glue::glue('"{stata_path}" /e do "{do_file_path}"')
  system(cmd, wait = TRUE)
  
  invisible(TRUE)
}
